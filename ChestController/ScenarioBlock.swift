//
//  ScenarioBlock.swift
//  ChestController
//
//  Created by Daniel on 05.11.16.
//  Copyright © 2016 Daniel. All rights reserved.
//

import Foundation

protocol ScenarioBlockDelegate {
    func updateEvents(withNew: [(String, Event)])
}

class ScenarioBlock {
    
    let block: ScenarioBlocks
    var rest: RestApiController
    var mqtt: MqttController
    var participantsNextEvents = [(String, Event)]()
    var events = [Event]()
    var followUpHelperDict = [Int: String]()
    var delegate: ScenarioBlockDelegate?
    let identifier: Int
    
    init(kindof: ScenarioBlocks, forParticipants: [(String, Event)], mqtt: MqttController, rest: RestApiController) {
        self.block = kindof
        self.mqtt = mqtt
        self.rest = rest
        self.participantsNextEvents = forParticipants
        self.identifier = Int(arc4random_uniform(99999))
    }
    
    /*
    schedules the events that the block consists of
    */
    @objc
    public func start() {
        let timeline = block.getTimeline()
        for(offset, event) in timeline {
            //build queue for invokeMethod
            events.append(event)
            Timer.scheduledTimer(timeInterval: TimeInterval(offset), target: self, selector: #selector(ScenarioBlock.invokeMethod), userInfo: nil, repeats: false)
        }
    }
    
    /*
    maps next events to participants and updates the events in the participantsNextEvents array
    */
    @objc
    private func invokeMethod() {
        let nextEvent = events.remove(at: 0)
        //replace next event in participantNextEvents
        switch nextEvent {
        case Event.Start:
            mqtt.logScenarioBlockStart(forBlock: block, withIdentifier: identifier)
            break
        case Event.Critical( _, let participantNr), Event.Warning( _, let participantNr), Event.BatteryEmpty(forParticipantNr: let participantNr), Event.Retreated(forParticipantNr: let participantNr), Event.NoConnection(forParticipantNr: let participantNr), Event.CoreTempPeak(forParticipantNr: let participantNr), Event.Okay(forParticipantNr: let participantNr):
            //check if event is a followup of another event and therefore the corresponding participant is in the helperDict
            if let participant = followUpHelperDict[participantNr] {
                for i in 0 ..< participantsNextEvents.count {
                    if participantsNextEvents[i].0 == participant {
                        participantsNextEvents[i].1 = nextEvent
                    }
                }
            } else {
                var success = false
                var safetyCounter = 0
                while(!success && safetyCounter < 50) {
                    safetyCounter += 1
                    let index = Int(arc4random_uniform(UInt32(participantsNextEvents.count-1)))
                    let tuple = participantsNextEvents[index]
                    switch tuple.1 {
                    case .Okay:
                        participantsNextEvents[index].1 = nextEvent
                        if participantNr != 0 {
                            followUpHelperDict[participantNr] = tuple.0
                        }
                        success = true
                        break
                    default:
                        success = false
                        break
                    }
                }
                if safetyCounter == 50 {
                    print("Couldn't find free participant!")
                }
            }
            break
        case Event.End:
            for usedParticipant in followUpHelperDict {
                for i in 0..<participantsNextEvents.count {
                    if usedParticipant.value == participantsNextEvents[i].0 {
                        let event = participantsNextEvents[i].1
                        switch event {
                        case .Okay(forParticipantNr: _), .Retreated(forParticipantNr: _):
                            break
                        default:
                            participantsNextEvents[i].1 = Event.Okay(forParticipantNr: 0)
                        }
                    }
                }
            }
            followUpHelperDict.removeAll()
            switch block {
            case .noConnection:
                print("======STARTING keepAlive")
                rest.startKeepAlive()
                break
            default:
                break
            }
            mqtt.logScenarioBlockEnd(forBlock: block, withIdentifier: identifier)
            break
        }
        //stop keepAlive when no connection event occurs
        switch nextEvent {
        case .NoConnection(forParticipantNr: _):
            print("======STOPPING keepAlive")
            rest.stopKeepAlive()
            break
        default:
            break
        }
        delegate?.updateEvents(withNew: participantsNextEvents)
    }

    
    func updateEvents(withNew: [(String, Event)]) {
        self.participantsNextEvents = withNew
    }
}
