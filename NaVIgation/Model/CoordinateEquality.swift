//
//  CoordinateEquality.swift
//  NaVIgation
//
//  Created by Tyler Sheft on 1/9/24.
//  Copyright © 2024 SheftApps. All rights reserved.
//

import MapKit

extension CLLocationCoordinate2D {
    
    static func ==(lCoord: CLLocationCoordinate2D, rCoord: CLLocationCoordinate2D) -> Bool {
        return lCoord.latitude == rCoord.latitude && lCoord.longitude == rCoord.longitude
    }
    
}
