//
//  LoginModel.swift
//  BusEcho
//
//  Created by user1 on 26/07/25.
//

import Foundation

enum LoginError: LocalizedError {
    case custom(String)
    
    var errorDescription: String? {
        switch self {
        case .custom(let message):
            return message
        }
    }
}

func loginUser(input: String, password: String, completion: @escaping (Result<(Int, String, String), Error>) -> Void) {
    guard let url = URL(string: API.Endpoints.userLogin) else {
        completion(.failure(LoginError.custom("Invalid server URL.")))
        return
    }
    
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    
    let parameters = [
        "username": input,
        "password": password
    ]
    
    request.httpBody = parameters
        .compactMap { "\($0.key)=\($0.value)" }
        .joined(separator: "&")
        .data(using: .utf8)
    
    request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
    
    URLSession.shared.dataTask(with: request) { data, _, error in
        if let error = error {
            completion(.failure(LoginError.custom("Network error: \(error.localizedDescription)")))
            return
        }
        
        guard let data = data else {
            completion(.failure(LoginError.custom("No response from server.")))
            return
        }
        
        do {
            if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                if let status = json["status"] as? String, status == "success" {
                    let id = json["user_id"] as? Int ?? 0
                    let name = json["name"] as? String ?? "User"
                    let role = json["role"] as? String ?? "user"
                    completion(.success((id, name, role)))
                    print(ResponseMessage.init(status: "success", message: role))
                } else if let message = json["message"] as? String {
                    let readableMessage: String
                    switch message {
                    case "user_not_found":
                        readableMessage = "User not found. Please check your username."
                    case "incorrect_password":
                        readableMessage = "Incorrect password. Please try again."
                    default:
                        readableMessage = message
                    }
                    completion(.failure(LoginError.custom(readableMessage)))
                }
                else {
                    completion(.failure(LoginError.custom("Unexpected server response.")))
                }
            } else {
                completion(.failure(LoginError.custom("Failed to parse server response.")))
            }
        } catch {
            completion(.failure(LoginError.custom("Error decoding response.")))
        }
    }.resume()
}
