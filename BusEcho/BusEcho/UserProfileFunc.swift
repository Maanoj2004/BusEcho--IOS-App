import Foundation

func fetchUserProfile(userID: Int, completion: @escaping (Result<UserProfile, Error>) -> Void) {
    guard let url = URL(string: API.Endpoints.userProfile+"?id=\(userID)") else {
        completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
        return
    }

    URLSession.shared.dataTask(with: url) { data, response, error in
        if let error = error {
            print("Network error: \(error.localizedDescription)")
            completion(.failure(error))
            return
        }

        if let httpResponse = response as? HTTPURLResponse {
            print("HTTP Status Code: \(httpResponse.statusCode)")
        }

        guard let data = data else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
            return
        }

        print("Raw response string:\n\(String(data: data, encoding: .utf8) ?? "Unable to decode")")

        do {
            if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
               let status = json["status"] as? String, status == "success",
               let userDict = json["user"] as? [String: Any],
               let userData = try? JSONSerialization.data(withJSONObject: userDict) {
                
                let profile = try JSONDecoder().decode(UserProfile.self, from: userData)
                completion(.success(profile))
            } else {
                completion(.failure(NSError(domain: "", code: -2, userInfo: [NSLocalizedDescriptionKey: "Invalid JSON structure or status"])))
            }
        } catch {
            print("JSON decoding error: \(error)")
            completion(.failure(error))
        }
    }.resume()
}
