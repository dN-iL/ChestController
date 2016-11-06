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
    let topic = "logs"
    
    init() {
        self.mqtt = CocoaMQTT(clientId: "ChestController-\(arc4random_uniform(99999999))", host: "192.168.0.2", port: 9001)
    }
    
    func publishHealthData() {
        let message = buildHealthDataMessage()
        mqtt.publish(topic, withString: message)
    }
    
    private func buildHealthDataMessage() -> String {
        return ""
    }
}
