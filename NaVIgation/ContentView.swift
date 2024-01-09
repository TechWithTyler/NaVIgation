//
//  ContentView.swift
//  NaVIgation
//
//  Created by Tyler Sheft on 1/4/24.
//  Copyright © 2024 SheftApps. All rights reserved.
//

import SwiftUI
import MapKit
import SheftAppsStylishUI

struct ContentView: View {
    
    var voice = AVSpeechSynthesizer()
    
    var initialPosition = MapCameraPosition.userLocation(followsHeading: true, fallback: .automatic)
    
    @AppStorage("mapStyle") var mapStyleSetting: Int = 0
    
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
    
    var body: some View {
        Map(initialPosition: initialPosition)
            .onAppear {
                speak(initialPosition.item?.name ?? "Unknown Location")
            }
            .onMapCameraChange(frequency: .onEnd) {
                speak(initialPosition.item?.name ?? "Unknown Location")
            }
            .mapStyle(mapStyle)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    OptionsMenu {
                        Picker(selection: $mapStyleSetting) {
                            Text("Standard").tag(0)
                            Text("Hybrid").tag(1)
                            Text("Satelite").tag(2)
                        } label: {
                            VStack {
                                Text("Map Style")
                                Text(currentMapStyleSettingTitle)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            }
    }
    
    func speak(_ message: String) {
        let utterance = AVSpeechUtterance(string: message)
        voice.stopSpeaking(at: .immediate)
        voice.speak(utterance)
    }
}

#Preview {
    ContentView()
}
