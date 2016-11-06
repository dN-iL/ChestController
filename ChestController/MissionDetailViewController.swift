//
//  MissionDetailViewController.swift
//  ChestController
//
//  Created by Daniel on 31.10.16.
//  Copyright © 2016 Daniel. All rights reserved.
//

import UIKit

enum Tests {
    case component
    case speed
    
    internal func getName() -> String {
        switch self {
        case .component:
            return "Component Test"
        case .speed:
            return "Speed Test"
        }
    }
}

class MissionDetailViewController: UIViewController {
    
    var mission: Mission?
    var rest: RestApiController?
    var componentTest: ComponentTestController?
    var stdDummyDataRunning = false
    
    @IBOutlet var missionNameLabel: UILabel!
    @IBOutlet var statusLabel: UILabel!
    @IBOutlet var participantStatusLabel: UILabel!
    @IBOutlet var currentActivity: UILabel!
    @IBAction func toggleStdDummyData(_ sender: AnyObject) {
        if let rest = rest {
            if(stdDummyDataRunning) {
                rest.stopStdDummyData()
                stdDummyDataRunning = false
            } else {
                rest.startStdDummyData()
                stdDummyDataRunning = true
            }
        }
    }
    
    @IBAction func startComponentTest(_ sender: AnyObject) {
        showConfirmationModal(test: Tests.component)
    }
    
    @IBAction func startSpeedtest(_ sender: AnyObject) {
        showConfirmationModal(test: Tests.speed)
    }
    
    private func showConfirmationModal(test: Tests) {
        let confirmationModal = UIAlertController(title: "Are you sure?", message: "The \(test.getName()) will be started as soon as you press okay.", preferredStyle: UIAlertControllerStyle.alert)
        confirmationModal.addAction(UIAlertAction(title: "Okay!", style: .default, handler: { (action: UIAlertAction!) in
            switch test {
            case .component:
                self.activateComponentTestData()
            case .speed:
                self.activateSpeedTestData()
            }
        }))
        confirmationModal.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(confirmationModal, animated: true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        initializeData()
        if let mission = mission {
            self.componentTest = ComponentTestController(mission: mission)
        }
    }

    private func initializeData() {
        if let mission = mission {
            missionNameLabel.text = mission.name
            statusLabel.text = "ID: \(mission.id)"
            if let participants = mission.participants {
                participantStatusLabel.text = "This mission currently has \(participants.count) participants"
            } else {
                participantStatusLabel.text = "No participants found!"
            }
        }
    }
    
    private func activateComponentTestData() {
        if let componentTest = componentTest {
            componentTest.startComponentTest()
        }
    }
    
    private func activateSpeedTestData() {
        
    }
}
