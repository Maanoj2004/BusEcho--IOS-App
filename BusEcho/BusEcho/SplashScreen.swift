import SwiftUI

struct SplashScreenView: View {
    @State private var showTitle = false
    @State private var starIndex = 0
    @State private var showTagline = false
    @State private var logoOffset: CGFloat = -150   // start off to the left
    @State private var logoScale: CGFloat = 0.3     // start small
    
    let starCount = 5
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Logo moving and scaling at the same time
                Image("Logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 250, height: 250)
                    .offset(x: logoOffset)
                    .scaleEffect(logoScale)
                    .animation(.easeOut(duration: 1), value: logoOffset)
                    .animation(.easeOut(duration: 1), value: logoScale)

                HStack(spacing: 0) {
                    Text("Bus")
                        .font(.system(size: 45, weight: .bold))
                        .foregroundColor(Color.blue)
                    Text(" Echo")
                        .font(.system(size: 45, weight: .bold))
                        .foregroundStyle(
                            LinearGradient(colors: [.blue, .teal],
                                           startPoint: .leading,
                                           endPoint: .trailing)
                        )
                }
                .opacity(showTitle ? 1 : 0)
                .animation(.easeIn(duration: 1), value: showTitle)
                
                Spacer()
                
                HStack(spacing: 4) {
                    ForEach(0..<starCount, id: \.self) { index in
                        Image(systemName: "star.fill")
                            .foregroundColor(index == 2 ? .yellow : .gray)
                            .opacity(starIndex == index ? 1 : 0.3)
                            .animation(.easeInOut(duration: 0.3), value: starIndex)
                    }
                }
                .padding(.top, 8)
                
                Text("Your voice for better journeys")
                    .font(.footnote)
                    .foregroundColor(.black)
                    .opacity(showTagline ? 1 : 0)
                    .animation(.easeIn(duration: 1).delay(2), value: showTagline)
            }
            .padding(30)
        }
        .onAppear {
            // 🟡 Move logo from left to center and scale up
            logoOffset = 0
            logoScale  = 1.0

            showTitle = true
            
            Timer.scheduledTimer(withTimeInterval: 0.4, repeats: true) { _ in
                starIndex = (starIndex + 1) % starCount
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                showTagline = true
            }
        }
    }
}

#Preview {
    SplashScreenView()
}
