//
//  Location.swift
//  NaVIgation
//
//  Created by Tyler Sheft on 1/9/24.
//

import Foundation
import MapKit

struct Location: Identifiable {
    
    let id = UUID()
    
    var name: String
    
    var isLandmark: Bool = false
    
    var coordinate: CLLocationCoordinate2D
    
    var country: String
    
    var stateProvinceRegion: String
    
    var city: String
    
    var street: String
    
}
