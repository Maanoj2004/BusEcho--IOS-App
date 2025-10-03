import SwiftUI

struct SidebarView: View {
    @Binding var isShowing: Bool
    @State private var showLogoutAlert: Bool = false
    @EnvironmentObject var appState: AppState
    
    // Profile state
    @State private var userProfile: UserProfile?
    @State private var loadingProfile = true
    @State private var loadError = ""
    
    var body: some View {
        ZStack(alignment: .leading) {
            // Dimmed background (fade in/out)
            if isShowing {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .transition(.opacity) // <- fade
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            isShowing = false
                        }
                    }
            }
            
            // Sidebar content (slide in/out)
            HStack {
                VStack(alignment: .leading, spacing: 20) {
                    
                    // MARK: - Profile Section
                    Group {
                        if loadingProfile {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .frame(width: 70, height: 70)
                                .padding(.top, 40)
                        } else if let user = userProfile {
                            HStack {
                                Image(systemName: "person.circle.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 50, height: 50)
                                    .foregroundColor(.white.opacity(0.9))
                                    .clipShape(Circle())
                                
                                VStack(alignment: .leading) {
                                    Text(user.name)
                                        .font(.headline)
                                        .foregroundColor(.white)
                                    
                                    Text(user.username)
                                        .font(.subheadline)
                                        .foregroundColor(.white.opacity(0.7))
                                }
                            }
                            .padding(.top, 40)
                        } else {
                            Text("Failed to load profile")
                                .foregroundColor(.red)
                                .padding(.top, 40)
                        }
                    }
                    
                    Divider().background(Color.white.opacity(0.5))
                    
                    // MARK: - Menu Items
                    // MARK: - Menu Items
                    Group {
                        NavigationLink(destination: NotificationsView()) {
                            HStack(spacing: 14) {
                                ZStack {
                                    Circle()
                                        .fill(Color.yellow.opacity(0.2))
                                        .frame(width: 36, height: 36)
                                    Image(systemName: "bell.badge.fill")
                                        .foregroundColor(.yellow)
                                }
                                Text("Notifications")
                                    .font(.system(size: 17, weight: .semibold))
                            }
                            .padding(.vertical, 8)
                        }
                        
                        NavigationLink(destination: RateUsView()) {
                            HStack(spacing: 14) {
                                ZStack {
                                    Circle()
                                        .fill(Color.orange.opacity(0.2))
                                        .frame(width: 36, height: 36)
                                    Image(systemName: "star.circle.fill")
                                        .foregroundColor(.orange)
                                }
                                Text("Rate Us")
                                    .font(.system(size: 17, weight: .semibold))
                            }
                            .padding(.vertical, 8)
                        }
                        
                        NavigationLink(destination: HelpSupportView()) {
                            HStack(spacing: 14) {
                                ZStack {
                                    Circle()
                                        .fill(Color.cyan.opacity(0.2))
                                        .frame(width: 36, height: 36)
                                    Image(systemName: "lifepreserver")
                                        .foregroundColor(.cyan)
                                }
                                Text("Help & Support")
                                    .font(.system(size: 17, weight: .semibold))
                            }
                            .padding(.vertical, 8)
                        }
                    }
                    .foregroundColor(.white)


                    
                    Spacer()
                    
                    // MARK: - Logout
                    Button(action: {
                        showLogoutAlert = true
                    }) {
                        HStack(spacing: 14) {
                            ZStack {
                                Circle()
                                    .fill(Color.red.opacity(0.2))
                                    .frame(width: 36, height: 36)
                                Image(systemName: "power")
                                    .foregroundColor(.red)
                            }
                            Text("Logout")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(.white)
                        }
                        .padding(.vertical, 8)
                    }
                    .padding(.bottom, 30)
                    .alert("Are you sure you want to logout?", isPresented: $showLogoutAlert) {
                        Button("Logout", role: .destructive) {
                            withAnimation {
                                appState.isLoggedIn = false
                                appState.rootViewState = .login
                            }
                        }
                        Button("Cancel", role: .cancel) {}
                    }

                }
                .padding(.horizontal, 20)
                .frame(width: 260, alignment: .top)
                .background(
                    LinearGradient(colors: [Color.indigo, Color.cyan],
                                   startPoint: .top,
                                   endPoint: .bottom)
                        .ignoresSafeArea()
                )
                .offset(x: isShowing ? 0 : -260) // Slide
                .animation(.easeInOut(duration: 0.25), value: isShowing)
                
                Spacer()
            }
        }
        .onChange(of: isShowing) { oldValue, newValue in
            if newValue && userProfile == nil {
                loadProfile()
            }
        }
    }
    
    // MARK: - Fetch user profile
    func loadProfile() {
        guard let userID = appState.storedUserID else {
            self.loadingProfile = false
            self.loadError = "No user ID"
            return
        }
        
        fetchUserProfile(userID: userID) { result in
            DispatchQueue.main.async {
                self.loadingProfile = false
                switch result {
                case .success(let profile):
                    self.userProfile = profile
                case .failure(let error):
                    self.loadError = error.localizedDescription
                }
            }
        }
    }
}
