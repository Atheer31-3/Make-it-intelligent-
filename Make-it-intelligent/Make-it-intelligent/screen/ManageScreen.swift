//
//  ManageScreen.swift
//  Make-it-intelligent
//
//  Created by Raghad Altalhi on 02/09/1446 AH.
//


/*
import SwiftUI

struct ManageScreen: View {
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

 */
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
        "Tomato": false
    ]
    
    let userDefaultsKey = "SelectedAllergies"

    init() {
        loadAllergies()
    }

    var body: some View {
        VStack {
            Image("manage")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 50)
                
            Text("Manage")
                .font(.title)
                .bold()
            
            SearchBar()
            
            List {
                ForEach(allergies.keys.sorted(), id: \.self) { key in
                    HStack {
                        Text(key)
                        Spacer()
                        Image(systemName: allergies[key] ?? false ? "checkmark.square.fill" : "square")
                            .foregroundColor(.green)
                            .onTapGesture {
                                allergies[key]?.toggle()
                                saveAllergies()
                            }
                    }
                    .contentShape(Rectangle()) // لجعل التفاعل أسهل عند النقر
                    .onTapGesture {
                        allergies[key]?.toggle()
                        saveAllergies()
                    }
                }
            }
            
            .scrollContentBackground(.hidden) // إخفاء الخلفية الافتراضية للقائمة
                       .background(Color.white) // تعيين الخلفية إلى الأبيض
                       
            
            Button(action: {
                saveAllergies()
            }) {
                Text("Save")
                    .frame(width: 300, height: 15)
                    .padding()
                    .background(LinearGradient(gradient: Gradient(colors: [Color.green2, Color.green1]), startPoint: .leading, endPoint: .trailing))
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding()
            }
        }
        .onAppear {
            loadAllergies()
        }
        .background(Color.white) // تعيين الخلفية البيضاء للشاشة بأكملها
    }

    func saveAllergies() {
        UserDefaults.standard.setValue(allergies, forKey: userDefaultsKey)
    }

    func loadAllergies() {
        if let savedData = UserDefaults.standard.dictionary(forKey: userDefaultsKey) as? [String: Bool] {
            allergies = savedData
        }
    }
}

struct SearchBar: View {
    @State private var searchText = ""

    var body: some View {
        TextField("Search", text: $searchText)
            .padding(10)
            .background(Color(.systemGray6))
            .frame(width: 330, height: 40)
            .cornerRadius(8)
            .padding(.horizontal)
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
