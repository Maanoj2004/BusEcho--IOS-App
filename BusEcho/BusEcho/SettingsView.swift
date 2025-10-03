import SwiftUI

// MARK: - Settings View
struct SettingsView: View {
    @EnvironmentObject var appState: AppState
    @AppStorage("storedUserID") var storedUserID: Int? {
        didSet { appState.storedUserID = storedUserID }
    }
    @State private var delete: Bool = false
    @State private var help: Bool = false
    @State private var edit: Bool = false
    @State private var resetPassword: Bool = false
    @State private var showOTPInput: Bool = false
    @State private var showMessage: Bool = false
    @State private var message: String = ""
    @State private var showDeleteSuccessAlert = false
    @State private var isSendingOTP = false
    
    var body: some View {
        VStack(spacing: 30) {

            // MARK: - Title
            Text("Settings")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundStyle(
                    LinearGradient(colors: [.blue, .purple],
                                   startPoint: .leading,
                                   endPoint: .trailing)
                )
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 30)
                .padding(.top, 20)
            
            // MARK: - Options
            VStack(spacing: 20) {
                SettingsCard(
                    icon: "pencil",
                    title: "Edit Profile",
                    gradient: [.blue, .purple]
                ) { edit = true }
                
                SettingsCard(
                    icon: "questionmark.circle",
                    title: "Help & Support",
                    gradient: [.green, .mint]
                ) { help = true }
                
                SettingsCard(
                    icon: "lock",
                    title: "Reset Password",
                    gradient: [.orange, .pink]
                ) { resetPassword = true }
            }
            .navigationDestination(isPresented: $edit) {
                EditProfile()
            }
            .navigationDestination(isPresented: $help) {
                HelpSupportView()
            }
            .navigationDestination(isPresented: $resetPassword) {
                ForgotPasswordView()
            }
            .padding(.horizontal, 20)
            
            Spacer()
            
            // MARK: - Delete Account Button
            Button(action: { delete = true }) {
                HStack {
                    if isSendingOTP {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Image(systemName: "exclamationmark.triangle.fill")
                        Text("Delete Account")
                            .bold()
                    }
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.red.opacity(0.9), Color.red.opacity(0.6)]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(12)
                .shadow(color: .red.opacity(0.4), radius: 6, x: 0, y: 4)
                .padding(.horizontal, 20)
            }
            .disabled(isSendingOTP)
            .alert("Are you sure you want to delete your account?", isPresented: $delete) {
                Button("Delete", role: .destructive) {
                    if let id = storedUserID {
                        sendDeleteOTP(userID: id) { success, msg in
                            DispatchQueue.main.async {
                                isSendingOTP = false
                                message = msg
                                if success { showOTPInput = true } else { showMessage = true }
                            }
                        }
                    }
                }
                Button("Cancel", role: .cancel) {}
            }
            .sheet(isPresented: $showOTPInput) {
                if let userId = storedUserID {
                    OTPInputSheet(userID: userId) {
                        showOTPInput = false
                        showDeleteSuccessAlert = true
                    }
                }
            }
            .alert(isPresented: $showDeleteSuccessAlert) {
                Alert(
                    title: Text("Account Deleted"),
                    message: Text("Your account has been deleted successfully."),
                    dismissButton: .default(Text("OK")) {
                        withAnimation {
                            appState.isLoggedIn = false
                            appState.rootViewState = .login
                        }
                    }
                )
            }
            .alert("Message", isPresented: $showMessage) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(message)
            }
        }
        .background(
            LinearGradient(colors: [Color(.systemGroupedBackground), .white],
                           startPoint: .topLeading,
                           endPoint: .bottomTrailing)
                .ignoresSafeArea()
        )
    }
}

// MARK: - Individual Option Card
struct SettingsCard: View {
    let icon: String
    let title: String
    let gradient: [Color]
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(LinearGradient(colors: gradient,
                                             startPoint: .topLeading,
                                             endPoint: .bottomTrailing))
                        .frame(width: 50, height: 50)
                    Image(systemName: icon)
                        .foregroundColor(.white)
                        .font(.system(size: 22, weight: .semibold))
                }
                
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
            .padding()
            .background(Color.white)
            .cornerRadius(14)
            .shadow(color: Color.black.opacity(0.08), radius: 6, x: 0, y: 4)
        }
    }
}

// MARK: - OTP Input
struct OTPInputSheet: View {
    var userID: Int
    var onSuccess: () -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var otp: String = ""
    @State private var message: String = ""
    @State private var showMessage = false

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Enter the OTP sent to your email")
                    .font(.headline)
                    .foregroundStyle(LinearGradient(colors: [.blue, .purple],
                                                    startPoint: .leading,
                                                    endPoint: .trailing))

                CustomTextField(title: "OTP", text: $otp)
                    .keyboardType(.numberPad)
                    .padding(.horizontal)
                
                Button("Confirm Deletion") {
                    guard !otp.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                        message = "OTP cannot be empty."
                        showMessage = true
                        return
                    }
                    
                    verifyAndDeleteAccount(userID: userID, otp: otp) { success, msg in
                        DispatchQueue.main.async {
                            if success {
                                onSuccess()
                                dismiss()
                            } else {
                                message = msg
                                showMessage = true
                            }
                        }
                    }
                }
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(LinearGradient(colors: [.red, .orange],
                                           startPoint: .topLeading,
                                           endPoint: .bottomTrailing))
                .cornerRadius(10)
                .shadow(radius: 3)
            }
            .padding()
            .alert("Error", isPresented: $showMessage) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(message)
            }
            .navigationTitle("Verify OTP")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// MARK: - Preview
#Preview {
    SettingsView()
        .environmentObject(AppState())
}
