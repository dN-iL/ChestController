//
//  MqttController.swift
//  ChestController
//
//  Created by Daniel on 31.10.16.
//  Copyright © 2016 Daniel. All rights reserved.
//

import Foundation
import CocoaMQTT

public class MqttController {
    let mqtt: CocoaMQTT
    let mission: Mission
    let missionBaseTopic: String
    
    init(mission: Mission) {
        self.mqtt = CocoaMQTT(clientId: "ChestController-\(arc4random_uniform(99999999))", host: "192.168.0.2", port: 1883)
        mqtt.connect()
        self.mission = mission
        self.missionBaseTopic = "missions/\(mission.id)/groups/1/participants/"
    }
    
    func publish(topic: String, message: String) {
        mqtt.publish(topic, withString: message)
    }
    
    func logScenarioBlockStart(forBlock: ScenarioBlocks) {
        sendScenarioBlockLog(startEnd: "startScenarioBlock", forBlock: forBlock)
    }
    
    func logScenarioBlockEnd(forBlock: ScenarioBlocks) {
        sendScenarioBlockLog(startEnd: "endScenarioBlock", forBlock: forBlock)
    }
    
    private func sendScenarioBlockLog(startEnd: String, forBlock: ScenarioBlocks) {
        let timestamp = round(NSDate().timeIntervalSince1970)
        let helperDict = ["event": startEnd, "description": forBlock.rawValue, "timestamp": String(timestamp)]
        let jsonMessage = try! JSONSerialization.data(withJSONObject: helperDict, options: JSONSerialization.WritingOptions.prettyPrinted)
        let stringMessage = NSString(data: jsonMessage, encoding: String.Encoding.ascii.rawValue)
        if let stringMessage = stringMessage {
            print(stringMessage)
            let stringWithoutLinebreaks = stringMessage.replacingOccurrences(of: "\n", with: "")
            mqtt.publish("logs", withString: stringWithoutLinebreaks)
        }
    }
    
    func publishEvent(event: Event, forParticipant: String, baseValues:[Int]) -> [Int] {
        let newValues = generateValues(forEvent: event, baseValues: baseValues)
        let topicAndMessage = generateMessages(forEvent: event, forParticipant: forParticipant, withValues: newValues)
        for (topic, message) in topicAndMessage {
            mqtt.publish(topic, withString: message)
        }
        return newValues
    }
    
    private func generateValues(forEvent: Event, baseValues: [Int]) -> [Int] {
        let newValues = generateNewBaseline(forEvent: forEvent, withBaseValues: baseValues)
        return generateNextValues(forValues: newValues)
    }
    
    private func generateNewBaseline(forEvent: Event, withBaseValues: [Int]) -> [Int] {
        var newValues = withBaseValues
        switch forEvent {
        case .Critical(forSensor: let sensor, forParticipantNr: _):
            let currentValue = newValues[sensor.getIndex()]
            if currentValue >= sensor.getBoundaries().2 {
                break
            }
            newValues[sensor.getIndex()] = sensor.getCriticalBaseline()
            break
        case .Warning(forSensor: let sensor, forParticipantNr: _):
            let currentValue = newValues[sensor.getIndex()]
            if currentValue >= sensor.getBoundaries().1 && currentValue < sensor.getBoundaries().2 {
                break
            }
            newValues[sensor.getIndex()] = sensor.getWarningBaseline()
            break
        case .Okay(forParticipantNr: _):
            let sensors = [Sensors.HeartRate, Sensors.StressLevel, Sensors.CoreTemp, Sensors.AnkleTemp, Sensors.WristTemp, Sensors.Humidity]
            for sensor in sensors {
                let currentValue = newValues[sensor.getIndex()]
                if currentValue < sensor.getBoundaries().1 && currentValue >= sensor.getBoundaries().0 {
                    break
                }
                newValues[sensor.getIndex()] = sensor.getNormalBaseline()
            }
            break
        default:
            break
        }
        return newValues
    }
    
    private func generateNextValues(forValues: [Int]) -> [Int] {
        let sensors = [Sensors.HeartRate, Sensors.StressLevel, Sensors.CoreTemp, Sensors.AnkleTemp, Sensors.WristTemp, Sensors.Humidity]
        var nextValues = forValues
        for sensor in sensors {
            var possibleChange = [Int]()
            let currentValue = forValues[sensor.getIndex()]
            //don't go lower than the current status
            if currentValue == sensor.getBoundaries().0 || currentValue == sensor.getBoundaries().1 || currentValue == sensor.getBoundaries().2 {
                possibleChange = [0,1]
            }
            //don't go higher than the current status
            else if currentValue == sensor.getBoundaries().1 - 1 || currentValue == sensor.getBoundaries().2 - 1 {
                possibleChange = [-1,0]
            } else {
                possibleChange = [-1,0,1]
            }
            let randomIndex = arc4random_uniform(UInt32(possibleChange.count-1))
            nextValues[sensor.getIndex()] = currentValue + possibleChange[Int(randomIndex)]
        }
        return nextValues
    }
    
    private func generateMessages(forEvent: Event, forParticipant: String, withValues: [Int]) -> [(String, String)] {
        let sensors = [Sensors.HeartRate, Sensors.StressLevel, Sensors.CoreTemp, Sensors.AnkleTemp, Sensors.WristTemp, Sensors.Humidity]
        var topicsAndMessages = [(String, String)]()
        let timestamp = round(NSDate().timeIntervalSince1970)
        let userId = forParticipant
        for sensor in sensors {
            let sensorType = sensor.getBackendSensorType()
            let deviceType = "SecureDataCollector"
            let value = String(withValues[sensor.getIndex()])
            let helperDict = ["userId": userId, "missionId": self.mission.id, "sensorType": sensorType, "deviceType": deviceType, "timestamp": String(timestamp), "value": value]
            let jsonMessage = try! JSONSerialization.data(withJSONObject: helperDict, options: JSONSerialization.WritingOptions.prettyPrinted)
            let stringMessage = NSString(data: jsonMessage, encoding: String.Encoding.ascii.rawValue)
            if let stringMessage = stringMessage {
                let stringWithoutLinebreaks = stringMessage.replacingOccurrences(of: "\n", with: "")
                let stringWithoutWhitespace = stringWithoutLinebreaks.replacingOccurrences(of: " ", with: "")
                let topic = generateTopic(forParticipant: forParticipant, forSensor: sensor)
                topicsAndMessages.append((topic, stringWithoutWhitespace))
            } else {
                topicsAndMessages.append(("", ""))
            }
        }
        return topicsAndMessages
    }
    
    private func generateTopic(forParticipant: String, forSensor: Sensors) -> String {
        return missionBaseTopic + "\(forParticipant)/devices/values/SecureDataCollector/\(forSensor.getBackendSensorType())"
    }
}

extension MqttController: CocoaMQTTDelegate {
    
    public func mqtt(_ mqtt: CocoaMQTT, didConnect host: String, port: Int) {
        print("MQTT did connect")
    }
    
    public func mqtt(_ mqtt: CocoaMQTT, didConnectAck ack: CocoaMQTTConnAck) {
        print("MQTT did connect ack")
    }
    
    public func mqtt(_ mqtt: CocoaMQTT, didPublishMessage message: CocoaMQTTMessage, id: UInt16) {
        print("MQTT published message \(message.string) to topic \(message.topic)")
    }
    
    public func mqtt(_ mqtt: CocoaMQTT, didPublishAck id: UInt16) {
        print("MQTT did publish Ack.")
    }
    
    public func mqtt(_ mqtt: CocoaMQTT, didReceiveMessage message: CocoaMQTTMessage, id: UInt16 ) {
        print(message)
    }
    
    public func mqtt(_ mqtt: CocoaMQTT, didSubscribeTopic topic: String) {
        NSLog("MQTT did subscribe to topic \(topic)")
    }
    
    public func mqtt(_ mqtt: CocoaMQTT, didUnsubscribeTopic topic: String) {
        NSLog("MQTT did unsubscribe from topic \(topic)")
    }
    
    public func mqttDidPing(_ mqtt: CocoaMQTT) {
        NSLog("MQTT did ping")
    }
    
    public func mqttDidReceivePong(_ mqtt: CocoaMQTT) {
        NSLog("MQTT did receive pong")
    }
    
    public func mqttDidDisconnect(_ mqtt: CocoaMQTT, withError err: Error?) {
        print("MQTT did disconnect")
    }
    
}
