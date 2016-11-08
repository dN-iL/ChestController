//
//  Event.swift
//  ChestController
//
//  Created by Daniel on 06.11.16.
//  Copyright © 2016 Daniel. All rights reserved.
//

enum Event {
    case Start
    case Okay(forParticipantNr: Int)
    case Warning(forSensor: Sensors, forParticipantNr: Int)
    case Critical(forSensor: Sensors, forParticipantNr: Int)
    case CoreTempPeak(forParticipantNr: Int)
    case NoConnection(forParticipantNr: Int)
    case BatteryEmpty(forParticipantNr: Int)
    case Retreated(forParticipantNr: Int)
    case End
}
