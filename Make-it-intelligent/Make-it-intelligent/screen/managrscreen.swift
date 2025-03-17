import SwiftUI
import VisionKit
import AVFoundation
import UIKit

struct ManageScreen: View {
    var onDismiss: (() -> Void)? // جعل onDismiss اختيارياً

    @State private var allergies: [String: Bool] = [
        "Dairy Product": false,
        "Egg": false,
        "Fish": false,
        "Soybean": false,
        "Corn": false,
        "Gluten": false,
        "Peanut Butter": false,
        "Wheat": false,
        "Yeast": false,
        "Banana": false,
        "Tomato": false,
    ]
    let userDefaultsKey = "SelectedAllergies"
    
    @Environment(\.presentationMode) var presentationMode
    
    @State private var searchText = ""

    init() {
        loadAllergies()
    }
    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)

                        TextField("Search", text: $searchText)
                            .padding(10)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                            .onChange(of: searchText) { _ in
                                searchAllergies()
                            }
                    }
                    if !searchText.isEmpty {
                        Button(action: {
                            searchText = ""
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray)
                        }
                    }
                }
                .padding(.horizontal)
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding(.horizontal)
               
                List {
                    ForEach(filteredAllergies.keys.sorted(), id: \..self) { key in
                        HStack {
                            Text(key)
                            Spacer()
                            Image(systemName: allergies[key] ?? false ? "checkmark.square.fill" : "square")
                                .foregroundColor(Color("green2"))
                                .onTapGesture {
                                    allergies[key]?.toggle()
                                    saveAllergies()
                                }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            allergies[key]?.toggle()
                            saveAllergies()
                        }
                    }
                }
                .scrollContentBackground(.hidden)  // إخفاء الخلفية الافتراضية للقائمة
                .background(Color.white)  // تعيين الخلفية إلى الأبيض

                
                
                Button(action: {
                    let selectedAllergies = allergies.filter { $0.value }.map { $0.key }
                        print("Selected Allergies: \(selectedAllergies)") // Print selected allergies
                    
                    saveAllergies()
//                    onDismiss?()
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Save")
                        .frame(maxWidth: .infinity, maxHeight: 15)
                        .padding()
                        .background(LinearGradient(gradient: Gradient(colors: [Color("green1"), Color("green2")]), startPoint: .leading, endPoint: .trailing))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding()
                }
            }
        }
        .navigationTitle("Settings")
        .onAppear {
            loadAllergies()
        }
    }
    
    var filteredAllergies: [String: Bool] {
        if searchText.isEmpty {
            return allergies
        } else {
            return allergies.filter { $0.key.lowercased().contains(searchText.lowercased()) }
        }
    }
    func searchAllergies() {
        // يتم تصفية القائمة تلقائيًا عبر `filteredAllergies`
    }
    func saveAllergies() {
        let selectedAllergies = allergies.filter { $0.value }.map { $0.key }
        UserDefaults.standard.set(selectedAllergies, forKey: userDefaultsKey)
//        UserDefaults.standard.set(true, forKey: "hasSetAllergies")
        UserDefaults.standard.set(!selectedAllergies.isEmpty, forKey: "hasSetAllergies")
        NotificationCenter.default.post(name: NSNotification.Name("AllergiesUpdated"), object: nil)
        print("in manga class: Saved Allergies: \(selectedAllergies)")
    }

    
    func loadAllergies() {
        if let savedAllergies = UserDefaults.standard.array(forKey: userDefaultsKey) as? [String] {
            for key in allergies.keys {
                allergies[key] = savedAllergies.contains(key)
            }
        }
    }
}
#Preview {
    ManageScreen()
}
