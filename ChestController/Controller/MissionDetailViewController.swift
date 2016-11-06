//
//  MissionDetailViewController.swift
//  ChestController
//
//  Created by Daniel on 31.10.16.
//  Copyright © 2016 Daniel. All rights reserved.
//

import UIKit

class MissionDetailViewController: UIViewController {
    
    var mission: Mission?
    
    @IBOutlet var missionNameLabel: UILabel!
    @IBOutlet var statusLabel: UILabel!
    @IBOutlet var participantStatusLabel: UILabel!
    
    @IBAction func startComponentTest(_ sender: AnyObject) {
    }
    
    @IBAction func startSpeedtest(_ sender: AnyObject) {
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        initializeData()
        
    }

    private func initializeData() {
        if let mission = mission {
            missionNameLabel.text = mission.name
            statusLabel.text = "ID: \(mission.id). "
            if let participants = mission.participants {
                participantStatusLabel.text = "This mission currently has \(participants.count) participants"
            } else {
                participantStatusLabel.text = "No participants found though!"
            }
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
