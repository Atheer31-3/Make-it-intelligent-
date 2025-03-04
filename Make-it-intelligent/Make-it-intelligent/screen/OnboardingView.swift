
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

            Text(title)
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top, 20)

            Text(description)
                .font(.body)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
                .padding(.top, 10)

            Spacer()
        }
        .foregroundColor(.black)
    }
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
                    .foregroundColor(.pink)
                    .padding(.top, 20)
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
            .padding(.trailing, 20)

            // TabView for onboarding pages
            TabView(selection: $currentPage) {
                OnboardingPage(title: "AI Chat Assistant",
                               description: "Chat with the smartest AI. Experience the power of AI + you.",
                               imageName: "Image1").tag(0)
                OnboardingPage(title: "Generate Stunning Visuals",
                               description: "Transform your ideas into stunning visuals with AI-powered image generation.",
                               imageName: "Image1").tag(1)
                OnboardingPage(title: "Voice to Transcript",
                               description: "Convert your voice to text instantly with our accurate transcription tool.",
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
                        LinearGradient(gradient: Gradient(colors: [Color.green1, Color.green2]), startPoint: .leading, endPoint: .trailing)
                    )
                    .foregroundColor(.white)
                    .cornerRadius(15)
            }
            .padding(.bottom, 50)
        }
        .background(Color.white.opacity(0.3).edgesIgnoringSafeArea(.all))
    }
}


