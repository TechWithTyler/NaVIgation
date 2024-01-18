//
//  SettingsView.swift
//  NaVIgation
//
//  Created by Tyler Sheft on 1/18/24.
//

import SwiftUI
import Speech

struct SettingsView: View {
    
    @EnvironmentObject var gps: GPS
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            Form {
                Picker("Voice", selection: $gps.selectedVoiceID) {
                    ForEach(gps.voices, id: \.self) {
                        voice in
                        VStack(alignment: .leading) {
                            Text(voice.name)
                            if voice.voiceTraits.contains(.isPersonalVoice) {
                                Text("Personal voice")
                                    .foregroundStyle(.secondary)
                            } else {
                                Text("System voice")
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .tag(voice.identifier)
                    }
                }
                .pickerStyle(.navigationLink)
                .onChange(of: gps.selectedVoiceID) {
                    gps.speak("Turn right onto Main Street.")
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                gps.fetchVoices()
            }
            .onReceive(NotificationCenter.default.publisher(for: AVSpeechSynthesizer.availableVoicesDidChangeNotification)) { output in
                gps.fetchVoices()
            }
        }
    }
}

#Preview {
    SettingsView()
}
