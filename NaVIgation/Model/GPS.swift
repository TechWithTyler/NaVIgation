//
//  GPS.swift
//  NaVIgation
//
//  Created by Tyler Sheft on 1/9/24.
//  Copyright © 2024 SheftApps. All rights reserved.
//

import SwiftUI
import MapKit
import SheftAppsStylishUI

class GPS: NSObject, ObservableObject, CLLocationManagerDelegate {
    
    var voice = AVSpeechSynthesizer()
    
    var locationManager: CLLocationManager?
    
    var coordinate = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    
    let geocoder = CLGeocoder()
    
    @Published var position = MapCameraPosition.automatic
    
    var country = String()
    
    var region = String()
    
     var city = String()
    
    var addressAndStreet = String()
    
    var locations = [
        Location(name: "Apple Corte Madera", coordinate: CLLocationCoordinate2D(latitude: 37.92557, longitude: 122.52765), country: "United States", stateProvinceRegion: "California", city: "Corte Madera", street: "1520 Redwood Highway"),
        Location(name: "Apple Park", coordinate: CLLocationCoordinate2D(latitude: 37.3346, longitude: -122.009102), country: "United States", stateProvinceRegion: "California", city: "Cupertino", street: "One Apple Park Way")
    ]
    
    @AppStorage("mapStyle") var mapStyleSetting: Int = 0
    
    @Published var showingAddLandmark: Bool = false
    
    var gpsText: String = String()
    
    var heading: Double = 0
    
    var currentMapStyleSettingTitle: String {
        switch mapStyleSetting {
        case 1:
            return "Hybrid"
        case 2:
            return "Satelite"
        default:
            return "Standard"
        }
    }
    
    var mapStyle: MapStyle {
        switch mapStyleSetting {
        case 1:
            return .hybrid
        case 2:
            return .imagery(elevation: .automatic)
        default:
            return .standard
        }
    }
    
    var headingDirection: String {
        let directions = ["North", "North-East", "East", "South-East", "South", "South-West", "West", "North-West"]
        if heading < 0 {
            return directions.first! // Handle invalid headings
        }
        let index = Int((heading + 22.5) / 45.0) & 7 // Map heading to 0-7 for cardinal directions
        return directions[index]
    }

    var whereAmI: String {
        // Street/address not available
        if addressAndStreet.isEmpty && city.isEmpty && region.isEmpty && country.isEmpty {
            return "Heading \(headingDirection). No location available."
        } else if addressAndStreet.isEmpty {
            return "Heading \(headingDirection). In open area, \(city), \(region), \(country)"
        } else if let firstAddressComponent = addressAndStreet.components(separatedBy: .whitespaces).first?.components(separatedBy: "-").first, !firstAddressComponent.allSatisfy({$0.isNumber}) {
            // Address not available
            return "Heading \(headingDirection). On \(addressAndStreet), \(city), \(region), \(country)."
        } else {
            // Everything available
            return "Heading \(headingDirection). Near \(addressAndStreet), \(city), \(region), \(country)."
        }
    }
    
    func saveCurrentPositionAsLandmark(name: String) {
        let landmark = Location(name: name, coordinate: coordinate, country: country, stateProvinceRegion: region, city: city, street: addressAndStreet)
        locations.append(landmark)
    }
    
    func speak(_ message: String) {
        let utterance = AVSpeechUtterance(string: message)
        voice.stopSpeaking(at: .immediate)
        voice.speak(utterance)
    }
    
    func checkIfLocationServicesIsEnabled(){
            locationManager = CLLocationManager()
            locationManager?.delegate = self
            locationManager?.requestWhenInUseAuthorization()
        locationManager?.requestLocation()
    }
    
    private func checkLocationAuthorization(){
        guard let locationManager = locationManager else {
            return
        }
        switch locationManager.authorizationStatus{
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            gpsText = "Your location is restricted likely due to parental controls."
        case .denied:
            gpsText = "You have denied this app location permission. Go into settings to change it."
        case .authorizedAlways:
            getCurrentLocation()
        case .authorizedWhenInUse:
            getCurrentLocation()
        @unknown default:
            break
        }
    }
    
    func getCurrentLocation() {
        position = MapCameraPosition.userLocation(followsHeading: true, fallback: .automatic)
    }
    
    func updateWhereAmI(heading: Double, coordinate: CLLocationCoordinate2D, distance: Double) {
        self.heading = heading
        self.coordinate = coordinate
        if distance >= 1000 {
            getAddressFromCoordinates(coordinate: coordinate)
        }
    }
    
    func getAddressFromCoordinates(coordinate: CLLocationCoordinate2D) {
        let latitude = coordinate.latitude
        let longitude = coordinate.longitude
        let currentLocation = CLLocation(latitude: latitude, longitude: longitude)
        gpsText = whereAmI
        country.removeAll()
        region.removeAll()
        city.removeAll()
        addressAndStreet.removeAll()
        guard !geocoder.isGeocoding else {
            gpsText = "Unable to convert coordinates to address right now. Try again later."
            return }
        geocoder.reverseGeocodeLocation(currentLocation) { [self] (places, error) in
            if let error = error {
                gpsText = error.localizedDescription
            } else {
                if let places = places, let firstPlace = places.first, let placeAddress = firstPlace.postalAddress {
                        country = placeAddress.country
                        region = placeAddress.state
                        city = placeAddress.city
                        addressAndStreet = placeAddress.street
                        gpsText = whereAmI
                    }
                }
            }
    }
    
    func speakWhereAmI() {
        speak(whereAmI)
    }
    
}

extension GPS {
    
    // MARK: - Location Manager Delegate
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("Did update locations")
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        speak(error.localizedDescription)
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        print("Location authorization did change")
        manager.requestAlwaysAuthorization()
    }
    
}
