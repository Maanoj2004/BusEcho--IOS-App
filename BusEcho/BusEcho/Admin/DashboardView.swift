//import SwiftUI
//
//struct DashboardStats: Decodable {
//    let users: Int
//    let buses: Int
//    let reviews: Int
//    let lost_found: Int
//    let comments: Int
//    let likes: Int
//}
//
//struct DashboardView: View {
//    @State private var stats: DashboardStats? = nil
//    @State private var isLoading = true
//    @State private var animateCards = false
//    
//    let columns = [
//        GridItem(.flexible(), spacing: 16),
//        GridItem(.flexible(), spacing: 16)
//    ]
//    
//    var body: some View {
//        ScrollView {
//            VStack(alignment: .leading, spacing: 20) {
//                Text("📊 Dashboard")
//                    .font(.largeTitle)
//                    .fontWeight(.bold)
//                    .foregroundColor(Color(hex: "2A3B7F"))
//                    .padding(.top, 20)
//                    .padding(.horizontal, 10)
//                
//                if isLoading {
//                    ProgressView("Loading stats...")
//                        .padding(.top, 50)
//                        .progressViewStyle(CircularProgressViewStyle(tint: .blue))
//                        .scaleEffect(1.2)
//                } else if let stats = stats {
//                    LazyVGrid(columns: columns, spacing: 16) {
//                        StatCard(title: "Users", value: stats.users, gradient: Gradient(colors: [.blue, .purple]))
//                        StatCard(title: "Buses", value: stats.buses, gradient: Gradient(colors: [.green, .teal]))
//                        StatCard(title: "Reviews", value: stats.reviews, gradient: Gradient(colors: [.orange, .red]))
//                        StatCard(title: "Lost & Found", value: stats.lost_found, gradient: Gradient(colors: [.pink, .purple]))
//                        StatCard(title: "Comments", value: stats.comments, gradient: Gradient(colors: [.indigo, .cyan]))
//                        StatCard(title: "Likes", value: stats.likes, gradient: Gradient(colors: [.yellow, .orange]))
//                    }
//                    .padding(.horizontal)
//                    .padding(.bottom, 30)
//                    .scaleEffect(animateCards ? 1 : 0.9)
//                    .animation(.spring(response: 0.6, dampingFraction: 0.7), value: animateCards)
//                } else {
//                    Text("❌ Failed to load stats.")
//                        .foregroundColor(.red)
//                        .padding(.top, 50)
//                }
//            }
//        }
//        .onAppear {
//            fetchStats()
//        }
//    }
//    
//    func fetchStats() {
//        guard let url = URL(string: "http://localhost/busreview/dashboard_stats.php") else { return }
//        URLSession.shared.dataTask(with: url) { data, _, _ in
//            DispatchQueue.main.async {
//                isLoading = false
//            }
//            if let data = data {
//                do {
//                    let decoded = try JSONDecoder().decode(DashboardStats.self, from: data)
//                    DispatchQueue.main.async {
//                        self.stats = decoded
//                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//                            animateCards = true
//                        }
//                    }
//                } catch {
//                    print("Decode error:", error)
//                }
//            }
//        }.resume()
//    }
//}
//
//struct StatCard: View {
//    let title: String
//    let value: Int
//    let gradient: Gradient
//    @State private var animatedValue: Int = 0
//    
//    var body: some View {
//        VStack(spacing: 10) {
//            Text(title)
//                .font(.headline)
//                .foregroundColor(.white)
//                .multilineTextAlignment(.center)
//            Text("\(animatedValue)")
//                .font(.largeTitle)
//                .bold()
//                .foregroundColor(.white)
//        }
//        .frame(maxWidth: .infinity, minHeight: 120)
//        .background(
//            LinearGradient(gradient: gradient, startPoint: .topLeading, endPoint: .bottomTrailing)
//        )
//        .cornerRadius(16)
//        .shadow(radius: 8)
//        .onAppear {
//            withAnimation(.easeOut(duration: 1.0)) {
//                animatedValue = value
//            }
//        }
//    }
//}
//
import SwiftUI
import Charts

struct DashboardStats: Decodable {
    let users: Int
    let buses: Int
    let reviews: Int
    let comments: Int
    let likes: Int
}

struct DashboardDataItem: Identifiable {
    let id = UUID()
    let title: String
    let value: Int
}

struct DashboardView: View {
    @State private var stats: DashboardStats? = nil
    @State private var isLoading = true
    @State private var animateCards = false
    @State private var selectedCategory: DashboardDataItem? = nil

    
    var chartData: [DashboardDataItem] {
        guard let s = stats else { return [] }
        return [
            DashboardDataItem(title: "Users", value: s.users),
            DashboardDataItem(title: "Buses", value: s.buses),
            DashboardDataItem(title: "Reviews", value: s.reviews),
            DashboardDataItem(title: "Comments", value: s.comments),
            DashboardDataItem(title: "Likes", value: s.likes)
        ]
    }
    
    let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var body: some View {
        VStack{
            Text("📊 Dashboard")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(Color(hex: "2A3B7F"))
                .padding(.top, 20)
                .padding(.horizontal, 10)
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    if isLoading {
                        ProgressView("Loading stats...")
                            .padding(.top, 50)
                            .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                            .scaleEffect(1.2)
                    } else if let _ = stats {
                        // Stat Cards Grid
                        LazyVGrid(columns: columns, spacing: 16) {
                            ForEach(chartData, id: \.id) { item in
                                StatCard(title: item.title, value: item.value,
                                         gradient: Gradient(colors: [.blue, .purple]))
                            }
                        }
                        .padding(.horizontal)
                        .scaleEffect(animateCards ? 1 : 0.9)
                        .animation(.spring(response: 0.6, dampingFraction: 0.7), value: animateCards)
                        
                        // Graph
                        Text("Statistics Overview")
                            .font(.headline)
                            .padding(.top, 20)
                            .padding(.horizontal)
                        
                        Chart(chartData) { item in BarMark( x: .value("Count", item.value), y: .value("Category", item.title) ) .foregroundStyle(.blue.gradient) } .frame(height: 300) .padding(.horizontal) } else { Text("❌ Failed to load stats.") .foregroundColor(.red) .padding(.top, 50) }
                }
            }
            .onAppear {
                fetchStats()
            }
        }
    }
    
    func fetchStats() {
        guard let url = URL(string: API.Endpoints.dashboardStats) else { return }
        URLSession.shared.dataTask(with: url) { data, _, _ in
            DispatchQueue.main.async {
                isLoading = false
            }
            if let data = data {
                do {
                    let decoded = try JSONDecoder().decode(DashboardStats.self, from: data)
                    DispatchQueue.main.async {
                        self.stats = decoded
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            animateCards = true
                        }
                    }
                } catch {
                    print("Decode error:", error)
                }
            }
        }.resume()
    }
}

struct StatCard: View {
    let title: String
    let value: Int
    let gradient: Gradient
    @State private var animatedValue: Int = 0
    
    var body: some View {
        VStack(spacing: 10) {
            Text(title)
                .font(.headline)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
            Text("\(animatedValue)")
                .font(.largeTitle)
                .bold()
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity, minHeight: 120)
        .background(
            LinearGradient(gradient: gradient, startPoint: .topLeading, endPoint: .bottomTrailing)
        )
        .cornerRadius(16)
        .shadow(radius: 8)
        .onAppear {
            withAnimation(.easeOut(duration: 1.0)) {
                animatedValue = value
            }
        }
    }
}

#Preview {
    DashboardView()
}
