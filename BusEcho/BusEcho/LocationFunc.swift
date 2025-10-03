import Foundation

class PlaceSearchViewModel: ObservableObject {
    @Published var places: [Place] = []
    @Published var searchResults: [Place] = []

    func fetchPlaces() {
        guard let url = URL(string: API.Endpoints.locations) else { return }
        print("Fetching places...")
        URLSession.shared.dataTask(with: url) { data, _, _ in
            if let data = data {
                do {
                    let decoded = try JSONDecoder().decode([Place].self, from: data)
                    DispatchQueue.main.async {
                        self.places = decoded
                        self.searchResults = decoded
                        print("✅ Fetched places count: \(decoded.count)")
                    }
                } catch {
                    print("❌ JSON Decode failed:", error)
                    print(String(data: data, encoding: .utf8) ?? "No raw data")
                }
            } else {
                print("❌ No data received from API.")
            }
        }.resume()
    }

    func filterPlaces(query: String) {
        if query.isEmpty {
            searchResults = places
        } else {
            searchResults = places.filter { $0.name.lowercased().contains(query.lowercased()) }
        }
    }
}
