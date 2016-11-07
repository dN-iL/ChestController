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
    var helperDict = [Int: String]()
    var delegate: ScenarioBlockDelegate?
    
    init(kindof: ScenarioBlocks, forMission: Mission, forParticipants: [(String, Event)], mqtt: MqttController, rest: RestApiController) {
        self.block = kindof
        self.mqtt = mqtt
        self.rest = rest
        self.participantsNextEvents = forParticipants
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
    updates the events in the participantsNextEvents array
    */
    @objc
    private func invokeMethod() {
        let nextEvent = events.remove(at: 0)
        switch nextEvent {
        case Event.Start:
            mqtt.logScenarioBlockStart(forBlock: block)
            break
        case Event.Critical( _, let participantNr), Event.Warning( _, let participantNr), Event.BatteryEmpty(forParticipantNr: let participantNr), Event.Retreated(forParticipantNr: let participantNr), Event.NoConnection(forParticipantNr: let participantNr):
            //check if event is a followup of another event and therefore the corresponding participant is in the helperDict
            if let participant = helperDict[participantNr] {
                changeEvent(name: participant, to: nextEvent)
            } else {
                var success = false
                while(!success) {
                    let index = Int(arc4random_uniform(UInt32(participantsNextEvents.count-1)))
                    let tuple = participantsNextEvents[index]
                    switch tuple.1 {
                    case .Okay:
                        participantsNextEvents[index].1 = nextEvent
                        helperDict[participantNr] = tuple.0
                        success = true
                        break
                    default:
                        success = false
                        break
                    }
                }
            }
            break
        case Event.End:
            makeAllRemainingParticipantsOkay()
            mqtt.logScenarioBlockEnd(forBlock: block)
            break
        default:
            break
        }
        switch nextEvent {
        case .NoConnection(forParticipantNr: _):
            rest.stopKeepAlive()
            break
        default:
            break
        }
        delegate?.updateEvents(withNew: participantsNextEvents)
    }
    
    private func changeEvent(name: String, to: Event) {
        for var tuple in participantsNextEvents {
            if tuple.0 == name {
                tuple.1 = to
            }
        }
    }
    
    private func makeAllRemainingParticipantsOkay() {
        for i in 0 ..< participantsNextEvents.count {
            let event = participantsNextEvents[i].1
            switch event {
            case .Okay(forParticipantNr: _), .Retreated(forParticipantNr: _):
                break
            default:
                participantsNextEvents[i].1 = Event.Okay(forParticipantNr: 0)
                break
            }
        }
        helperDict.removeAll()
        switch block {
        case .noConnection:
            rest.startKeepAlive()
            break
        default:
            break
        }
    }
}
