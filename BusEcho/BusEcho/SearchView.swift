//import SwiftUI
//
//import SwiftUI
//
//struct SearchView: View {
//    @State private var searchText = ""
//    @State private var showFilter = false
//
//    var body: some View {
//        GeometryReader { geo in
//            VStack(spacing: 20) {
//                HStack {
//                    CustomTextField(title: "Search", text: $searchText)
//                        .frame(height: 40)
//                        .padding(.leading, 16)
//
//                    Button(action: {}) {
//                        Image(systemName: "magnifyingglass")
//                            .frame(width: 40, height: 40)
//                            .background(Color(hex: "2A3B7F"))
//                            .clipShape(Circle())
//                            .foregroundColor(.white)
//                    }
//                    .padding(.trailing, 16)
//                }
//                .padding(.top, 20)
//
////                HStack {
////                    Spacer()
////                    Button(action: {
////                        showFilter = true
////                    }) {
////                        Label("Filter", systemImage: "slider.horizontal.3")
////                            .padding(.horizontal)
////                            .padding(.vertical, 10)
////                            .frame(maxWidth: geo.size.width * 0.3)
////                            .background(Color(hex: "8DD0F0"))
////                            .foregroundColor(Color(hex: "2A3B7F"))
////                            .cornerRadius(12)
////                            .shadow(color: .gray.opacity(0.3), radius: 4, x: 0, y: 2)
////                    }
////                    .padding(.horizontal)
////                }
//
//                Spacer()
//            }
//            .padding(.horizontal,10)
//            .frame(width: geo.size.width, height: geo.size.height)
//        }
////        .sheet(isPresented: $showFilter) {
////            FilterView()
////        }
//    }
//}
//
////struct FilterView: View {
////    @Environment(\.presentationMode) var presentationMode
////
////    @State private var boardingPoint = ""
////    @State private var selectedBoarding: Place? = nil
////    @State private var droppingPoint = ""
////    @State private var selectedDropping: Place? = nil
////    @State private var selectedACType = ""
////    @State private var selectedRating = 0
////    @State private var selectedTime = ""
////
////    @StateObject var boardingVM = PlaceSearchViewModel()
////    @StateObject var droppingVM = PlaceSearchViewModel()
////
////    var body: some View {
////        NavigationView {
////            ScrollView {
////                LazyVStack(spacing: 20) {
////                    GroupBox(label: Label("Boarding Point", systemImage: "bus")) {
////                        LocationSearchField(viewModel: boardingVM, title: "Boarding Point", searchText: $boardingPoint, selectedPlace: $selectedBoarding, icon: "map")
////                    }
////
////                    GroupBox(label: Label("Dropping Point", systemImage: "bus")) {
////                        LocationSearchField(viewModel: droppingVM, title: "Dropping Point", searchText: $droppingPoint, selectedPlace: $selectedDropping, icon: "map")
////                    }
////
////                    GroupBox(label: Label("AC Type", systemImage: "wind")) {
////                        HStack(spacing: 20) {
////                            OptionButton(title: "AC", isSelected: selectedACType == "AC") {
////                                selectedACType = "AC"
////                            }
////                            OptionButton(title: "Non-AC", isSelected: selectedACType == "Non-AC") {
////                                selectedACType = "Non-AC"
////                            }
////                        }
////                        .padding(.top, 6)
////                    }
////
////                    GroupBox(label: Label("Minimum Rating", systemImage: "star.fill")) {
////                        StarPicker(rating: $selectedRating)
////                            .padding(.top, 5)
////                    }
////
////                    Button(action: {
////                        presentationMode.wrappedValue.dismiss()
////                    }) {
////                        Text("Apply Filters")
////                            .fontWeight(.semibold)
////                            .frame(maxWidth: .infinity)
////                            .padding()
////                            .background(Color(hex: "2A3B7F"))
////                            .foregroundColor(.white)
////                            .cornerRadius(12)
////                            .shadow(color: .gray.opacity(0.3), radius: 4, x: 0, y: 2)
////                    }
////                }
////                .padding()
////                .frame(maxWidth: .infinity)
////            }
////            .navigationTitle("Filter Options")
////            .navigationBarTitleDisplayMode(.inline)
////            .background(Color(.systemGroupedBackground))
////        }
////    }
////}

import SwiftUI

struct SearchView: View {
    @Binding var selectedTab: Tab
    @State private var searchText = ""
    @State private var isLoading = false
    @State private var buses: [Bus] = []

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                VStack {
                    HStack {
                        Text("Search Bus")
                            .font(.title)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                        Spacer()
                    }
                    .padding(.leading, 16)
                    .padding(.top, 16)

                    HStack {
                        CustomTextField(title: "Search bus", text: $searchText)
                            .padding(12)
                            .cornerRadius(20)
                            .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 2)
                            .padding(.leading, 16)
                        
                        Button(action: {
                            searchBus()
                        }) {
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 18, weight: .semibold))
                                .frame(width: 44, height: 44)
                                .background(
                                    LinearGradient(colors: [Color.blue, Color.purple],
                                                   startPoint: .topLeading,
                                                   endPoint: .bottomTrailing)
                                )
                                .clipShape(Circle())
                                .foregroundColor(.white)
                                .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
                        }
                        .padding(.trailing, 16)
                    }
                }
                .background(
                    LinearGradient(colors: [Color(hex: "2A3B7F"), Color.purple.opacity(0.8)],
                                   startPoint: .leading,
                                   endPoint: .trailing)
                        .ignoresSafeArea(edges: .top)
                )

                if isLoading {
                    Spacer()
                    ProgressView("Searching buses...")
                        .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                        .padding()
                    Spacer()
                }
                // MARK: - Search Results (Card Style)
                else if !buses.isEmpty {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(buses) { bus in
                                NavigationLink(destination: BusProfileView(bus: bus)) {
                                    VStack(alignment: .leading, spacing: 8) {
                                        HStack {
                                            Image(systemName: "bus.fill")
                                                .foregroundColor(.white)
                                                .padding(12)
                                                .background(
                                                    LinearGradient(colors: [Color.blue, Color.purple],
                                                                   startPoint: .topLeading,
                                                                   endPoint: .bottomTrailing)
                                                )
                                                .clipShape(Circle())
                                            
                                            VStack(alignment: .leading, spacing: 4) {
                                                Text(bus.bus_operator)
                                                    .font(.headline)
                                                    .foregroundColor(.primary)
                                                Text("\(bus.boarding_point) ➝ \(bus.dropping_point)")
                                                    .font(.subheadline)
                                                    .foregroundColor(.secondary)
                                            }
                                            Spacer()
                                        }

                                        HStack {
                                            Image(systemName: "star.fill")
                                                .foregroundColor(.yellow)
                                            Text(String(format: "%.1f", bus.average_rating))
                                                .fontWeight(.semibold)
                                            Text("(\(bus.total_reviews) reviews)")
                                                .foregroundColor(.secondary)
                                                .font(.caption)
                                        }
                                        .font(.subheadline)
                                    }
                                    .padding()
                                    .background(Color.white)
                                    .cornerRadius(12)
                                    .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                    }
                } else {
                    Spacer()
                    VStack(spacing: 12) {
                        Image(systemName: "magnifyingglass.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.blue.opacity(0.7))
                        Text("Search for buses")
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 30)
                    }
                    Spacer()
                }
            }
            .onChange(of: selectedTab) { oldValue, newValue in
                if newValue == .search {
                    refreshSearchIfNeeded()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
        }
    }
    
    func refreshSearchIfNeeded() {
        if !searchText.isEmpty {
            searchBus()
        }
    }
    
    func searchBus() {
        guard !searchText.isEmpty else { return }
        isLoading = true
        buses = []

        BusSearchService.searchBus(with: searchText) { result in
            isLoading = false
            switch result {
            case .success(let fetchedBuses):
                self.buses = fetchedBuses
            case .failure(let error):
                print("Search failed: \(error)")
            }
        }
    }
}
