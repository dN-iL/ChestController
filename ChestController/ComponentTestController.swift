//
//  ComponentTestController.swift
//  ChestController
//
//  Created by Daniel on 05.11.16.
//  Copyright © 2016 Daniel. All rights reserved.
//

import Foundation

class ComponentTestController {
    var scenarioBlocks: [(Int, ScenarioBlock)]
    var participantsNextEvents = [(String, Event)]()
    var currentValues = [(String, [Int])]()
    var publishingProcess = Timer()
    let mqtt: MqttController
    
    init(mission: Mission) {
        if let missionParticipants = mission.participants {
            for participant in missionParticipants {
                participantsNextEvents.append((participant.id, Event.Okay(forParticipantNr: 0)))
                currentValues.append((participant.id, [90, 1, 36, 37, 37, 60]))
            }
        }
        self.mqtt = MqttController(mission: mission)
        scenarioBlocks = [
            (0, ScenarioBlock(kindof: ScenarioBlocks.importantVsUnimportant, forMission: mission, forParticipants: participantsNextEvents, mqtt: mqtt)),
            (24, ScenarioBlock(kindof: ScenarioBlocks.sdtWarning, forMission: mission, forParticipants: participantsNextEvents, mqtt: mqtt)),
            (47, ScenarioBlock(kindof: ScenarioBlocks.stdCE, forMission: mission, forParticipants: participantsNextEvents, mqtt: mqtt))
        ]
        for (_, block) in scenarioBlocks {
            block.delegate = self
        }
    }
    
    func startComponentTest() {
        for (offset, scenarioBlock) in scenarioBlocks {
            Timer.scheduledTimer(timeInterval: TimeInterval(offset), target: scenarioBlock, selector: #selector(ScenarioBlock.start), userInfo: nil, repeats: false)
        }
        publishingProcess = Timer.scheduledTimer(timeInterval: TimeInterval(0.2), target: self, selector: #selector(ComponentTestController.publishData), userInfo: nil, repeats: true)
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
        for var tuple in currentValues {
            if tuple.0 == forParticipant {
                tuple = (tuple.0, withValues)
            }
        }
    }
}

extension ComponentTestController: ScenarioBlockDelegate {
    func updateEvents(withNew: [(String, Event)]) {
        self.participantsNextEvents = withNew
    }
}
