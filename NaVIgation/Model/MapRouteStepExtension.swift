//
//  MapRouteStepExtension.swift
//  NaVIgation
//
//  Created by Tyler Sheft on 1/18/24.
//

import MapKit

extension MKRoute.Step {
    
    var instructionsWithDistance: String {
        if distance > 0 {
            if distance > 1000 {
                let distanceInMiles = distance / 5280 // 1 mile = 5280 feet
                return "In \(distanceInMiles)mi, \(instructions)"
            } else {
                return "In \(distance)ft, \(instructions)"
            }
        } else {
            return instructions
        }
    }
    
}
