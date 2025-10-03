import Foundation
import SwiftUI

class BusSearchService {
    static func searchBus(with name: String, completion: @escaping (Result<[Bus], Error>) -> Void) {
        guard let url = URL(string: API.Endpoints.busSearch) else {
            completion(.failure(URLError(.badURL)))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let body = "bus_name=\(name)"
        request.httpBody = body.data(using: .utf8)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }

            guard let data = data else {
                DispatchQueue.main.async {
                    completion(.failure(URLError(.badServerResponse)))
                }
                return
            }

            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let busData = json["buses"] as? [[String: Any]] {
                    let decodedData = try JSONSerialization.data(withJSONObject: busData)
                    let buses = try JSONDecoder().decode([Bus].self, from: decodedData)
                    DispatchQueue.main.async {
                        completion(.success(buses))
                    }
                } else {
                    DispatchQueue.main.async {
                        completion(.failure(URLError(.cannotParseResponse)))
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }.resume()
    }
}
