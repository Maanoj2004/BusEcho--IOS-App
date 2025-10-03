import SwiftUI

enum Tab {
    case home
    case search
    case post
    case profile
}

import SwiftUI

struct MainTabView: View {
    @State private var selectedTab: Tab = .home
    @State private var showSidebar: Bool = false
    
    let gradient = LinearGradient(
        colors: [Color.indigo, Color.cyan],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    var body: some View {
        ZStack {
            // Background
            Color.white.ignoresSafeArea()
            
            // MARK: - Main content + TabBar
            VStack(spacing: 0) {
                // Main content
                ZStack {
                    switch selectedTab {
                    case .home:
                        HomeView(showSidebar: $showSidebar)
                    case .search:
                        SearchView(selectedTab: $selectedTab)
                    case .post:
                        PostView()
                    case .profile:
                        ProfileView()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                // Custom TabBar
                HStack {
                    tabButton(.home, systemImage: "house", text: "Home")
                    tabButton(.search, systemImage: "magnifyingglass", text: "Search")
                    tabButton(.post, systemImage: "plus.circle", text: "Post")
                    tabButton(.profile, systemImage: "person", text: "Profile")
                }
                .padding(.vertical, 10)
                .padding(.horizontal, 10)
                // transparent background
            }
            
            // MARK: - Sidebar Overlay (always on top)
            SidebarView(isShowing: $showSidebar)
                .zIndex(1) // ensures it’s above TabBar
        }
    }
    
    @ViewBuilder
    private func tabButton(_ tab: Tab, systemImage: String, text: String) -> some View {
        Button {
            selectedTab = tab
        } label: {
            VStack(spacing: 4) {
                gradient
                    .mask(Image(systemName: systemImage)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 22, height: 22))
                    .frame(width: 22, height: 22)
                
                Text(text)
                    .font(.caption2)
                    .foregroundColor(selectedTab == tab ? .primary : .secondary)
            }
            .frame(maxWidth: .infinity)
        }
    }
}

#Preview {
    MainTabView()
}
