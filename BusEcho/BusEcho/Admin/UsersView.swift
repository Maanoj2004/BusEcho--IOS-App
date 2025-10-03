import SwiftUI

struct Users: Identifiable, Codable {
    let id: Int
    let name: String
    let username: String
    let email: String
    let bio: String?
}


struct UsersView: View {
    @State private var searchText = ""
    @State private var users: [Users] = []
    @State private var isLoading = true
    
    var filteredUsers: [Users] {
        if searchText.isEmpty {
            return users
        } else {
            return users.filter { $0.name.localizedCaseInsensitiveContains(searchText) || $0.username.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                // Search Bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    CustomTextField(title:"Search", text: $searchText)
                }
                .padding(.horizontal)
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding(.horizontal)
                Spacer()
                if isLoading {
                    ProgressView("Loading...")
                        .padding()
                } else {
                    List(filteredUsers) { user in
                        HStack(alignment: .top) {
                            Circle()
                                .fill(Color.blue.opacity(0.2))
                                .frame(width: 40, height: 40)
                                .overlay(
                                    Text(String(user.name.prefix(1)))
                                        .font(.headline)
                                        .foregroundColor(.blue)
                                )
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(user.name)
                                    .font(.headline)
                                Text("@\(user.username)")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                Text(user.email)
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                Text(user.bio ?? "")
                                    .font(.footnote)
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .navigationTitle("Users Directory")
            .onAppear(perform: fetchUsers)
            Spacer()
        }
        .navigationViewStyle(.stack)
    }
    
    func fetchUsers() {
        guard let url = URL(string: "http://localhost/busreview/users.php") else { return }
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else { return }
            do {
                let fetchedUsers = try JSONDecoder().decode([Users].self, from: data)
                DispatchQueue.main.async {
                    self.users = fetchedUsers
                    self.isLoading = false
                }
            } catch {
                print("Decoding error:", error)
            }
        }.resume()
    }
}

#Preview{
    UsersView()
}
