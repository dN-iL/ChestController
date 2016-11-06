//
//  Mission.swift
//  ChestController
//
//  Created by Daniel on 31.10.16.
//  Copyright © 2016 Daniel. All rights reserved.
//

import Foundation

public class Mission {
    var id: String
    var name: String
    var participants: [Participant]?
    
    init(id: String, name: String, participants: [Participant]) {
        self.id = id
        self.name = name
        self.participants = participants
    }
}
