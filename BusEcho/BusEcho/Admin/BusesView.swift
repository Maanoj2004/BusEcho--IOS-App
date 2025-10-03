import SwiftUI

struct BusesView: View {
    @State private var isLoading = true
    @State private var buses: [Bus] = []
    @State private var searchText: String = ""
    @State private var hasPending: Bool = false   // 👈 Track pending status
    @Environment(\.horizontalSizeClass) var sizeClass
    
    // Filtered result based on search text
    var filteredBuses: [Bus] {
        if searchText.isEmpty {
            return buses
        } else {
            return buses.filter { $0.bus_operator.localizedCaseInsensitiveContains(searchText) }
        }
    }

    func fetchBuses() {
        guard let url = URL(string: API.Endpoints.fetchBuses+"?status=approved") else { return }

        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else { return }
            do {
                let result = try JSONDecoder().decode([Bus].self, from: data)
                DispatchQueue.main.async {
                    self.buses = result
                }
            } catch {
                print("Decoding error:", error)
            }
        }.resume()
    }

    // 👇 Function to check pending buses count
    func checkPending() {
        guard let url = URL(string: "http://localhost/busreview/fetch_buses.php?status=pending") else { return }

        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else { return }
            do {
                let result = try JSONDecoder().decode([Bus].self, from: data)
                DispatchQueue.main.async {
                    self.hasPending = !result.isEmpty   // true if pending exists
                }
            } catch {
                print("Pending check decoding error:", error)
            }
        }.resume()
    }

    var body: some View {
        NavigationView {
            GeometryReader { geo in
                List(filteredBuses) { bus in
                    NavigationLink(destination: BusProfileView(bus: bus)) {
                        VStack(alignment: .leading, spacing: sizeClass == .compact ? 6 : 10) {
                            Text(bus.bus_operator)
                                .font(sizeClass == .compact ? .title3.bold() : .title2.bold())
                                .lineLimit(1)
                                .minimumScaleFactor(0.8)

                            HStack(spacing: 6) {
                                Image(systemName: "star.fill")
                                    .foregroundColor(.yellow)
                                Text(String(format: "%.1f", Double(bus.average_rating) ?? 0))
                                Text("• \(bus.total_reviews) reviews")
                            }
                            .font(sizeClass == .compact ? .footnote : .callout)
                            .foregroundColor(.secondary)
                        }
                        .padding(.vertical, sizeClass == .compact ? 10 : 14)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .listRowBackground(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(Color(.systemGray6))
                            .padding(.vertical, 4)
                    )
                }
                .listStyle(.plain)
                .padding(.horizontal, sizeClass == .compact ? 10 : 20)
                .navigationTitle("Buses")
                .searchable(text: $searchText, prompt: "Search bus operator")
                .toolbar {
                    NavigationLink(destination: PendingApprovalsView()) {
                        Label("Pending", systemImage: hasPending ? "clock.badge.exclamationmark" : "clock")
                            .symbolRenderingMode(.multicolor)
                    }
                }
            }
        }
        .onAppear {
            fetchBuses()
            checkPending()
        }
    }
}

#Preview {
    BusesView()
}
