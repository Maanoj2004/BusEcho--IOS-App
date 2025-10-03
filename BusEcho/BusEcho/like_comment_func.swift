import SwiftUI



func toggleLike(reviewID: Int, completion: @escaping (Bool, Bool?) -> Void) {
    let userID = UserDefaults.standard.integer(forKey: "storedUserID")
    guard userID != 0 else {
        print("User ID not found")
        completion(false, nil)
        return
    }

    guard let url = URL(string: API.Endpoints.likeReviews) else {
        print("Invalid URL")
        completion(false, nil)
        return
    }

    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    
    let payload: [String: Any] = [
        "review_id": reviewID,
        "user_id": userID
    ]
    
    do {
        request.httpBody = try JSONSerialization.data(withJSONObject: payload)
    } catch {
        print("JSON Serialization Error: \(error)")
        completion(false, nil)
        return
    }

    URLSession.shared.dataTask(with: request) { data, response, error in
        if let error = error {
            print("Request Error: \(error)")
            completion(false, nil)
            return
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            print("No HTTP Response")
            completion(false, nil)
            return
        }

        guard httpResponse.statusCode == 200 else {
            print("Status Code: \(httpResponse.statusCode)")
            if let data = data {
                print("Response: \(String(data: data, encoding: .utf8) ?? "")")
            }
            completion(false, nil)
            return
        }

        guard let data = data else {
            print("No data in response")
            completion(false, nil)
            return
        }

        do {
            let decoded = try JSONDecoder().decode(LikeResponse.self, from: data)
            completion(decoded.success, decoded.liked)
        } catch {
            print("Decoding error: \(error)")
            completion(false, nil)
        }
    }.resume()
}
