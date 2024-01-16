//
//  AddLandmarkView.swift
//  NaVIgation
//
//  Created by Tyler Sheft on 1/9/24.
//

import SheftAppsStylishUI
import SwiftUI
import MapKit
import Contacts

struct AddLandmarkView: View {
    
    @EnvironmentObject var gps: GPS
    
    @State var name: String = String()
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
                Form {
                    List {
                        FormTextField("Name", text: $name)
                        HStack {
                            Text("Country")
                            Text(gps.country)
                        }
                        HStack {
                            Text("State/Province/Region")
                            Text(gps.region)
                        }
                        HStack {
                            Text("City")
                            Text(gps.city)
                        }
                        HStack {
                            Text("Street/Number")
                            Text(gps.addressAndStreet)
                        }
                    }
                    Button("Save") {
                        gps.saveCurrentPositionAsLandmark(name: name)
                    }
                }
        }
        .onAppear {
            
        }
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel", role: .cancel) {
                    dismiss()
                }
            }
        }
    }
    
}

#Preview {
    AddLandmarkView()
}
