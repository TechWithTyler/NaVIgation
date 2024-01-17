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
    
    @EnvironmentObject var gps: GPS
    
    @Namespace var mapScope

    var body: some View {
        NavigationStack {
            TranslucentFooterVStack {
                Map(selection: $gps.selectedResult) {
                    Marker("Start", coordinate: gps.startingPoint)
                    
                    ForEach(gps.locations) { location in
                        Marker(location.name, systemImage: "house", coordinate: location.coordinate)
                    }
                    
                    // Show the route if it is available
                    if let route = gps.route {
                        MapPolyline(route)
                            .stroke(.blue, lineWidth: 5)
                    }
                }
                .mapScope(mapScope)
                .mapStyle(gps.mapStyle)
                .mapControls {
                    MapCompass(scope: mapScope)
                    MapPitchSlider(scope: mapScope)
                    MapUserLocationButton(scope: mapScope)
                }
            } translucentFooterContent: {
                VStack {
                    Text(gps.selectedResult?.description ?? "Error")
                        .onTapGesture {
                            gps.speak(gps.selectedResult?.description ?? "Error")
                        }
                    Text(gps.gpsText)
                        .onTapGesture {
                            gps.speak(gps.gpsText)
                        }
                    if let steps = gps.route?.steps {
                        List {
                            ForEach(steps, id: \.self) { step in
                                Text(step.instructions)
                                    .onTapGesture {
                                        gps.speak(step.instructions)
                                    }
                            }
                        }
                    } else {
                        Text("No route")
                    }
                }
                .padding()
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    OptionsMenu {
                        Button {
                            gps.speakWhereAmI()
                        } label: {
                            Label("Where Am I?", systemImage: "mappin.circle.fill")
                        }
                        Button {
                            gps.showingAddLandmark = true
                        } label: {
                            Label("Add Landmark…", systemImage: "plus")
                        }
                        Picker(selection: $gps.mapStyleSetting) {
                            Text("Standard").tag(0)
                            Text("Hybrid").tag(1)
                            Text("Satelite").tag(2)
                        } label: {
                            VStack {
                                Text("Map Style")
                                Text(gps.currentMapStyleSettingTitle)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            }
        }
    .sheet(isPresented: $gps.showingAddLandmark) {
        AddLandmarkView()
    }
        .onChange(of: gps.selectedResult) {
            gps.getDirections()
                }
    }

}

#Preview {
    ContentView()
}
