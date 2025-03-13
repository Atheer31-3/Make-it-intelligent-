////
////  Untitled.swift
////  ch6
////
////  Created by atheer alshareef on 04/03/2025.

import SwiftUI

struct ManageScreen: View {
    @State private var allergies: [String: Bool] = [
        "Milk": false,
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
    // ✅ لإغلاق الصفحة والعودة إلى الكاميرا
    @State private var searchText = ""

    init() {
        loadAllergies()
    }

    var body: some View {
        NavigationStack {
            VStack {

                // 🔍 شريط البحث
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
                    ForEach(filteredAllergies.keys.sorted(), id: \.self) { key in
                        HStack {
                            Text(key)
                            Spacer()
                            Image(systemName: allergies[key] ?? false ? "checkmark.square.fill" : "square")
                                .foregroundColor(.green2)
                                .onTapGesture {
                                    allergies[key]?.toggle()
                                    saveAllergies()
                                }
                        }
                        .contentShape(Rectangle())  // لجعل التفاعل أسهل عند النقر
                        .onTapGesture {
                            allergies[key]?.toggle()
                            saveAllergies()
                        }
                    }
                }
                .scrollContentBackground(.hidden)  // إخفاء الخلفية الافتراضية للقائمة
                .background(Color.white)  // تعيين الخلفية إلى الأبيض

                Button(action: {
                    saveAllergies()
                    presentationMode.wrappedValue.dismiss()  // ✅ إغلاق الصفحة بعد الحفظ
                }) {
                    Text("Save")
                        .frame(maxWidth: .infinity, maxHeight: 15)
                        .padding()
                        .background(LinearGradient(gradient: Gradient(colors: [Color.green1, Color.green2]), startPoint: .leading, endPoint: .trailing))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding()
                }
            }
            .onAppear {
                loadAllergies()
            }
        }
        .navigationTitle("Setting")
        .padding(.top,30)

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
        let selectedAllergies = allergies.filter { $0.value }.map { $0.key } // استخراج الحساسية المحددة فقط
        UserDefaults.standard.set(selectedAllergies, forKey: userDefaultsKey) // حفظها في UserDefaults
        
        NotificationCenter.default.post(name: NSNotification.Name("AllergiesUpdated"), object: nil) // إرسال إشعار بالتحديث
    }
    
    func loadAllergies() {
        if let savedAllergies = UserDefaults.standard.array(forKey: userDefaultsKey) as? [String] {
            for key in allergies.keys {
                allergies[key] = savedAllergies.contains(key) // تحديث القيم بناءً على البيانات المخزنة
            }
        }
    }
}

struct AllergySettingsView_Previews: PreviewProvider {
    static var previews: some View {
        ManageScreen()
    }
}
#Preview {
    ManageScreen()
}
