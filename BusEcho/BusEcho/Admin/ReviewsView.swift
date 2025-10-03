import SwiftUI

struct ReviewsView: View {
    @StateObject private var reviewFetcher = ReviewFetch()
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                VStack(alignment: .leading, spacing: 16) {
                    
                    // MARK: - Title
                    Text("Reviews")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(Color(hex: "2A3B7F"))
                        .padding(.top, 20)
                        .padding(.horizontal, geometry.size.width * 0.05)
                    
                    // MARK: - Content Area
                    if reviewFetcher.isLoading {
                        VStack {
                            Spacer()
                            ProgressView("Loading reviews...")
                                .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                            Spacer()
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else if let error = reviewFetcher.errorMessage {
                        VStack {
                            Spacer()
                            Text("Error:")
                                .font(.headline)
                                .foregroundColor(.red)
                            Text(error)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 24)
                            Spacer()
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else if reviewFetcher.reviews.isEmpty {
                        // ✅ Empty state
                        VStack {
                            Spacer()
                            Text("No reviews found.")
                                .foregroundColor(.gray)
                                .font(.headline)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 24)
                            Spacer()
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        // ✅ Reviews list
                        ScrollView {
                            LazyVStack(spacing: 12) {
                                ForEach(reviewFetcher.reviews) { review in
                                    ReviewTile(review: review)
                                        .id(review.id)
                                }
                            }
                            .padding(.horizontal, geometry.size.width * 0.05)
                            .padding(.bottom, 20)
                        }
                    }
                }
                .frame(width: geometry.size.width, height: geometry.size.height)
                .background(Color(.white).ignoresSafeArea())
                .onAppear {
                    if let userId = appState.storedUserID {
                        Task {
                            await reviewFetcher.fetchReviews(viewerId: userId)
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    ReviewsView()
        .environmentObject(AppState())
}
