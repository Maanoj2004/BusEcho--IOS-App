import SwiftUI

struct ProfileView: View {
    @StateObject private var reviewFetcher = ReviewFetch()
    @EnvironmentObject var appState: AppState
    @State private var showLogoutAlert = false
    @State private var showSettings = false

    @State private var userProfile: UserProfile?
    @State private var loading = true
    @State private var loadError = ""

    @State private var userReviews: [ReviewModel] = []
    @State private var loadingReviews = true

    var body: some View {
        NavigationStack {
            VStack{
                VStack{
                    headerSection
                }
                ScrollView {
                    VStack(spacing: 20) {
                        if loading {
                            ProgressView("Loading profile...")
                                .padding()
                        } else if let user = userProfile {
                            profileInfoSection(user: user)
                        } else {
                            Text("Error: \(loadError)")
                                .foregroundColor(.red)
                                .padding()
                        }
                        Divider().padding(.vertical, 8)
                        VStack(alignment: .center, spacing: 12) {
                            Text("My Reviews")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundStyle(Color(hex: "2A3B7F"))
                            
                            if loadingReviews {
                                ProgressView()
                            } else if userReviews.isEmpty {
                                Text("You haven’t posted any reviews yet.")
                                    .foregroundColor(.gray)
                            } else {
                                VStack(spacing: 16) {
                                    ForEach(userReviews) { review in
                                        ReviewTile(review: review)
                                    }
                                }
                            }
                        }
                    }
                    .padding()
                }
                .onAppear(perform: loadData)
                .onAppear {
                    if let userId = appState.storedUserID {
                        Task {
                            await reviewFetcher.fetchReviews(viewerId: userId)
                        }
                    }
                }
                .onReceive(reviewFetcher.$reviews) { reviews in
                    self.userReviews = reviews
                    self.loadingReviews = false
                }
            }
            .padding(.horizontal,10)
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
        }
    }

    var headerSection: some View {
        HStack {
            Button(action: { showSettings = true }) {
                Image(systemName: "gearshape.fill")
                    .font(.system(size: 22))
                    .foregroundColor(.white)
                    .padding(10)
                    .background(
                        LinearGradient(colors: [.blue, .teal],
                                       startPoint: .topLeading,
                                       endPoint: .bottomTrailing)
                    )
                    .clipShape(Circle())
                    .shadow(radius: 3)
            }
            .navigationDestination(isPresented: $showSettings) {
                SettingsView()
            }

            Spacer()

            Text("Profile")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(Color(hex: "2A3B7F"))

            Spacer()

            Button(action: { showLogoutAlert = true }) {
                Image(systemName: "rectangle.portrait.and.arrow.right")
                    .font(.system(size: 22))
                    .foregroundColor(.white)
                    .padding(10)
                    .background(
                        LinearGradient(colors: [.red, .orange],
                                       startPoint: .topLeading,
                                       endPoint: .bottomTrailing)
                    )
                    .clipShape(Circle())
                    .shadow(radius: 3)
            }
            .alert("Are you sure you want to logout?", isPresented: $showLogoutAlert) {
                Button("Logout", role: .destructive) {
                    withAnimation {
                        appState.isLoggedIn = false
                        appState.rootViewState = .login
                    }
                }
                Button("Cancel", role: .cancel) { }
            }
        }
        .padding(.horizontal,20)
    }

    func profileInfoSection(user: UserProfile) -> some View {
        VStack(spacing: 10) {
            // Profile Image
            Image(systemName: "person.circle.fill")
                .resizable()
                .frame(width: 90, height: 90)
                .foregroundColor(Color(hex: "4A90E2"))
                .shadow(radius: 4)

            // User Info
            Text(user.name)
                .font(.title2)
                .bold()
                .foregroundStyle(Color(hex: "2A3B7F"))

            Text("@\(user.username)")
                .font(.subheadline)
                .foregroundColor(.gray)

            if let bio = user.bio, !bio.isEmpty {
                Text(bio)
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }

            // Stats
            HStack(spacing: 40) {
                StatView(number: "\(userReviews.count)", label: "Total Reviews", gradient: [.blue, .cyan])
                let level = reviewerLevel(for: userReviews.count)
                LevelView(icon: level.icon, name: level.name, gradient: level.gradient)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(LinearGradient(colors: [Color.white, Color(hex: "F0F7FF")],
                                         startPoint: .top,
                                         endPoint: .bottom))
                    .shadow(color: Color.black.opacity(0.08), radius: 6, x: 0, y: 3)
            )
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal,20)
    }
    
    func reviewerLevel(for count: Int) -> (name: String, icon: String, gradient: [Color]) {
        switch count {
        case 0...2:
            return ("New Passenger", "person.fill", [.gray, .blue])
        case 3...10:
            return ("Frequent Reviewer", "star.fill", [.yellow, .orange])
        case 11...25:
            return ("Trusted Voice", "hand.thumbsup.fill", [.green, .mint])
        case 26...50:
            return ("Expert Traveler", "bus.fill", [.indigo, .purple])
        default:
            return ("Echo Ambassador", "crown.fill", [.pink, .orange])
        }
    }
    
    func loadData() {
        if let userID = appState.storedUserID {
            fetchUserProfile(userID: userID) { result in
                DispatchQueue.main.async {
                    loading = false
                    switch result {
                    case .success(let user): self.userProfile = user
                    case .failure(let error): self.loadError = error.localizedDescription
                    }
                }
            }
        }
    }
}

struct LevelView: View {
    let icon: String
    let name: String
    let gradient: [Color]
    
    var body: some View {
        VStack(spacing: 6) {
            LinearGradient(colors: gradient, startPoint: .topLeading, endPoint: .bottomTrailing)
                .mask(
                    Image(systemName: icon)
                        .font(.system(size: 26))
                )
                .frame(height: 26)
            
            Text(name)
                .font(.caption)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .frame(width: 90)
        }
    }
}

struct StatView: View {
    let number: String
    let label: String
    let gradient: [Color]

    var body: some View {
        VStack {
            LinearGradient(colors: gradient, startPoint: .topLeading, endPoint: .bottomTrailing)
                .mask(
                    Text(number)
                        .font(.title3)
                        .bold()
                )
                .frame(height: 20)

            Text(label)
                .font(.caption)
                .multilineTextAlignment(.center)
                .foregroundColor(.gray)
        }
    }
}

#Preview {
    ProfileView()
        .environmentObject(AppState())
}
