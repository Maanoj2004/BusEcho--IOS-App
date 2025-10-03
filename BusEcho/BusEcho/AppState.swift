import SwiftUI

enum RootViewState {
    case login
    case signUpSuccess
    case signup
    case forgotPassword
    case resetPassword
    case home
    case dashboard
}

class AppState: ObservableObject {
    @AppStorage("isLoggedIn") var isLoggedIn: Bool = false
    @AppStorage("notifications") var notifications: Bool = false
    @AppStorage("userType") var userType: String?
    @Published var showSettings = false
    @Published var rootViewState: RootViewState = .login
    @AppStorage("storedUserID") var storedUserID: Int?
    @Published var name: String = ""
    @Published var emailForReset: String = ""
}
