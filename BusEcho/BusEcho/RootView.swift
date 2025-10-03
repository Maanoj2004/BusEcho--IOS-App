import SwiftUI

struct RootView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        Group {
            if appState.isLoggedIn {
                if appState.userType == "admin"{
                    BottomBarView()
                }
                else{
                    MainTabView()
                }
            } else {
                switch appState.rootViewState {
                case .login:
                    LoginView()
                case .signUpSuccess:
                    SignupWelcomeScreen()
                case .signup:
                    Signup()
                case .forgotPassword:
                    ForgotPasswordView()
                case .resetPassword:
                    PasswordResetView(email: appState.emailForReset)
                case .home:
                    MainTabView()
                case .dashboard:
                    DashboardView()
                }
            }
        }
        .id(appState.rootViewState)
        .animation(.easeInOut, value: appState.rootViewState)
        .animation(.easeInOut, value: appState.isLoggedIn)
    }
}

struct AppLaunchView: View {
    @State private var showSplash = true

    var body: some View {
        ZStack {
            RootView()
                .opacity(showSplash ? 0 : 1)

            if showSplash {
                SplashScreenView()
                    .transition(.opacity)
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3 ) {
                withAnimation {
                    showSplash = false
                }
            }
        }
    }
}
