import Foundation

func postComment(reviewID: Int, commentText: String, onSuccess: @escaping () -> Void, onError: @escaping (String) -> Void) {
    let userID = UserDefaults.standard.integer(forKey: "storedUserID")
    guard userID != 0 else {
        onError("User not logged in.")
        return
    }

    guard let url = URL(string: API.Endpoints.commentReviews) else {
        onError("Invalid URL.")
        return
    }

    var request = URLRequest(url: url)
    request.httpMethod = "POST"

    let payload: [String: Any] = [
        "review_id": reviewID,
        "user_id": userID,
        "comment_text": commentText
    ]

    do {
        request.httpBody = try JSONSerialization.data(withJSONObject: payload)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    } catch {
        onError("Failed to encode data.")
        return
    }

    URLSession.shared.dataTask(with: request) { data, response, error in
        DispatchQueue.main.async {
            if let error = error {
                onError("Network error: \(error.localizedDescription)")
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                onError("No response from server.")
                return
            }

            if httpResponse.statusCode == 200 {
                onSuccess()
            } else {
                onError("Server error. Code: \(httpResponse.statusCode)")
            }
        }
    }.resume()
}
