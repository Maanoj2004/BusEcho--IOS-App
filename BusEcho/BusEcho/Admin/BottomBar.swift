import SwiftUI

enum view {
    case dashboard
    case users
    case buses
    case reviews
    case profile
}

struct BottomBarView: View {
    @State private var selectedTab: view = .dashboard
    
    var body: some View {
        ZStack {
            Color.white // Sets the full screen background
                .ignoresSafeArea()

            TabView(selection: $selectedTab) {
                DashboardView()
                    .tabItem { Label("Dashboard", systemImage: "chart.bar.doc.horizontal.fill") }
                    .tag(view.dashboard)

                UsersView()
                    .tabItem { Label("Users", systemImage: "person.circle.fill") }
                    .tag(view.users)

                BusesView()
                    .tabItem { Label("Buses", systemImage: "bus") }
                    .tag(view.buses)

                ReviewsView()
                    .tabItem { Label("Reviews", systemImage: "text.bubble.rtl") }
                    .tag(view.reviews)

                AdminView(admin: Admin(
                    id: 1,
                    name: "Maanoj Palani",
                    username: "admin123",
                    mail_id: "admin@gmail.com"
                ))
                    .tabItem { Label("Profile", systemImage: "person") }
                    .tag(view.profile)
            }
            .accentColor(Color(hex: "20C3C9"))
        }
    }
}

#Preview {
    BottomBarView()
}

