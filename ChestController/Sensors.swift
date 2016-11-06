//
//  Sensors.swift
//  ChestController
//
//  Created by Daniel on 06.11.16.
//  Copyright © 2016 Daniel. All rights reserved.
//

import Foundation

enum Sensors {
    case HeartRate
    case StressLevel
    case CoreTemp
    case AnkleTemp
    case WristTemp
    case Humidity
    
    internal func getIndex() -> Int {
        switch self {
        case .HeartRate:
            return 0
        case .StressLevel:
            return 1
        case .CoreTemp:
            return 2
        case .AnkleTemp:
            return 3
        case .WristTemp:
            return 4
        case .Humidity:
            return 5
        }
    }
    
    internal func getBackendSensorType() -> String {
        switch self {
        case .HeartRate:
            return "heartRate"
        case .StressLevel:
            return ""
        case .CoreTemp:
            return "coreTemperature"
        case .AnkleTemp:
            return "ankleTemperature"
        case .WristTemp:
            return "wristTemperature"
        case .Humidity:
            return "backHumidity"
        }
    }
    
    //returns (lowerNormal, lowerWarning, lowerCritical)
    internal func getBoundaries() -> (Int,Int,Int) {
        switch self {
        case .HeartRate:
            return (80,180,185)
        case .StressLevel:
            return (0,6,8)
        case .CoreTemp:
            return (36,37,39)
        case .AnkleTemp, .WristTemp:
            return (30,39,43)
        case .Humidity:
            return (20,80,90)
        }
    }
    
    internal func getNormalBaseline() -> Int {
        switch self {
        case .HeartRate:
            return 90
        case .StressLevel:
            return 1
        case .CoreTemp:
            return 36
        case .AnkleTemp, .WristTemp:
            return 34
        case .Humidity:
            return 60
        }
    }
    
    internal func getWarningBaseline() -> Int {
        switch self {
        case .HeartRate:
            return 183
        case .StressLevel:
            return 7
        case .CoreTemp:
            return 38
        case .AnkleTemp, .WristTemp:
            return 40
        case .Humidity:
            return 85
        }
    }
    
    internal func getCriticalBaseline() -> Int {
        switch self {
        case .HeartRate:
            return 190
        case .StressLevel:
            return 9
        case .CoreTemp:
            return 40
        case .AnkleTemp, .WristTemp:
            return 45
        case .Humidity:
            return 95
        }
    }
    
    //for std ce and std warning
    static internal func getRandom() -> Sensors {
        let number = arc4random_uniform(2)
        switch number {
        case 0:
            return Sensors.HeartRate
        case 1:
            return Sensors.CoreTemp
        case 2:
            return Sensors.Humidity
        default:
            return Sensors.HeartRate
        }
    }
}
