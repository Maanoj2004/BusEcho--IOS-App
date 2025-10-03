import SwiftUI

struct ReviewDetailView: View {
    var review: ReviewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                
                // MARK: - Image Carousel
                if !review.images.isEmpty {
                    TabView {
                        ForEach(review.images, id: \.self) { imagePath in
                            AsyncImage(url: URL(string: API.baseURL+"\(imagePath)")) { phase in
                                switch phase {
                                case .empty:
                                    ZStack {
                                        Color.gray.opacity(0.2)
                                        ProgressView()
                                    }
                                    .frame(height: 240)
                                    .cornerRadius(12)
                                case .success(let image):
                                    image
                                        .resizable()
                                        .scaledToFill()
                                        .frame(height: 240)
                                        .clipped()
                                        .cornerRadius(12)
                                        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                                case .failure(_):
                                    Color.gray.opacity(0.2)
                                        .frame(height: 240)
                                        .cornerRadius(12)
                                @unknown default:
                                    EmptyView()
                                }
                            }
                        }
                    }
                    .tabViewStyle(PageTabViewStyle())
                    .frame(height: 240)
                    .padding(.horizontal, 16)
                }
                
                VStack(alignment: .leading, spacing: 16) {
                    
                    // MARK: - Header (matches ReviewTile style)
                    HStack(alignment: .top, spacing: 12) {
                        Image(systemName: "bus.fill")
                            .foregroundColor(.white)
                            .padding(10)
                            .background(
                                LinearGradient(colors: [Color.blue, Color.purple],
                                               startPoint: .topLeading,
                                               endPoint: .bottomTrailing)
                            )
                            .clipShape(Circle())
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(review.bus_operator)
                                .font(.system(size: 18, weight: .semibold))
                            
                            Text("Bus No: \(review.bus_number)") // ✅ Added
                                .font(.system(size: 14))
                                .foregroundColor(.secondary)
                            
                            Text("\(review.boarding_point) ➜ \(review.dropping_point)")
                                .font(.system(size: 14))
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Text(review.date_of_travel)
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal, 10)
                    
                    Divider()
                    
                    // MARK: - Ratings Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Ratings")
                            .font(.system(size: 16, weight: .semibold))
                        
                        Group {
                            RatingRow(label: "Overall", rating: review.overall_rating)
                            RatingRow(label: "Punctuality", rating: review.punctuality_rating)
                            RatingRow(label: "Comfort", rating: review.comfort_rating)
                            RatingRow(label: "Cleanliness", rating: review.cleanliness_rating)
                            RatingRow(label: "Staff", rating: review.staff_behaviour_rating)
                        }
                    }
                    .padding(.horizontal, 16)
                    
                    Divider()
                    
                    // MARK: - Review Text
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Review")
                            .font(.system(size: 16, weight: .semibold))
                        Text(review.review_text)
                            .font(.system(size: 15))
                            .foregroundColor(.primary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(.horizontal, 16)
                    
                    Divider()
                    
                    // MARK: - Comments
                    CommentBox(review: review)
                        .padding(.horizontal, 10)
                }
                .padding(.vertical, 8)
            }
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .navigationTitle("Review")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Rating Row
struct RatingRow: View {
    let label: String
    let rating: Double

    var body: some View {
        HStack(spacing: 8) {
            Text(label)
                .font(.system(size: 14))
                .frame(width: 100, alignment: .leading)
            StarRatingView(rating: rating)
            Spacer()
        }
    }
}
