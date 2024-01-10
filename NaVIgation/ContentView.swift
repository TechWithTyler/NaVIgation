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
                Map(position: $gps.position, scope: mapScope) {
                    UserAnnotation()
                    ForEach(gps.locations) { location in
                        Marker(location.name, coordinate: location.coordinate)
                            .foregroundStyle(location.isLandmark ? .red : .gray)
                    }
                }
                .mapControls {
                    MapUserLocationButton(scope: mapScope)
                    MapCompass(scope: mapScope)
                }
                .onAppear {
                    gps.checkIfLocationServicesIsEnabled()
                }
            } translucentFooterContent: {
                Text(gps.gpsText)
                    .font(.callout)
                    .padding()
            }
            .mapScope(mapScope)
            .onMapCameraChange(frequency: .onEnd) { context in
                let coordinate = context.camera.centerCoordinate
                let heading = context.camera.heading
                let distance = context.camera.distance
                gps.updateWhereAmI(heading: heading, coordinate: coordinate, distance: distance)
            }
            .mapStyle(gps.mapStyle)
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
    }
    
}

#Preview {
    ContentView()
}
