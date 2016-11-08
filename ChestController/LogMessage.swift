//
//  LogMessage.swift
//  ChestController
//
//  Created by Daniel on 05.11.16.
//  Copyright © 2016 Daniel. All rights reserved.
//

enum Events {
    case Start
    case End
    
    internal func getEvent() -> String {
        switch self {
        case .Start:
            return "start"
        case .End:
            return "end"
        }
    }
}

class LogMessage {
    
    var test: Tests
    var event: String
    
    init(test: Tests, event: Events) {
        self.test = test
        self.event = event.getEvent()
    }
}
