import Foundation

func signupUser(name: String, username: String, mail_id: String, password: String, phone_num: String, completion: @escaping (Result<String, Error>) -> Void) {
    guard let url = URL(string: API.Endpoints.userRegister) else {
        completion(.failure(NSError(domain: "Invalid URL", code: 0)))
        return
    }

    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

    let params = "name=\(name)&username=\(username)&mail_id=\(mail_id)&password=\(password)&phone_num=\(phone_num)"
    request.httpBody = params.data(using: .utf8)

    URLSession.shared.dataTask(with: request) { data, response, error in
        if let error = error {
            completion(.failure(error))
            return
        }

        guard let data = data else {
            completion(.failure(NSError(domain: "No data", code: 0)))
            return
        }

        do {
            let decoded = try JSONDecoder().decode(SignupResponse.self, from: data)
            if decoded.status == "success", let name = decoded.name {
                completion(.success(name))
            } else {
                if let message = decoded.message {
                    completion(.failure(SignupError.message(message)))
                } else {
                    completion(.failure(SignupError.unknown))
                }

            }
        } catch {
            print("Decoding error:", String(data: data, encoding: .utf8) ?? "")
            completion(.failure(error))
        }
    }.resume()
}





enum SignupError: LocalizedError {
    case message(String)
    case unknown

    var errorDescription: String? {
        switch self {
        case .message(let msg): return msg
        case .unknown: return "An unknown error occurred."
        }
    }
}

