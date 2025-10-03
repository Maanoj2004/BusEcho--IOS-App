import SwiftUI

struct CommentResponse: Codable {
    let status: String
    let comments: [CommentModel]?
    let message: String?
}

struct CommentBox: View {
    let review: ReviewModel
    @AppStorage("storedUserID") private var storedUserID: Int?
    @State private var newComment: String = ""
    @State private var comments: [CommentModel] = []
    @State private var userProfile: UserProfile?
    @State private var user: String?
    
    // Timer to poll for new comments
    let timer = Timer.publish(every: 5, on: .main, in: .common).autoconnect()

    var body: some View {
        VStack(spacing: 0) {
            
            // Title
            Text("Comments")
                .font(.title2.bold())
                .foregroundColor(Color(hex: "2A3B7F"))
                .padding(.vertical, 8)
            
            // Comments list
            ScrollView {
                if comments.isEmpty {
                    VStack(spacing: 8) {
                        Image(systemName: "text.bubble")
                            .font(.system(size: 30))
                            .foregroundColor(.gray.opacity(0.6))
                        Text("No comments yet.\nBe the first to share your thoughts!")
                            .foregroundColor(.gray)
                            .font(.subheadline)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity, minHeight: 150)
                    .padding(.top, 30)
                } else {
                    LazyVStack(alignment: .leading, spacing: 14) {
                        ForEach(comments, id: \.comment_id) { comment in
                            HStack(alignment: .top, spacing: 10) {
                                
                                // Avatar Circle
                                Circle()
                                    .fill(avatarColor(for: comment.user_id))
                                    .frame(width: 40, height: 40)
                                    .overlay(
                                        Text(comment.username?.prefix(1).uppercased() ?? "U")
                                            .font(.headline)
                                            .foregroundColor(.white)
                                    )
                                
                                // Comment Bubble
                                VStack(alignment: .leading, spacing: 6) {
                                    HStack {
                                        Text(comment.username ?? "User \(comment.user_id)")
                                            .font(.subheadline.bold())
                                            .foregroundColor(Color(hex: "2A3B7F"))
                                        Spacer()
                                        Text(comment.commented_at)
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                                    
                                    Text(comment.comment_text)
                                        .font(.body)
                                        .foregroundColor(.primary)
                                        .padding(10)
                                        .background(
                                            LinearGradient(
                                                colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.1)],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                        .cornerRadius(12)
                                }
                            }
                            .padding(.horizontal, 16)
                        }
                    }
                    .padding(.top, 12)
                }
            }
            
            Divider().padding(.vertical, 8)
            
            // Input section
            HStack(spacing: 12) {
                TextField("Add a comment...", text: $newComment, axis: .vertical)
                    .textFieldStyle(PlainTextFieldStyle())
                    .padding(10)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(20)
                    .lineLimit(3)
                
                Button(action: postComment) {
                    Image(systemName: "paperplane.fill")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(12)
                        .background(
                            LinearGradient(colors: [Color.blue, Color.purple],
                                           startPoint: .topLeading,
                                           endPoint: .bottomTrailing)
                        )
                        .clipShape(Circle())
                        .shadow(radius: 2)
                }
                .disabled(newComment.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                .opacity(newComment.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.5 : 1)
            }
            .padding(.horizontal)
            .padding(.bottom, 8)
        }
        .onAppear {
            fetchComments()
            if let userID = storedUserID {
                fetchUserProfile(userID: userID) { result in
                    switch result {
                    case .success(let profile):
                        DispatchQueue.main.async {
                            self.userProfile = profile
                            self.user = profile.username
                        }
                    case .failure(let error):
                        print("Failed to fetch user profile:", error)
                    }
                }
            }
        }
        .onReceive(timer) { _ in
            fetchComments()
        }
    }
    
    // MARK: - Avatar Color Generator
    private func avatarColor(for userId: Int) -> Color {
        let colors: [Color] = [.blue, .green, .orange, .pink, .purple, .teal, .indigo, .red]
        return colors[userId % colors.count]
    }
    
    // MARK: - Fetch Comments
    func fetchComments() {
        guard let url = URL(string: API.Endpoints.fetchComments+"?review_id=\(review.review_id)") else {
            print("Invalid fetch URL")
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error fetching comments:", error)
                return
            }

            guard let data = data else { return }
            do {
                let decoder = JSONDecoder()
                let response = try decoder.decode(CommentResponse.self, from: data)
                if response.status == "success", let fetchedComments = response.comments {
                    DispatchQueue.main.async {
                        self.comments = fetchedComments
                    }
                } else {
                    print("Failed to fetch: \(response.message ?? "No message")")
                }
            } catch {
                print("Decoding error:", error)
            }
        }.resume()
    }

    // MARK: - Post Comment
    func postComment() {
        guard let userID = storedUserID else {
            print("User not logged in")
            return
        }

        let trimmedComment = newComment.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedComment.isEmpty else { return }

        guard let url = URL(string: API.Endpoints.commentReviews) else {
            print("Invalid post URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let body = "review_id=\(review.review_id)&user_id=\(userID)&comment_text=\(trimmedComment)"
        request.httpBody = body.data(using: .utf8)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error posting comment:", error)
                return
            }

            DispatchQueue.main.async {
                newComment = ""
                fetchComments() // Refresh full comments immediately
            }
        }.resume()
    }
}
