import Foundation

struct BusService {
    static func submitBus(
        busOperator: String,
        boardingPoint: String,
        droppingPoint: String,
        busType: String,
        acType: String,
        completion: @escaping (Result<[String: Any], Error>) -> Void
    ) {
        guard let url = URL(string: API.Endpoints.addbus) else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        let postString = "bus_operator=\(busOperator)&boarding_point=\(boardingPoint)&dropping_point=\(droppingPoint)&bus_type=\(busType)&ac_type=\(acType)"
        request.httpBody = postString.data(using: .utf8)
        
        URLSession.shared.dataTask(with: request) { data, _, error in
            
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received from server"])))
                return
            }
            
            // Debug: print raw server response
            if let rawString = String(data: data, encoding: .utf8) {
                print("🔍 Raw Response from Server:\n\(rawString)")
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    completion(.success(json))
                } else {
                    completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Server response is not a JSON object"])))
                }
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}
