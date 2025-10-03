import Foundation
import SwiftUI

class BusOperatorViewModel: ObservableObject {
    @Published var allOperators: [BusOperator] = []
    @Published var filteredOperators: [BusOperator] = []

    func fetchOperators() {
        print("Fetching")
        guard let url = URL(string: API.Endpoints.busOperator) else {
            print("❌ Invalid URL")
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("❌ Error fetching data:", error.localizedDescription)
                return
            }

            guard let data = data else {
                print("❌ No data returned")
                return
            }

            // Debug print
            print("✅ Raw JSON:", String(data: data, encoding: .utf8) ?? "Invalid")

            do {
                let decoded = try JSONDecoder().decode([BusOperator].self, from: data)
                DispatchQueue.main.async {
                    self.allOperators = decoded
                    self.filteredOperators = decoded
                    print("✅ Operators Loaded: \(decoded.count)")
                }
            } catch {
                print("❌ JSON Decoding error:", error.localizedDescription)
            }
        }.resume()
    }


    func filterOperators(by keyword: String) {
        filteredOperators = keyword.isEmpty
            ? allOperators
            : allOperators.filter { $0.bus_operator.localizedCaseInsensitiveContains(keyword) }
    }
}

struct BusOperatorPicker: View {
    @Binding var busOperator: String
    @ObservedObject var viewModel: BusOperatorViewModel
    @State private var showSuggestions = false
    @State private var textFieldHeight: CGFloat = 0

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            CustomPicker(title: "Search bus operator", text: $busOperator,icon: "bus")
                .onChange(of: busOperator) {oldValue, newValue in
                    viewModel.filterOperators(by: newValue)
                    showSuggestions = !newValue.isEmpty
                }
            if showSuggestions {
                VStack(alignment: .leading, spacing: 0) {
                    if viewModel.filteredOperators.isEmpty {
                        Text("No matches found")
                            .foregroundColor(.gray)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.white)
                            .cornerRadius(10)
                            .shadow(radius: 2)
                    } else {
                        ScrollView {
                            VStack(spacing: 0) {
                                ForEach(viewModel.filteredOperators, id: \.bus_id) { bus in
                                    Button(action: {
                                        busOperator = bus.bus_operator
                                        showSuggestions = false
                                    }) {
                                        HStack {
                                            Text(bus.bus_operator)
                                                .foregroundColor(.primary)
                                                .padding(.vertical, 8)
                                            Spacer()
                                        }
                                        .padding(.horizontal)
                                        .background(Color.white)
                                    }
                                }
                            }
                        }
                        .frame(maxHeight: 35)
                        .background(Color.white)
                        .cornerRadius(10)
                        .shadow(radius: 4)
                    }
                }
                .padding(.top, textFieldHeight + 4)
            }
        }
    }
}
