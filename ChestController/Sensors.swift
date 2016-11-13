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
    case CoreTemp
    case AnkleTemp
    case WristTemp
    case Humidity
    case BreathingRate
    
    internal func getIndex() -> Int {
        switch self {
        case .HeartRate:
            return 0
        case .CoreTemp:
            return 1
        case .AnkleTemp:
            return 2
        case .WristTemp:
            return 3
        case .Humidity:
            return 4
        case .BreathingRate:
            return 5
        }
    }
    
    internal func getBackendSensorType() -> String {
        switch self {
        case .HeartRate:
            return "heartRate"
        case .CoreTemp:
            return "coreTemperature"
        case .AnkleTemp:
            return "ankleTemperature"
        case .WristTemp:
            return "wristTemperature"
        case .Humidity:
            return "backHumidity"
        case .BreathingRate:
            return "breathingRate"
        }
    }
    
    //returns (lowerNormal, lowerWarning, lowerCritical, maximum)
    internal func getBoundaries() -> [(Int,Int)] {
        switch self {
        case .HeartRate:
            return [(80,175),(182,195),(210,220)]
        case .CoreTemp:
            return [(36,37),(40,41),(42,43)]
        case .AnkleTemp, .WristTemp:
            return [(33,37),(40,41),(42,43)]
        case .Humidity:
            return [(20,75),(82,85),(98,100)]
        case .BreathingRate:
            return [(18,21),(23,24),(25,45)]
        }
    }
    
    internal func getNormalBaseline() -> Int {
        switch self {
        case .HeartRate:
            return 90
        case .CoreTemp:
            return 36
        case .AnkleTemp, .WristTemp:
            return 34
        case .Humidity:
            return 60
        case .BreathingRate:
            return 20
        }
    }
    
    internal func getWarningBaseline() -> Int {
        switch self {
        case .HeartRate:
            return 185
        case .CoreTemp:
            return 40
        case .AnkleTemp, .WristTemp:
            return 40
        case .Humidity:
            return 83
        case .BreathingRate:
            return 23
        }
    }
    
    internal func getCriticalBaseline() -> Int {
        switch self {
        case .HeartRate:
            return 215
        case .CoreTemp:
            return 42
        case .AnkleTemp, .WristTemp:
            return 43
        case .Humidity:
            return 97
        case .BreathingRate:
            return 35
        }
    }
    
    //for std ce and std warning
    static internal func getRandom() -> Sensors {
        let possibleSensors = [Sensors.HeartRate, Sensors.Humidity]
        let randomIndex = Int(arc4random_uniform(UInt32(possibleSensors.count)))
        return possibleSensors[randomIndex]
    }
    
    static internal func getAll() -> [Sensors] {
        return [Sensors.HeartRate, Sensors.CoreTemp, Sensors.AnkleTemp, Sensors.WristTemp, Sensors.Humidity, Sensors.BreathingRate] 
    }
    
    static internal func getBaselines() -> [Int] {
        return [90, 36, 34, 34, 60, 20]
    }
}
