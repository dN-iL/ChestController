//
//  MissionOverviewTableViewController.swift
//  ChestController
//
//  Created by Daniel on 31.10.16.
//  Copyright © 2016 Daniel. All rights reserved.
//

import UIKit

class MissionOverviewTableViewController: UITableViewController {
    
    @IBOutlet var missionTableView: UITableView!
    
    var restApi = RestApiController()
    var missions : [Mission]?

    override func viewDidLoad() {
        super.viewDidLoad()
        restApi.delegate = self as RestApiControllerDelegate
        restApi.getMissions()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let missions = missions {
            return missions.count
        } else {
            return 0
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "MissionOverviewTableViewCell", for: indexPath) as? MissionOverviewTableViewCell,
            let missions = missions {
            cell.missionName.text = missions[indexPath.row].name
            return cell
        }
        return tableView.dequeueReusableCell(withIdentifier: "MissionOverviewTableViewCell", for: indexPath)
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toDetailView" {
            if let destination = segue.destination as? MissionDetailViewController,
                let index = missionTableView.indexPathForSelectedRow,
                let mission = missions?[index.row] {
                destination.mission = mission
            }
        }
    }

}

extension MissionOverviewTableViewController: RestApiControllerDelegate {
    
    func handleResponse(response: [Mission]) {
        missions = response
        missionTableView.reloadData()
    }
}
