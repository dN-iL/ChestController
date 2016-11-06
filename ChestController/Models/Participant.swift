//
//  Participant.swift
//  ChestController
//
//  Created by Daniel on 31.10.16.
//  Copyright © 2016 Daniel. All rights reserved.
//

import Foundation

public class Participant {
    var name: String?
    var id: String
    
    init(id: String, name: String?) {
        self.id = id
        if let name = name {
            self.name = name
        }
    }
}
