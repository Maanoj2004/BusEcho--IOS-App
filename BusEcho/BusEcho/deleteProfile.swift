import Foundation
import SwiftUI

func sendDeleteOTP(userID: Int, completion: @escaping (Bool, String) -> Void) {
    guard let url = URL(string: API.Endpoints.deletProfile) else {
        completion(false, "Invalid URL")
        return
    }

    let parameters = [
        "id": "\(userID)"
    ]

    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.httpBody = parameters
        .map { "\($0.key)=\($0.value)" }
        .joined(separator: "&")
        .data(using: .utf8)

    request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

    URLSession.shared.dataTask(with: request) { data, response, error in
        if let error = error {
            completion(false, "Error: \(error.localizedDescription)")
            return
        }

        guard let data = data else {
            completion(false, "No data received.")
            return
        }

        do {
            if let result = try JSONSerialization.jsonObject(with: data) as? [String: Any],
               let status = result["status"] as? String,
               let message = result["message"] as? String {
                completion(status == "success", message)
            } else {
                completion(false, "Unexpected response format.")
            }
        } catch {
            completion(false, "JSON parsing error: \(error)")
        }
    }.resume()
}


func verifyAndDeleteAccount(userID: Int, otp: String, completion: @escaping (Bool, String) -> Void) {
    guard let url = URL(string: API.Endpoints.deleteOTP) else {
        completion(false, "Invalid URL")
        return
    }

    let parameters = [
        "id": "\(userID)",
        "otp": otp
    ]

    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.httpBody = parameters
        .map { "\($0.key)=\($0.value)" }
        .joined(separator: "&")
        .data(using: .utf8)

    request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

    URLSession.shared.dataTask(with: request) { data, response, error in
        if let error = error {
            completion(false, "Error: \(error.localizedDescription)")
            return
        }

        guard let data = data else {
            completion(false, "No data received.")
            return
        }
        
        do {
            if let result = try JSONSerialization.jsonObject(with: data) as? [String: Any],
               let status = result["status"] as? String,
               let message = result["message"] as? String {
                completion(status == "success", message)
            } else {
                completion(false, "Unexpected response format.")
            }
        } catch {
            completion(false, "JSON parsing error: \(error)")
        }
    }.resume()
}

