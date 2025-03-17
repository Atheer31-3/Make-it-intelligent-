//
//  Make_it_intelligentApp.swift
//  Make-it-intelligent
//
//  Created by atheer alshareef on 26/02/2025.
//

import SwiftUI
import AVFoundation
import Vision
import CoreML
@main
struct Make_it_intelligentApp: App {
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding: Bool = false
    
    var body: some Scene {
        
        WindowGroup {
//            tst()
            if hasSeenOnboarding {
                ContentView()
            } else {
                OnboardingView()
            }
        }
    }
}
