import SwiftUI

struct RateUsView: View {
    @State private var rating: Int = 0
    @State private var feedback: String = ""
    @State private var showThankYou: Bool = false
    @Environment(\.dismiss) var dismiss   // 👈 for going back
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Rate Bus Echo")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(Color(hex: "2A3B7F"))
                .padding(.top, 30)
            
            Text("We’d love to hear your feedback!")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            // MARK: - Star Rating
            HStack(spacing: 12) {
                ForEach(1...5, id: \.self) { index in
                    Image(systemName: index <= rating ? "star.fill" : "star")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 40, height: 40)
                        .foregroundColor(.yellow)
                        .onTapGesture {
                            rating = index
                        }
                }
            }
            .padding(.vertical, 10)
            
            // MARK: - Feedback Text Field
            TextEditor(text: $feedback)
                .frame(height: 150)
                .padding()
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 2)
                )
                .padding(.horizontal, 20)
            
            // MARK: - Submit Button
            Button(action: {
                submitFeedback()
            }) {
                Text("Submit")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(hex: "2A3B7F"))
                    .cornerRadius(12)
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)
            
            Spacer()
        }
        .padding()
        // MARK: - Popup Alert
        .alert("✅ Thank you for your feedback!", isPresented: $showThankYou) {
            Button("OK") {
                dismiss()  // 👈 go back after closing alert
            }
        }
    }
    
    // MARK: - API Call
    func submitFeedback() {
        guard let url = URL(string: API.Endpoints.rateApp) else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let body = "rating=\(rating)&feedback=\(feedback)"
        request.httpBody = body.data(using: .utf8)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Error:", error.localizedDescription)
                return
            }
            
            if let data = data {
                if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    print("✅ Response:", json)
                    DispatchQueue.main.async {
                        showThankYou = true   // 👈 show popup
                    }
                }
            }
        }.resume()
    }
}

#Preview {
    RateUsView()
}
