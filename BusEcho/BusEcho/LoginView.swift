import SwiftUI

struct LoginView: View {
    @EnvironmentObject var appState: AppState
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var isPasswordVisible: Bool = false
    @State private var navigateToSignUp = false
    @State private var resetPassword = false
    @State private var errorMessage = ""
    @State private var showAlert : Bool = false
    @AppStorage("isLoggedIn") var isLoggedIn: Bool = false
    @State private var isLoading: Bool = false
    
    var body: some View {
        GeometryReader { geometry in
            NavigationStack {
                VStack(spacing: geometry.size.height * 0.03) {
                    
                    Spacer(minLength: geometry.size.height * 0.05)
                    
                    Rectangle()
                        .fill(LinearGradient(colors: [.blue, .indigo], startPoint: .bottom, endPoint: .leading))
                        .frame(width: geometry.size.width * 0.25, height: geometry.size.width * 0.25)
                        .cornerRadius(20)
                    
                    HStack(spacing: 5) {
                        Text("Bus")
                            .font(.system(size: geometry.size.width * 0.12, weight: .bold))
                            .foregroundColor(Color(hex: "8DD0F0"))
                        Text("Echo")
                            .font(.system(size: geometry.size.width * 0.12, weight: .bold))
                            .foregroundColor(Color(hex: "2A3B7F"))
                    }
                    
                    VStack(spacing: geometry.size.height * 0.025) {
                        Text("Login")
                            .font(.title2)
                            .foregroundStyle(Color(hex: "2A3B7F"))
                        
                        VStack(alignment: .leading, spacing: 15) {
                            CustomTextField(title: "Username", text: $username)
                                .textInputAutocapitalization(.never)
                            
                            ZStack(alignment: .trailing) {
                                if isPasswordVisible {
                                    CustomTextField(title: "Password", text: $password)
                                        .textInputAutocapitalization(.never)
                                } else {
                                    CustomPasswordField(title: "Password", text: $password)
                                        .textInputAutocapitalization(.never)
                                }
                                
                                Button(action: {
                                    isPasswordVisible.toggle()
                                }) {
                                    Image(systemName: isPasswordVisible ? "eye" : "eye.slash")
                                        .foregroundColor(.black)
                                }
                                .padding(.trailing, 10)
                            }
                            
                            Button(action: {
                                resetPassword = true
                            }) {
                                Text("Forgot password?")
                                    .font(.footnote)
                                    .frame(maxWidth: .infinity, alignment: .trailing)
                            }
                        }
                        
                        Button(action: {
                            if username.trimmingCharacters(in: .whitespaces).isEmpty ||
                                password.trimmingCharacters(in: .whitespaces).isEmpty {
                                errorMessage = "Please enter both username and password."
                                showAlert = true
                                return
                            }
                            
                            isLoading = true   // START loading
                            loginUser(input: username, password: password) { result in
                                DispatchQueue.main.async {
                                    isLoading = false   // STOP loading
                                    switch result {
                                    case .success(let (id, name, role)):
                                        appState.storedUserID = id
                                        appState.name = name
                                        appState.isLoggedIn = true
                                        appState.userType = role
                                    case .failure(let error):
                                        showAlert = true
                                        errorMessage = error.localizedDescription
                                    }
                                }
                            }
                        }) {
                            if isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .frame(maxWidth: .infinity)
                                    .padding()
                            } else {
                                Text("Login")
                                    .font(.headline)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                            }
                        }
                        .background(
                            LinearGradient(colors: [Color.cyan, Color.blue],
                                           startPoint: .leading,
                                           endPoint: .trailing)
                        )
                        .foregroundColor(.white)
                        .cornerRadius(14)
                        .shadow(color: .black.opacity(0.2), radius: 6, x: 0, y: 4)
                        .disabled(isLoading)
                        
                        HStack {
                            Text("New User?")
                            Button("Sign Up") {
                                navigateToSignUp = true
                            }
                            .foregroundColor(Color(hex: "8DD0F0"))
                        }
                    }
                    .alert(isPresented: $showAlert){
                        Alert(title: Text("Login Failed"), message: Text(errorMessage), dismissButton: .default(Text("Ok")))
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                }
                .padding()
                .navigationDestination(isPresented: $navigateToSignUp) {
                    Signup()
                }
                .navigationDestination(isPresented: $resetPassword) {
                    ForgotPasswordView()
                }
            }
            .ignoresSafeArea(.keyboard)
        }
    }
}

//import SwiftUI
//
//struct LoginView: View {
//    @State private var email = ""
//    @State private var password = ""
//    @State private var role: String? = nil
//    @State private var isLoggedIn = false
//    @State private var errorMessage = ""
//
//    var body: some View {
//        NavigationStack {
//            VStack(spacing: 20) {
//                TextField("Email", text: $email)
//                    .textFieldStyle(.roundedBorder)
//                SecureField("Password", text: $password)
//                    .textFieldStyle(.roundedBorder)
//                
//                Button("Login") {
//                    login()
//                }
//                .buttonStyle(.borderedProminent)
//
//                if !errorMessage.isEmpty {
//                    Text(errorMessage)
//                        .foregroundColor(.red)
//                }
//            }
//            .navigationDestination(isPresented: .constant(isLoggedIn && role == "admin")) {
//                AdminDashboardView()
//            }
//            .navigationDestination(isPresented: .constant(isLoggedIn && role == "user")) {
//                MainTabView()
//            }
//            .padding()
//            .navigationTitle("Login")
//        }
//    }
//
//    func login() {
//        guard let url = URL(string: "http://localhost/login.php") else { return }
//        
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//        let bodyData = "email=\(email)&password=\(password)"
//        request.httpBody = bodyData.data(using: .utf8)
//        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
//
//        URLSession.shared.dataTask(with: request) { data, _, error in
//            if let error = error {
//                DispatchQueue.main.async {
//                    self.errorMessage = error.localizedDescription
//                }
//                return
//            }
//
//            guard let data = data else { return }
//            do {
//                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
//                    if let status = json["status"] as? String, status == "success" {
//                        DispatchQueue.main.async {
//                            self.role = json["role"] as? String
//                            self.isLoggedIn = true
//                        }
//                    } else {
//                        DispatchQueue.main.async {
//                            self.errorMessage = json["message"] as? String ?? "Login failed"
//                        }
//                    }
//                }
//            } catch {
//                DispatchQueue.main.async {
//                    self.errorMessage = "Invalid server response"
//                }
//            }
//        }.resume()
//    }
//}
//
//struct AdminDashboardView: View {
//    var body: some View {
//        Text("Welcome, Admin!")
//    }
//}
//
//struct UserHomeView: View {
//    var body: some View {
//        Text("Welcome, User!")
//    }
//}

#Preview {
    LoginView()
        .environmentObject(AppState())
}
