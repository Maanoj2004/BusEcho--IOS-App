import SwiftUI

struct ReviewTile: View {
    var review: ReviewModel
    
    @State private var isLiked: Bool
    @State private var likeCount: Int
    let screenWidth = UIScreen.main.bounds.width
    
    init(review: ReviewModel) {
        self.review = review
        _isLiked = State(initialValue: review.user_liked)
        _likeCount = State(initialValue: review.like_count)
    }

    var body: some View {
        NavigationLink(destination: ReviewDetailView(review: review)) {
            VStack(alignment: .leading, spacing: 8) {
                
                // Header with gradient
                HStack(alignment: .center, spacing: 12) {
                    Image(systemName: "bus.fill")
                        .foregroundColor(.white)
                        .padding(12)
                        .background(
                            LinearGradient(colors: [Color.blue, Color.purple],
                                           startPoint: .topLeading,
                                           endPoint: .bottomTrailing)
                        )
                        .clipShape(Circle())
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(review.bus_operator)
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        Text("\(review.boarding_point) ➜ \(review.dropping_point)")
                            .font(.system(size: screenWidth * 0.03, weight: .light))
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    StarRatingView(rating: review.overall_rating)
                }
                .padding(12)
                .background(Color.blue.opacity(0.1).cornerRadius(12))
                
                // Optional Image
                if let firstImage = review.images.first,
                   let url = URL(string: API.baseURL+"\(firstImage)") {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                                .scaledToFill()
                                .frame(width:350,height: 200)
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(12)
                                .padding(.horizontal,10)
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(width:350,height: 200)
                                .clipped()
                                .cornerRadius(12)
                                .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                                .padding(.horizontal,10)
                        case .failure(_):
                            EmptyView()
                        @unknown default:
                            EmptyView()
                        }
                    }
                }

                // Review text
                Text(review.review_text)
                    .font(.body)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.leading)
                    .lineLimit(3)
                    .padding(.horizontal, 8)
                
                // Likes & Comments
                HStack(spacing: 12) {
                    Button {
                        toggleLike(reviewID: review.id) { success, isNowLiked in
                            if success, let isNowLiked = isNowLiked {
                                isLiked = isNowLiked
                                likeCount += isNowLiked ? 1 : -1
                            }
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: isLiked ? "heart.fill" : "heart")
                                .foregroundColor(isLiked ? .red : .blue)
                            Text("\(likeCount)")
                                .font(.subheadline)
                                .foregroundColor(.blue)
                        }
                        .padding(6)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(8)
                    }
                    
                    NavigationLink(destination: CommentBox(review: review)) {
                        HStack(spacing: 4) {
                            Image(systemName: "bubble.right.fill")
                                .foregroundColor(.green)
                            Text("\(review.comment_count)")
                                .font(.subheadline)
                                .foregroundColor(.green)
                        }
                        .padding(6)
                        .background(Color.green.opacity(0.1))
                        .cornerRadius(8)
                    }
                    
                    Spacer()
                    Text(review.created_at_formatted)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 8)
                .padding(.bottom, 8)
            }
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
            .padding(.vertical, 4)
        }
    }
}
