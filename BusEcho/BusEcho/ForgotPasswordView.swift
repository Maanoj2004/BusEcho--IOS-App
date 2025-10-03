import SwiftUI

struct ForgotPasswordView: View {
    @State private var email = ""
    @State private var sentOTP: String?
    @State private var enteredOTP = ""
    @State private var showOTPField = false
    @State private var successMessage = ""
    @State private var errorMessage = ""
    @State private var isSending = false
    @State private var isVerifying = false
    
    @EnvironmentObject private var appState: AppState
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Forgot Password")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top,20)

            TextField("Enter your registered email", text: $email)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)

            // MARK: - Send OTP
            Button(action: {
                guard !email.trimmingCharacters(in: .whitespaces).isEmpty else {
                    errorMessage = "Please enter your registered email"
                    successMessage = ""
                    return
                }
                errorMessage = ""
                successMessage = ""
                isSending = true
                sendOTP(to: email)
            }) {
                if isSending {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                } else {
                    Text("Send OTP")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }
            }
            .disabled(isSending)

            // MARK: - OTP Verification
            if showOTPField {
                TextField("Enter OTP", text: $enteredOTP)
                    .keyboardType(.numberPad)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)

                Button(action: {
                    isVerifying = true
                    verifyOTP()
                }) {
                    if isVerifying {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .cornerRadius(10)
                    } else {
                        Text("Verify OTP")
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .cornerRadius(10)
                    }
                }
                .disabled(isVerifying)
            }

            if !successMessage.isEmpty {
                Text(successMessage)
                    .foregroundColor(.green)
                    .font(.subheadline)
            }

            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.subheadline)
            }

            Spacer()
        }
        .padding(.horizontal,40)
    }

    // MARK: - Helpers
    func sendOTP(to email: String) {
        guard let url = URL(string: API.Endpoints.forgotPassword) else {
            errorMessage = "Invalid server URL"
            isSending = false
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let bodyData = "email=\(email)"
        request.httpBody = bodyData.data(using: .utf8)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        URLSession.shared.dataTask(with: request) { data, _, error in
            DispatchQueue.main.async {
                isSending = false
                if let error = error {
                    errorMessage = "Network error: \(error.localizedDescription)"
                    return
                }

                guard let data = data else {
                    errorMessage = "No data received"
                    return
                }

                do {
                    let decoded = try JSONDecoder().decode(OTPResponse.self, from: data)
                    if decoded.status == "success" {
                        sentOTP = decoded.otp
                        showOTPField = true
                        errorMessage = ""
                        successMessage = "OTP sent to \(email)"
                    } else {
                        errorMessage = decoded.message ?? "Failed to send OTP"
                        successMessage = ""
                    }
                } catch {
                    errorMessage = "Decoding error"
                }
            }
        }.resume()
    }

    func verifyOTP() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { // simulate small delay
            if enteredOTP == sentOTP {
                successMessage = "OTP verified! Redirecting to reset page..."
                errorMessage = ""
                appState.emailForReset = email
                appState.rootViewState = .resetPassword
            } else {
                errorMessage = "Incorrect OTP"
                successMessage = ""
            }
            isVerifying = false
        }
    }
}

struct OTPResponse: Codable {
    let status: String
    let message: String?
    let otp: String?
}
