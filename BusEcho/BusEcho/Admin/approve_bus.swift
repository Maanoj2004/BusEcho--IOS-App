import SwiftUI

struct PendingApprovalsView: View {
    @State private var isLoading = true
    @State private var pendingBuses: [Bus] = []
    @State private var searchText: String = ""

    var filteredBuses: [Bus] {
        if searchText.isEmpty {
            return pendingBuses
        } else {
            return pendingBuses.filter { $0.bus_operator.localizedCaseInsensitiveContains(searchText) }
        }
    }

    func fetchPendingBuses() {
        guard let url = URL(string: API.Endpoints.fetchBuses+"?status=pending") else { return }

        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else { return }
            do {
                let result = try JSONDecoder().decode([Bus].self, from: data)
                DispatchQueue.main.async {
                    self.pendingBuses = result
                }
            } catch {
                print("Decoding error:", error)
            }
        }.resume()
    }

    func updateBusStatus(busId: Int, newStatus: String) {
        guard let url = URL(string: "http://localhost/busreview/approve_bus_admin.php") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let body = "bus_id=\(busId)&status=\(newStatus)"
        request.httpBody = body.data(using: .utf8)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        URLSession.shared.dataTask(with: request) { data, _, error in
            guard let data = data, error == nil else { return }
            if let response = try? JSONDecoder().decode(ServerResponse.self, from: data) {
                print(response.message)
                // Refresh list after action
                fetchPendingBuses()
            }
        }.resume()
    }

    var body: some View {
        NavigationView {
            List(filteredBuses) { bus in
                VStack(alignment: .leading, spacing: 6) {
                    Text(bus.bus_operator)
                        .font(.title3.bold())

                    HStack {
                        Button("Approve") {
                            updateBusStatus(busId: bus.bus_id, newStatus: "approved")
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.green)

                        Button("Reject") {
                            updateBusStatus(busId: bus.bus_id, newStatus: "rejected")
                        }
                        .buttonStyle(.bordered)
                        .tint(.red)
                    }
                }
                .padding(.vertical, 8)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .listStyle(.plain)
            .navigationTitle("Pending Buses")
            .searchable(text: $searchText, prompt: "Search bus operator")
        }
        .onAppear(perform: fetchPendingBuses)
    }
}

#Preview {
    PendingApprovalsView()
}
