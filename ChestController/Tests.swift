//
//  Tests.swift
//  ChestController
//
//  Created by Daniel on 08.11.16.
//  Copyright © 2016 Daniel. All rights reserved.
//

enum Tests {
    case component
    case speed(numberOfCEs: Int, timeBetweenBursts: Int)
    
    internal func getName() -> String {
        switch self {
        case .component:
            return "Component Test"
        case .speed:
            return "Speed Test"
        }
    }
}
