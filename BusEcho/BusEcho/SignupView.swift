import SwiftUI

struct Signup: View {
    @EnvironmentObject var appState: AppState

    @State private var name: String = ""
    @State private var username: String = ""
    @State private var mail_id: String = ""
    @State private var password: String = ""
    @State private var phone_num: String = ""

    @State private var isPasswordVisible = false

    @State private var usernameError = ""
    @State private var emailError = ""
    @State private var phoneError = ""
    @State private var generalError = ""

    @State private var sentOTP: Bool = false
    @State private var enteredOTP: String = ""
    @State private var otpError: String = ""

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: geometry.size.height * 0.025) {
                Spacer()

                Text("Welcome to\nBus Echo")
                    .font(.system(size: geometry.size.width * 0.1, weight: .bold))
                    .multilineTextAlignment(.center)
                    .foregroundColor(Color(hex: "2A3B7F"))

                Group {
                    CustomTextField(title: "Name", text: $name)

                    VStack(alignment: .leading, spacing: 5) {
                        CustomTextField(title: "Username", text: $username)
                            .onChange(of: username) {
                                usernameError = ""
                            }
                        if !usernameError.isEmpty {
                            Text(usernameError).font(.caption).foregroundColor(.red)
                        }
                    }

                    VStack(alignment: .leading, spacing: 5) {
                        CustomTextField(title: "Email", text: $mail_id)
                            .onChange(of: mail_id) {
                                emailError = ""
                            }.textInputAutocapitalization(.never)
                        if !emailError.isEmpty {
                            Text(emailError).font(.caption).foregroundColor(.red)
                        }
                    }

                    ZStack(alignment: .trailing) {
                        if isPasswordVisible {
                            CustomTextField(title: "Password", text: $password)
                        } else {
                            CustomPasswordField(title: "Password", text: $password)
                        }
                        Button(action: {
                            isPasswordVisible.toggle()
                        }) {
                            Image(systemName: isPasswordVisible ? "eye" : "eye.slash")
                                .foregroundColor(.gray)
                        }.padding(.trailing, 10)
                    }

                    VStack(alignment: .leading, spacing: 5) {
                        CustomTextField(title: "Phone Number", text: $phone_num)
                            .onChange(of: phone_num) {
                                phoneError = ""
                            }
                        if !phoneError.isEmpty {
                            Text(phoneError).font(.caption).foregroundColor(.red)
                        }
                    }
                }

                if !generalError.isEmpty {
                    Text(generalError)
                        .foregroundColor(.red)
                        .font(.footnote)
                        .multilineTextAlignment(.center)
                        .padding(.top, -10)
                }

                Button(action: {
                    generalError = ""
                    signupUser(
                        name: name.trimmingCharacters(in: .whitespaces),
                        username: username.trimmingCharacters(in: .whitespaces),
                        mail_id: mail_id.trimmingCharacters(in: .whitespaces),
                        password: password,
                        phone_num: phone_num.trimmingCharacters(in: .whitespaces)
                    ) { result in
                        DispatchQueue.main.async {
                            switch result {
                            case .success(let returnedName):
                                appState.name = returnedName
                                appState.rootViewState = .signUpSuccess
                            case .failure(let error):
                                let msg = error.localizedDescription
                                if msg.contains("Username") {
                                    usernameError = msg
                                } else if msg.contains("Email") {
                                    emailError = msg
                                } else if msg.contains("Phone") {
                                    phoneError = msg
                                } else {
                                    generalError = msg
                                }
                            }
                        }
                    }
                }) {
                    Text("Create Account")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(LinearGradient(colors: [.blue, .indigo],
                                                   startPoint: .leading,
                                                   endPoint: .trailing))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }

                Spacer()
            }
            .padding(.horizontal, 30)
            .frame(maxWidth: 600)
            .ignoresSafeArea(.keyboard) // Prevent view from pushing on keyboard
        }
    }
}

import SwiftUI

struct SignupWelcomeScreen: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        ZStack {
            // Background Gradient
            LinearGradient(
                colors: [Color(hex: "2A3B7F"), Color(hex: "4E6CFF")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 28) {
                // App Icon / Illustration
                Image(systemName: "bus.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.white.opacity(0.15))
                    .clipShape(Circle())
                    .shadow(radius: 10)

                // Welcome Title
                Text("Welcome, \(appState.name)!")
                    .multilineTextAlignment(.center)
                    .font(.largeTitle.bold())
                    .foregroundColor(.white)

                // Tagline
                Text("Discover. Review. Connect.\nYour trusted bus companion.")
                    .multilineTextAlignment(.center)
                    .font(.headline)
                    .foregroundColor(.white.opacity(0.9))
                    .padding(.horizontal, 20)

                Spacer().frame(height: 30)

                // Login Button
                Button(action: {
                    appState.rootViewState = .login
                }) {
                    Text("Get Started")
                        .font(.title3.bold())
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(
                            LinearGradient(colors: [.cyan, .blue],
                                           startPoint: .leading,
                                           endPoint: .trailing)
                        )
                        .foregroundColor(.white)
                        .cornerRadius(14)
                        .shadow(color: .black.opacity(0.2), radius: 6, x: 0, y: 4)
                }
                .padding(.horizontal, 40)
            }
            .padding()
        }
    }
}

#Preview {
    Signup()
        .environmentObject(AppState())
}
