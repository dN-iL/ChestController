//
//  ScenarioBlocks.swift
//  ChestController
//
//  Created by Daniel on 31.10.16.
//  Copyright © 2016 Daniel. All rights reserved.
//

enum ScenarioBlocks: String {
    case stdCE
    case sdtWarning
    case batteryEmpty
    case coreTempPeak
    case importantVsUnimportant
    case missionTimeExceeded
    case noConnection
    
    internal func getTimeline() -> [(Int, Event)] {
        switch self {
        case .stdCE:
            return [(0, Event.Start), (1, Event.Critical(forSensor: Sensors.getRandom(), forParticipantNr: 1)), (21, Event.End)]
        case .sdtWarning:
            return [(0, Event.Start), (1, Event.Warning(forSensor: Sensors.getRandom(), forParticipantNr: 1)), (21, Event.End)]
        case .batteryEmpty:
            return [(0, Event.Start), (1, Event.BatteryEmpty(forParticipantNr: 1)), (2, Event.Critical(forSensor: Sensors.getRandom(), forParticipantNr: 1)), (22, Event.End)]
        case .coreTempPeak:
            return [(0, Event.Start), (1, Event.Critical(forSensor: Sensors.CoreTemp, forParticipantNr: 1)), (3, Event.Okay(forParticipantNr: 1)), (23, Event.End)]
        case .importantVsUnimportant:
            return [(0, Event.Start), (1, Event.Critical(forSensor: Sensors.AnkleTemp, forParticipantNr: 1)), (1, Event.Critical(forSensor: Sensors.WristTemp, forParticipantNr: 1)), (5, Event.Critical(forSensor: Sensors.HeartRate, forParticipantNr: 2)), (7, Event.Okay(forParticipantNr: 1)), (25, Event.End)]
        case .noConnection:
            return [(0, Event.Start), (1, Event.NoConnection(forParticipantNr: 1)), (21, Event.End)]
        default:
            return []
        }
    }
}
