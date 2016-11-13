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
    var rest: RestApiController?
    var oneCE: TestController?
    var componentTest: TestController?
    var speedTest: TestController?
    var currentCEsForSpeedTest = 1
    var stdDummyDataRunning = true
    var possibleNumbersOfCEs: [Int]?
    var selectedNumberOfCEs = 1
    
    @IBOutlet var numberOfCEs: UIPickerView!
    @IBOutlet var missionNameLabel: UILabel!
    @IBOutlet var statusLabel: UILabel!
    @IBOutlet var participantStatusLabel: UILabel!
    
    @IBAction func fireOneCE(_ sender: Any) {
        showConfirmationModal(test: Tests.oneCE)
    }
    @IBAction func startComponentTest(_ sender: AnyObject) {
        showConfirmationModal(test: Tests.component)
    }
    
    @IBAction func startSpeedtest(_ sender: AnyObject) {
        showConfirmationModal(test: Tests.speed(numberOfCEs: selectedNumberOfCEs))
    }
    
    private func showConfirmationModal(test: Tests) {
        var message = "The \(test.getName()) will be started as soon as you press okay."
        switch test {
        case .speed(numberOfCEs: _):
            message += "\nNumber of CEs: \(selectedNumberOfCEs)"
            break
        default:
            break
        }
        let confirmationModal = UIAlertController(title: "Are you sure?", message: message, preferredStyle: UIAlertControllerStyle.alert)
        confirmationModal.addAction(UIAlertAction(title: "Okay!", style: .default, handler: { (action: UIAlertAction!) in
            switch test {
            case .oneCE:
                self.activateOneCE()
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
            self.componentTest = TestController(kindof: Tests.component, forMission: mission)
            self.oneCE = TestController(kindof: Tests.oneCE, forMission: mission)
            if let participants = mission.participants {
                let numberOfPaticipants = participants.count
                if numberOfPaticipants < 4 {
                    possibleNumbersOfCEs = [1]
                } else if numberOfPaticipants < 6 {
                    possibleNumbersOfCEs = [1,2]
                } else {
                    possibleNumbersOfCEs = [1,2,3]
                }
            }
        }
        numberOfCEs.delegate = self
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
    
    private func activateOneCE() {
        if let oneCE = oneCE {
            oneCE.startTest()
        }
    }
    
    private func activateComponentTestData() {
        if let componentTest = componentTest {
            componentTest.startTest()
        }
    }
    
    private func activateSpeedTestData() {
        if let mission = mission {
            speedTest = TestController(kindof: Tests.speed(numberOfCEs: selectedNumberOfCEs), forMission: mission)
            speedTest!.startTest()
        }
    }
}

extension MissionDetailViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if let possibleNumbersOfCEs = possibleNumbersOfCEs {
            return possibleNumbersOfCEs.count
        }
        return 0
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if let possibleNumbersOfCEs = possibleNumbersOfCEs {
            return String(possibleNumbersOfCEs[row])
        }
        return "no participants found"
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if let possibleNumbersOfCEs = possibleNumbersOfCEs {
            selectedNumberOfCEs = possibleNumbersOfCEs[row]
        }
    }
}
