//
//  NaVIgationApp.swift
//  NaVIgation
//
//  Created by Tyler Sheft on 1/4/24.
//  Copyright © 2024 SheftApps. All rights reserved.
//

import SwiftUI

@main
struct NaVIgationApp: App {
    
    @ObservedObject var gps: GPS = GPS()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(gps)
        }
    }
}
