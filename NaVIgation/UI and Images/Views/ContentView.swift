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
            VStack {
                Map(selection: $gps.selectedResult) {
                    Marker("Start", coordinate: gps.startingPoint)
                    Marker("End", coordinate: gps.endingPoint)
                        .tag(gps.mapItem(forCoordinate: gps.endingPoint))
                    
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
                    MapUserLocationButton(scope: mapScope)
                }
                .onChange(of: gps.selectedResult) {
                    gps.speak(gps.selectedResult?.name ?? "No name")
                    gps.getDirections()
                }
                VStack {
                    Text(gps.gpsText)
                        .onTapGesture {
                            gps.speak(gps.gpsText)
                        }
                    if let steps = gps.route?.steps {
                        TabView {
                            ForEach(steps, id: \.self) { step in
                                Text(step.instructionsWithDistance)
                                    .onTapGesture {
                                        gps.speak(step.instructionsWithDistance)
                                    }
                                    .tabItem {
                                        Text("\(step.distance)").tag(step)
                                    }
                            }
                        }
                        .tabViewStyle(.page)
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
                        Button {
                            gps.showingSettings = true
                        } label: {
                            Label("Settings…", systemImage: "gear")
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
        .sheet(isPresented: $gps.showingSettings) {
            SettingsView()
        }
    }
    
}

#Preview {
    ContentView()
}
