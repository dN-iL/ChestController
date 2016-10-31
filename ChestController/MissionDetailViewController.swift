//
//  MissionDetailViewController.swift
//  ChestController
//
//  Created by Daniel on 31.10.16.
//  Copyright © 2016 Daniel. All rights reserved.
//

import UIKit

class MissionDetailViewController: UIViewController {
    
    @IBOutlet var missionNameLabel: UILabel!
    @IBOutlet var statusLabel: UILabel!
    
    @IBAction func startComponentTest(_ sender: AnyObject) {
    }
    
    @IBAction func startSpeedtest(_ sender: AnyObject) {
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
