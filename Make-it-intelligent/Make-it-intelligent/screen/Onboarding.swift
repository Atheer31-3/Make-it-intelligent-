//
//  Onboarding.swift
//  LiveTextDemo
//
//  Created by Raneem on 15/09/1446 AH.
//

import SwiftUI

// Custom Page Indicator
struct CustomPageIndicator: View {
    var currentPage: Int
    var totalPages: Int
    var onPageTap: (Int) -> Void

    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<totalPages, id: \.self) { index in
                RoundedRectangle(cornerRadius: 5)
                    .fill(index == currentPage ? Color.pink : Color.gray.opacity(0.5))
                    .frame(width: 10, height: 10)
                    .onTapGesture {
                        onPageTap(index)
                    }
            }
        }
        .padding(.bottom, 20)
    }
}

// Onboarding Pages
struct OnboardingPage: View {
    var title: String
    var description: String
    var imageName: String

    var body: some View {
      VStack {
            Image(imageName)
                .resizable()
                .scaledToFit()
                .frame(width: 300, height: 300)
                .padding(.top, 50)

            VStack(alignment: .leading, spacing: 8) {
                Rectangle()
                    .fill(Color("green2"))
                    .frame(width: 35, height: 6)
                    .cornerRadius(10)
                    .padding(.bottom, 10)

                Text(title)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity, alignment: .leading) // ضبط المحاذاة لليسار

                Text(description)
                    .font(.system(size: 16))
                    .foregroundColor(.black)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading) // ضبط المحاذاة لليسار
                    .padding(.bottom, 10)
            }
            .padding(.horizontal, 20) // ضبط الهوامش
            .padding(.top, 80)
            .frame(maxWidth: .infinity, alignment: .leading) // تأكد من أن كل المحتوى محاذٍ لليسار
        }}
}

// Onboarding View
struct OnboardingView: View {
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding: Bool = false
    @State private var currentPage = 0

    var body: some View {
        VStack {
            // Skip button
            Button(action: {
                hasSeenOnboarding = true
            }) {
                Text("Skip")
                    .foregroundColor(Color("green2"))
                    .padding(.top, 20)
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
            .padding(.trailing, 20)

            // TabView for onboarding pages
            TabView(selection: $currentPage) {
                OnboardingPage(title: "Avoid reacting ",
                               description: "Check if your food are safe ",
                               imageName: "Image2").tag(0)
                OnboardingPage(title: "Safety with one touch",
                               description: "Easily scan food product ingredients and detect allergens.",
                               imageName: "Image").tag(1)
                OnboardingPage(title: "Packaged products",
                               description: "Scan the ingredient label.",
                               imageName: "Image1").tag(2)
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))

            // Custom Page Indicator
            CustomPageIndicator(currentPage: currentPage, totalPages: 3) { newIndex in
                currentPage = newIndex
            }

            // Action Button
            Button(action: {
                if currentPage < 2 { // Navigate to next page
                    currentPage += 1
                } else {
                    hasSeenOnboarding = true // ✅ حفظ الحالة عند الانتهاء
                }
            }) {
                Text(currentPage == 2 ? "Get Started" : "Continue")
                    .padding()
                    .frame(width: 350, height: 50)
                    .background(
                        LinearGradient(gradient: Gradient(colors: [Color("green1"), Color("green2")]),startPoint: .leading,endPoint: .trailing)
                    )
                    .foregroundColor(.white)
                    .cornerRadius(15)
            }
            .padding(.bottom, 50)
        }
        .background(Color.white.opacity(0.3).edgesIgnoringSafeArea(.all))
    }
}
