import AVFoundation
import SwiftUI
import SwiftUICore
import Vision

struct CameraView: View {
    @State private var showManageAllergies = false
    @State private var allergiesSet = false
    @State private var showAllergyWarning = false
    @State private var recognizedText: String = ""  // Holds recognized text from OCR
    @State private var scanResult: String = ""
    @State private var selectedLanguage = "en"
    let allergyModel = AllergyModel()

    var body: some View {
        NavigationStack {
            ZStack {

                VStack {
                    // Top buttons (setting & languages)
                    HStack {
                        // Setting button
                        NavigationLink(destination: ManageScreen()) {
                            Image(systemName: "gearshape.fill")
                                .resizable()
                                .frame(width: 30, height: 30)
                                .padding()
                                .background(Color.white.opacity(0.8))
                                .cornerRadius(10)
                                .shadow(radius: 5)
                        }

                        Spacer()

                        // Languages button
                        Button(action: {
                            selectedLanguage = (selectedLanguage == "en") ? "ar" : "en"
                        }) {
                            Text(selectedLanguage == "en" ? "🇬🇧 EN" : "🇸🇦 AR")
                                .padding()
                                .background(Color.white.opacity(0.8))
                                .cornerRadius(10)
                                .shadow(radius: 5)
                        }
                    }
                    .padding()

                    Spacer()

                    // Show this if user didn't select their allergies
                    if allergiesSet {
                        AllergyWarningView(showManageAllergies: $showManageAllergies)
                    }

                    // Display recognized text
                    if !recognizedText.isEmpty {
                        Text("Recognized Text:")
                            .font(.headline)
                        ScrollView {
                            Text(recognizedText)  // Display the OCR recognized text
                                .padding()
                                .background(Color.white)
                                .cornerRadius(10)
                                .shadow(radius: 5)
                                .padding()
                        }
                    }

                    Spacer()
                }
            }
            .onAppear {
                checkUserAllergies()
            }
//            .fullScreenCover(isPresented: $showManageAllergies) {
//                ManageScreen()
//            }
        }
    }

    func checkUserAllergies() {
        if let savedAllergies = UserDefaults.standard.dictionary(forKey: "SelectedAllergies") as? [String: Bool] {
            allergiesSet = savedAllergies.values.contains(true)
        }
        showAllergyWarning = !allergiesSet
    }
}

// MARK: If user didn't select their allergies
struct AllergyWarningView: View {
    @Binding var showManageAllergies: Bool

    var body: some View {
        VStack {
            Image(systemName: "magnifyingglass.circle.fill")
                .resizable()
                .frame(width: 80, height: 80)
                .foregroundColor(.gray.opacity(0.6))
                .padding(.bottom, 20)

            Text("Your allergies are not set yet.")
                .font(.headline)
                .foregroundColor(.black)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Text("Go to settings to customize your allergies")
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.bottom, 20)

            NavigationLink(destination: ManageScreen()) {
                Text("Go to Settings")
                    .frame(maxWidth: .infinity, maxHeight: 15)
                    .padding()
                    .background(LinearGradient(gradient: Gradient(colors: [Color.green1, Color.green2]), startPoint: .leading, endPoint: .trailing))
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding()
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.white.opacity(0.9))
        .cornerRadius(20)
        .shadow(radius: 10)
        .padding(.horizontal, 20)
    }
}

#Preview {
    CameraView()
}
