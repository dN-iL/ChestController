//
//  ScenarioBlocks.swift
//  ChestController
//
//  Created by Daniel on 31.10.16.
//  Copyright © 2016 Daniel. All rights reserved.
//

import Foundation

enum ScenarioBlocks: String {
    case stdCE
    case stdWarning
    case batteryEmpty
    case coreTempPeak
    case importantVsUnimportant
    case missionTimeExceeded
    case noConnection
    
    internal func getTimeline() -> [(Int, Event)] {
        let randomNumber = Int(arc4random_uniform(9999999))
        switch self {
        case .stdCE:
            return [(0, Event.Start), (1, Event.Critical(forSensor: Sensors.getRandom(), forParticipantNr: randomNumber)), (21, Event.Retreated(forParticipantNr: randomNumber)), (21, Event.End)]
        case .stdWarning:
            return [(0, Event.Start), (1, Event.Warning(forSensor: Sensors.getRandom(), forParticipantNr: randomNumber)), (21, Event.End)]
        case .batteryEmpty:
            return [(0, Event.Start), (1, Event.BatteryEmpty(forParticipantNr: randomNumber)), (2, Event.Critical(forSensor: Sensors.getRandom(), forParticipantNr: randomNumber)), (20, Event.Retreated(forParticipantNr: 1)), (22, Event.End)]
        case .coreTempPeak:
            return [(0, Event.Start), (1, Event.CoreTempPeak(forParticipantNr: randomNumber)), (4, Event.Okay(forParticipantNr: randomNumber)), (23, Event.End)]
        case .importantVsUnimportant:
            return [(0, Event.Start), (1, Event.Critical(forSensor: Sensors.Humidity, forParticipantNr: randomNumber)), (2, Event.Warning(forSensor: Sensors.WristTemp, forParticipantNr: randomNumber)), (5, Event.Critical(forSensor: Sensors.HeartRate, forParticipantNr: randomNumber+2)), (7, Event.Okay(forParticipantNr: randomNumber)), (20, Event.Retreated(forParticipantNr: randomNumber+2)), (25, Event.End)]
        case .noConnection:
            return [(0, Event.Start), (1, Event.NoConnection(forParticipantNr: randomNumber)), (21, Event.End)]
        default:
            return []
        }
    }
    
    internal func getLength() -> Int {
        if let endEvent = self.getTimeline().last {
            return endEvent.0
        }
        return -1
    }
}
