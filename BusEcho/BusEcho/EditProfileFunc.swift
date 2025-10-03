import Foundation

// MARK: Verify OTP
func verifyOTP(userID: Int, otp: String, completion: @escaping (Result<Bool, Error>) -> Void) {
    guard let url = URL(string: API.Endpoints.profileOTP) else { return }

    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

    let bodyString = "id=\(userID)&otp=\(otp)"
    request.httpBody = bodyString.data(using: .utf8)

    URLSession.shared.dataTask(with: request) { data, response, error in
        if let error = error {
            completion(.failure(error))
            return
        }

        guard let data = data else {
            completion(.failure(NSError(domain: "No Data", code: 0)))
            return
        }

        do {
            if let result = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
               let status = result["status"] as? String {
                completion(.success(status == "success"))
            } else {
                completion(.success(false))
            }
        } catch {
            completion(.failure(error))
        }
    }.resume()
}


enum SaveProfileResult {
    case success(String)       // Profile updated successfully
    case otpRequired(String)   // OTP required for email/phone change
    case failure(Error)        // Any other failure
}


func saveProfileChanges(userID: Int, name: String, username: String, email: String, phone: String, bio: String, completion: @escaping (SaveProfileResult) -> Void) {
    guard let url = URL(string: API.Endpoints.editProfile) else { return }

    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

    let params: [String: String] = [
        "id": String(userID),
        "name": name,
        "username": username,
        "mail_id": email,
        "phone_num": phone,
        "bio": bio
    ]

    let bodyString = params
        .map { "\($0.key)=\($0.value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")" }
        .joined(separator: "&")

    request.httpBody = bodyString.data(using: .utf8)

    URLSession.shared.dataTask(with: request) { data, response, error in
        if let error = error {
            completion(.failure(error))
            return
        }

        guard let data = data else {
            completion(.failure(NSError(domain: "NoData", code: 0)))
            return
        }

        do {
            if let result = try JSONSerialization.jsonObject(with: data) as? [String: Any],
               let status = result["status"] as? String,
               let message = result["message"] as? String {

                switch status {
                case "success":
                    completion(.success(message))
                case "otp_required":
                    completion(.otpRequired(message))  // ✅ new case
                default:
                    completion(.failure(NSError(domain: "UpdateFailed", code: 1, userInfo: [NSLocalizedDescriptionKey: message])))
                }
            } else {
                completion(.failure(NSError(domain: "InvalidResponse", code: 2)))
            }
        } catch {
            completion(.failure(error))
        }
    }.resume()
}
