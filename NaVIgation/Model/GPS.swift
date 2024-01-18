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
    
    func fetchVoices() {
        voices = []
        AVSpeechSynthesizer.requestPersonalVoiceAuthorization { [self] status in
            let installedVoices = AVSpeechSynthesisVoice.speechVoices().filter({$0.language == "en-US"})
                for voice in installedVoices {
                    voices.append(voice)
                }
            voices.sort { $1.name > $0.name }
        }
    }
    
    @Published var voices: [AVSpeechSynthesisVoice] = []
    
    @AppStorage("selectedVoiceID") var selectedVoiceID = "com.apple.eloquence.en-US.Reed"
    
    var locationManager: CLLocationManager?
    
    var coordinate = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    
    @Published var position = MapCameraPosition.automatic
    
    @Published var selectedResult: MKMapItem?
    
    @Published var route: MKRoute?
    
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
    
    @Published var showingSettings: Bool = false
    
    var gpsText: String = String()
    
    var heading: Double = 0
    
    let startingPoint = CLLocationCoordinate2D(latitude: 35.59686103777399, longitude: -82.54773673862036
    )
    
    let endingPoint = CLLocationCoordinate2D(
        latitude: 35.60490413968361,
        longitude: -82.55308112914025
    )
    
    var travelTime: String? {
            // Check if there is a route to get the info from
            guard let route else { return nil }
        
            // Set up a date formater
            let formatter = DateComponentsFormatter()
            formatter.unitsStyle = .abbreviated
            formatter.allowedUnits = [.hour, .minute]
        
            // Format the travel time to the format you want to display it
            return formatter.string(from: route.expectedTravelTime)
        }
    
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
    
    func getDirections() {
        route = nil
        
        // Check if there is a selected result
        guard let selectedResult = selectedResult else { return }
        
        // Coordinate to use as a starting point for the example
        let startingPoint = self.startingPoint
        
        // Create and configure the request
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: startingPoint))
        request.destination = selectedResult
        
        // Get the directions based on the request
        Task {
            let directions = MKDirections(request: request)
            let response = try? await directions.calculate()
            route = response?.routes.first
            let firstStep = route?.steps.first
            gpsText = firstStep?.instructions ?? "No first step on route"
            speak(gpsText)
        }
    }
    
    func mapItem(forCoordinate coordinate: CLLocationCoordinate2D) -> MKMapItem {
        return MKMapItem(placemark: MKPlacemark(coordinate: coordinate))
    }
    
    func saveCurrentPositionAsLandmark(name: String) {
        let landmark = Location(name: name, coordinate: coordinate, country: country, stateProvinceRegion: region, city: city, street: addressAndStreet)
        locations.append(landmark)
    }
    
    func speak(_ message: String) {
        let utterance = AVSpeechUtterance(string: message)
        utterance.voice = AVSpeechSynthesisVoice(identifier: selectedVoiceID)
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
    
    func updateWhereAmI(heading: Double, coordinate: CLLocationCoordinate2D) {
        self.heading = heading
        self.coordinate = coordinate
        // Code to update the where am I information
        print("Heading: \(heading)")
        print("Coordinate: \(coordinate)")
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
