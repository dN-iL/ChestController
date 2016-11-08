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
    var componentTest: TestController?
    var speedTest: TestController?
    var currentCEsForSpeedTest = 1
    var stdDummyDataRunning = true
    let possibleNumbersOfCEs = [1,2,3]
    var selectedNumberOfCEs = 1
    let possibleTimeBetweenBursts = [20,10,5]
    var selectedTimeBetweenBursts = 20
    
    @IBOutlet var numberOfCEs: UIPickerView!
    @IBOutlet var timeBetweenBursts: UIPickerView!
    @IBOutlet var missionNameLabel: UILabel!
    @IBOutlet var statusLabel: UILabel!
    @IBOutlet var participantStatusLabel: UILabel!
    
    @IBAction func startComponentTest(_ sender: AnyObject) {
        showConfirmationModal(test: Tests.component)
    }
    
    @IBAction func startSpeedtest(_ sender: AnyObject) {
        showConfirmationModal(test: Tests.speed(numberOfCEs: selectedNumberOfCEs, timeBetweenBursts: selectedTimeBetweenBursts))
    }
    
    private func showConfirmationModal(test: Tests) {
        var message = "The \(test.getName()) will be started as soon as you press okay."
        switch test {
        case .speed(numberOfCEs: _, timeBetweenBursts: _):
            message += "\nNumber of CEs: \(selectedNumberOfCEs), Time Between: \(selectedTimeBetweenBursts)"
            break
        default:
            break
        }
        let confirmationModal = UIAlertController(title: "Are you sure?", message: message, preferredStyle: UIAlertControllerStyle.alert)
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
            self.componentTest = TestController(kindof: Tests.component, forMission: mission)
        }
        numberOfCEs.delegate = self
        timeBetweenBursts.delegate = self
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
            componentTest.startTest()
        }
    }
    
    private func activateSpeedTestData() {
        if let mission = mission {
            speedTest = TestController(kindof: Tests.speed(numberOfCEs: selectedNumberOfCEs, timeBetweenBursts: selectedTimeBetweenBursts), forMission: mission)
            speedTest!.startTest()
        }
    }
}

extension MissionDetailViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == numberOfCEs {
            return possibleNumbersOfCEs.count
        } else if pickerView == timeBetweenBursts {
            return possibleTimeBetweenBursts.count
        }
        return -1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == numberOfCEs {
            return String(possibleNumbersOfCEs[row])
        } else if pickerView == timeBetweenBursts {
            return String(possibleTimeBetweenBursts[row])
        }
        return "n/a"
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == numberOfCEs {
            selectedNumberOfCEs = possibleNumbersOfCEs[row]
        } else if pickerView == timeBetweenBursts {
            selectedTimeBetweenBursts = possibleTimeBetweenBursts[row]
        }
    }
}
