import SwiftUI

struct EditProfile: View {
    @AppStorage("storedUserID") private var storedUserID: Int?

    @State private var name: String = ""
    @State private var username: String = ""
    @State private var email: String = ""
    @State private var phone: String = ""
    @State private var bio: String = ""

    @State private var originalEmail: String = ""
    @State private var originalPhone: String = ""
    @State private var originalName: String = ""
    @State private var originalUsername: String = ""
    @State private var originalBio: String = ""

    @State private var showOTPField = false
    @State private var otp: String = ""

    @State private var isLoading = true
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var isSuccessAlert = false

    // ✅ OTP Sent Popup
    @State private var showOTPSentPopup = false

    // Loading states
    @State private var isSaving = false
    @State private var isVerifyingOTP = false

    var changesMade: Bool {
        name != originalName ||
        username != originalUsername ||
        email != originalEmail ||
        phone != originalPhone ||
        bio != originalBio
    }

    var body: some View {
        NavigationView {
            VStack {
                VStack(spacing: 24) {
                    Text("Edit Profile")
                        .font(.title)
                        .bold()
                        .foregroundColor(.black)
                        .padding(.vertical)

                    ScrollView {
                        // MARK: - Profile Form
                        VStack(alignment: .leading, spacing: 18) {
                            formField(title: "Name", text: $name, icon: "person.fill")
                            formField(title: "Username", text: $username, icon: "at")
                            formField(title: "Email", text: $email, icon: "envelope.fill")
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled()
                            formField(title: "Phone Number", text: $phone, icon: "phone.fill")
                            formField(title: "Bio (Optional)", text: $bio, icon: "text.quote")
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.white)
                                .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
                        )
                        .padding(.horizontal)

                        // MARK: - OTP Section
                        if showOTPField {
                            VStack(alignment: .leading, spacing: 14) {
                                Text("OTP Verification")
                                    .font(.headline)
                                    .foregroundColor(Color.blue)

                                formField(title: "Enter OTP", text: $otp, icon: "number")
                                    .keyboardType(.numberPad)

                                Button(action: {
                                    guard let userId = storedUserID else { return }
                                    isVerifyingOTP = true
                                    verifyOTP(userID: userId, otp: otp) { result in
                                        DispatchQueue.main.async {
                                            isVerifyingOTP = false
                                            switch result {
                                            case .success(let verified):
                                                if verified {
                                                    alertMessage = "OTP Verified. Changes saved!"
                                                    isSuccessAlert = true
                                                    showOTPField = false
                                                    updateOriginals()
                                                } else {
                                                    alertMessage = "Incorrect OTP. Please try again."
                                                    isSuccessAlert = false
                                                }
                                            case .failure(let error):
                                                alertMessage = "Error verifying OTP: \(error.localizedDescription)"
                                                isSuccessAlert = false
                                            }
                                            showAlert = true
                                        }
                                    }
                                }) {
                                    if isVerifyingOTP {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                            .frame(maxWidth: .infinity)
                                            .padding()
                                            .background(Color.green.opacity(0.7))
                                            .cornerRadius(10)
                                    } else {
                                        Text("Verify and Save")
                                            .foregroundColor(.white)
                                            .frame(maxWidth: .infinity)
                                            .padding()
                                            .background(
                                                LinearGradient(
                                                    colors: [Color.green.opacity(0.9), Color.green.opacity(0.6)],
                                                    startPoint: .leading,
                                                    endPoint: .trailing
                                                )
                                            )
                                            .cornerRadius(10)
                                            .shadow(radius: 3)
                                    }
                                }
                                .disabled(isVerifyingOTP)
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.blue.opacity(0.05))
                            )
                            .padding(.horizontal)
                        } else {
                            // ✅ Save Changes Button
                            if changesMade {
                                Button(action: {
                                    guard let id = storedUserID else { return }
                                    isSaving = true
                                    saveProfileChanges(userID: id, name: name, username: username, email: email, phone: phone, bio: bio) { result in
                                        DispatchQueue.main.async {
                                            isSaving = false
                                            switch result {
                                            case .success(let msg):
                                                alertMessage = msg
                                                isSuccessAlert = true
                                                updateOriginals()
                                                showAlert = true

                                            case .otpRequired(let msg):
                                                showOTPField = true      // show OTP input box
                                                showOTPSentPopup = true  // show the popup
                                                alertMessage = msg

                                            case .failure(let error):
                                                alertMessage = "Failed to save: \(error.localizedDescription)"
                                                isSuccessAlert = false
                                                showAlert = true
                                            }
                                        }
                                    }
                                }) {
                                    if isSaving {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                            .frame(maxWidth: .infinity)
                                            .padding()
                                            .background(Color.gray)
                                            .cornerRadius(12)
                                    } else {
                                        Text("Save Changes")
                                            .foregroundColor(.white)
                                            .frame(maxWidth: .infinity)
                                            .padding()
                                            .background(
                                                LinearGradient(
                                                    colors: [Color.blue, Color.cyan],
                                                    startPoint: .leading,
                                                    endPoint: .trailing
                                                )
                                            )
                                            .cornerRadius(12)
                                            .shadow(radius: 4)
                                    }
                                }
                                .padding(.horizontal)
                                .disabled(isSaving)
                            }
                        }
                    }
                    .padding(.bottom, 30)
                }
                .onAppear {
                    if let id = storedUserID {
                        fetchUserProfile(userID: id) { result in
                            DispatchQueue.main.async {
                                switch result {
                                case .success(let profile):
                                    name = profile.name
                                    username = profile.username
                                    email = profile.mail_id
                                    phone = profile.phone_num
                                    bio = profile.bio ?? ""
                                    updateOriginals()
                                case .failure(let error):
                                    alertMessage = "Failed to load profile: \(error.localizedDescription)"
                                    showAlert = true
                                }
                                isLoading = false
                            }
                        }
                    }
                }
                // ✅ Success/Error Alerts
                .alert(isPresented: $showAlert) {
                    Alert(
                        title: Text(isSuccessAlert ? "Success" : "Error"),
                        message: Text(alertMessage),
                        dismissButton: .default(Text("OK"))
                    )
                }
                // ✅ OTP Sent Popup
                .sheet(isPresented: $showOTPSentPopup) {
                    VStack(spacing: 20) {
                        Text("OTP Sent")
                            .font(.title2)
                            .bold()
                        Text("An OTP has been sent to your email. Please enter it below to confirm changes.")
                            .multilineTextAlignment(.center)
                            .padding()
                        Button("OK") {
                            showOTPSentPopup = false
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    .padding()
                }
                .background(Color(.systemGroupedBackground).ignoresSafeArea())
                .navigationBarTitleDisplayMode(.inline)
            }
        }
    }

    // MARK: - Reusable Field
    func formField(title: String, text: Binding<String>, icon: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.blue)

            HStack {
                Image(systemName: icon)
                    .foregroundColor(.blue)
                TextField(title, text: text)
                    .padding(8)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(Color(.systemGray6))
            .cornerRadius(10)
        }
    }

    // MARK: - Update Originals
    func updateOriginals() {
        originalName = name
        originalUsername = username
        originalEmail = email
        originalPhone = phone
        originalBio = bio
    }
}
