//
//  TestController.swift
//  ChestController
//
//  Created by Daniel on 05.11.16.
//  Copyright © 2016 Daniel. All rights reserved.
//

import Foundation

class TestController {
    var scenarioBlocks: [(offset: Int, ScenarioBlocks)]
    var participantsNextEvents = [(String, Event)]()
    var currentValues = [(String, [Int])]()
    var publishingProcess = Timer()
    var runningScenarioBlock = [ScenarioBlock]()
    let mission: Mission
    let mqtt: MqttController
    let rest = RestApiController()
    /* 
    define publishing interval (in seconds) here
    */
    let publishingInterval = 0.5
    
    init(kindof: Tests, forMission: Mission) {
        self.mission = forMission
        if let missionParticipants = mission.participants {
            for participant in missionParticipants {
                participantsNextEvents.append((participant.id, Event.Okay(forParticipantNr: 0)))
                currentValues.append((participant.id, Sensors.getBaselines()))
            }
        }
        self.mqtt = MqttController(mission: mission)
        self.scenarioBlocks = [(Int, ScenarioBlocks)]()
        switch kindof {
        case .component:
            /* COMPONENT TEST CONFIG
             define sequence of scenario blocks, offset of first block
             and pause between blocks here
             */
            let blockSequence = [
                ScenarioBlocks.stdCE,
                ScenarioBlocks.stdWarning,
                ScenarioBlocks.stdWarning,
                ScenarioBlocks.stdCE,
                //Battery empty
                ScenarioBlocks.coreTempPeak,
                ScenarioBlocks.stdWarning,
                ScenarioBlocks.importantVsUnimportant,
                //Mission time exceeded
                ScenarioBlocks.stdWarning,
                ScenarioBlocks.noConnection
            ]
            var offsetFirstBlock = 3
            let pauseBetweenBlocks = 5
            
            for block in blockSequence {
                scenarioBlocks.append((offset: offsetFirstBlock, block))
                offsetFirstBlock += block.getLength() + pauseBetweenBlocks
            }
            break
        case .speed(let numberOfCEs, let timeBetweenBursts):
            var offsetFirstBlock = 3
            if let numberOfParticipants = mission.participants?.count {
                var leftParticipants = numberOfParticipants
                while leftParticipants > 0 {
                    for i in 0..<numberOfCEs {
                        if leftParticipants > 0 {
                            scenarioBlocks.append((offset: offsetFirstBlock+i, ScenarioBlocks.stdCE))
                            leftParticipants -= 1
                        }
                    }
                    offsetFirstBlock += timeBetweenBursts
                }
            }
            break
        }
        print("==========SCENARIOBLOCKS")
        print(scenarioBlocks)
    }
    
    func startTest() {
        for (offset, _) in scenarioBlocks {
            Timer.scheduledTimer(timeInterval: TimeInterval(offset), target: self, selector: #selector(TestController.startNextScenarioBlock), userInfo: nil, repeats: false)
        }
        publishingProcess = Timer.scheduledTimer(timeInterval: TimeInterval(publishingInterval), target: self, selector: #selector(TestController.publishData), userInfo: nil, repeats: true)
    }
    
    @objc
    private func startNextScenarioBlock() {
        let nextKindOfBlock = scenarioBlocks.remove(at: 0).1
        let nextScenarioBlock = ScenarioBlock(kindof: nextKindOfBlock, forParticipants: participantsNextEvents, mqtt: mqtt, rest: rest)
        nextScenarioBlock.delegate = self
        runningScenarioBlock.append(nextScenarioBlock)
        nextScenarioBlock.start()
    }
    
    func stopComponentTest() {
        publishingProcess.invalidate()
    }
    
    @objc
    private func publishData() {
        for (id, event) in participantsNextEvents {
            var values = findBaseValues(forParticipant: id)
            values = mqtt.publishEvent(event: event, forParticipant: id, baseValues: values)
            replaceValues(forParticipant: id, withValues: values)
        }
    }
    
    private func findBaseValues(forParticipant: String) -> [Int] {
        for (id, values) in currentValues {
            if id == forParticipant {
                return values
            }
        }
        return []
    }
    
    private func replaceValues(forParticipant: String, withValues: [Int]) {
        for i in 0 ..< currentValues.count {
            if currentValues[i].0 == forParticipant {
                currentValues[i].1 = withValues
            }
        }
    }
}

extension TestController: ScenarioBlockDelegate {
    func updateEvents(withNew: [(String, Event)]) {
        self.participantsNextEvents = withNew
        for i in 0..<runningScenarioBlock.count {
            runningScenarioBlock[i].updateEvents(withNew: withNew)
        }
    }
}
