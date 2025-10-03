import SwiftUI

struct HomeView: View {
    @StateObject private var reviewFetcher = ReviewFetch()
    @EnvironmentObject var appState: AppState
    @Binding var showSidebar: Bool
    @Environment(\.horizontalSizeClass) var hSizeClass

    var body: some View {
        NavigationStack {
            GeometryReader { geo in
                ZStack {
                    // Main Content
                    VStack(alignment: .leading, spacing: 16) {
                        
                        // MARK: - Header
                        HStack {
                            Button {
                                withAnimation {
                                    showSidebar.toggle()
                                }
                            } label: {
                                Image(systemName: "line.3.horizontal")
                                    .font(.system(size: geo.size.width < 400 ? 20 : 24, weight: .semibold))
                                    .foregroundColor(.white)
                            }
                            
                            Text("Bus Echo")
                                .font(.system(size: geo.size.width < 400 ? 26 : 34, weight: .bold))
                                .foregroundColor(.white)
                            
                            Spacer()
                        }
                        .padding(.horizontal, geo.size.width < 400 ? 12 : 20)
                        .padding(.vertical, 12)
                        .padding(.bottom, 10)
                        .background(
                            LinearGradient(colors: [Color.indigo, Color.cyan],
                                           startPoint: .top,
                                           endPoint: .bottom)
                                .ignoresSafeArea(edges: .top)
                        )
                        
                        // MARK: - Content
                        Group {
                            if reviewFetcher.isLoading {
                                Spacer()
                                ProgressView("Loading reviews...")
                                    .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                                Spacer()
                            }  else if let error = reviewFetcher.errorMessage {
                                Spacer()
                                VStack(spacing: 12) {
                                    Text("Something went wrong")
                                        .font(.headline)
                                        .foregroundColor(.red)

                                    Text(error)
                                        .multilineTextAlignment(.center)
                                        .foregroundColor(.secondary)

                                    Button(action: {
                                        if let userId = appState.storedUserID {
                                            Task {
                                                await reviewFetcher.fetchReviews(viewerId: userId)
                                            }
                                        }
                                    }) {
                                        HStack {
                                            Image(systemName: "arrow.clockwise")
                                            Text("Retry")
                                        }
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 10)
                                        .background(Color.blue.opacity(0.2))
                                        .foregroundColor(.blue)
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                    }
                                }
                                .padding()
                                Spacer()
                            } else {
                                ScrollView {
                                    LazyVStack(spacing: hSizeClass == .compact ? 12 : 20) {
                                        ForEach(reviewFetcher.reviews) { review in
                                            ReviewTile(review: review)
                                                .frame(maxWidth: .infinity)
                                        }
                                    }
                                    .padding(.horizontal, hSizeClass == .compact ? 10 : 20)
                                    .padding(.bottom, 12)
                                    .frame(maxWidth: geo.size.width)
                                }
                                // ✅ Pull to Refresh
                                .refreshable {
                                    if let userId = appState.storedUserID {
                                        await reviewFetcher.fetchReviews(viewerId: userId)
                                    }
                                }
                            }
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                    .background(Color(.systemGroupedBackground).ignoresSafeArea())
                    .onAppear {
                        if let userId = appState.storedUserID {
                            Task {
                                await reviewFetcher.fetchReviews(viewerId: userId)
                            }
                        }
                    }
                    
                    // Sidebar Overlay
                    SidebarView(isShowing: $showSidebar).environmentObject(appState) 
                }
            }
        }
    }
}
