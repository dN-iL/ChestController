//
//  RestApiController.swift
//  ChestController
//
//  Created by Daniel on 31.10.16.
//  Copyright © 2016 Daniel. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

protocol RestApiControllerDelegate {
    func handleResponse(response: [Mission])
}

public class RestApiController {
    
    var url = "http://192.168.0.2:80"
    var delegate : RestApiControllerDelegate?
    
    func getMissions() {
        Alamofire.request(url+"/api/mission").validate().responseJSON { response in
            guard response.result.error == nil else {
                return
            }
            if let data = response.result.value {
                let missions = self.processMissionsFromJSON(jsonObj: JSON(data))
                self.delegate?.handleResponse(response: missions)
            }
        }
    }
    
    private func processMissionsFromJSON(jsonObj: JSON) -> [Mission] {
        var missions = [Mission]()
        print(jsonObj)
        for(_, missionJson):(String, JSON) in jsonObj {
            var participants = [Participant]()
            for(_, participantJson):(String, JSON) in missionJson["participants"] {
                participants.append(Participant(id: String(describing: participantJson["userId"]), name: nil))
            }
            missions.append(Mission(id: String(describing: missionJson["_id"]), name: String(describing: missionJson["name"]), participants: participants))
        }
        return missions
    }
    
    func startStdDummyData() {
        Alamofire.request(url+"/api/mockupData/sensorData/start")
    }
    
    func stopStdDummyData() {
        Alamofire.request(url+"/api/mockupData/sensorData/stop")
    }
    
    func startKeepAlive() {
        Alamofire.request(url+"/api/mockupData/keepAlive/start")
    }
    
    func stopKeepAlive() {
        Alamofire.request(url+"/api/mockupData/keepAlive/stop")
    }
    
}
