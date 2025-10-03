import SwiftUI

struct AdminView: View {
    let admin: Admin
    
    @EnvironmentObject var appState: AppState
    @State private var showLogoutAlert = false
    @State private var showAddAdminSheet = false
    @State private var showDeleteConfirm = false
    @Environment(\.horizontalSizeClass) var sizeClass
    
    var body: some View {
        ScrollView {
            GeometryReader { geo in
                let isWide = sizeClass == .regular && geo.size.width > 600
                let avatarSize: CGFloat = isWide ? 160 : 120
                
                VStack(spacing: isWide ? 40 : 28) {
                    
                    // MARK: - Avatar + Name Card
                    VStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(LinearGradient(colors: [.blue, .purple],
                                                     startPoint: .topLeading,
                                                     endPoint: .bottomTrailing))
                                .frame(width: avatarSize, height: avatarSize)
                                .shadow(color: .purple.opacity(0.3), radius: 10, x: 0, y: 6)
                            
                            Image(systemName: "person.fill")
                                .font(.system(size: avatarSize / 2.5))
                                .foregroundColor(.white)
                        }
                        
                        Text(admin.name)
                            .font(isWide ? .largeTitle.bold() : .title.bold())
                            .foregroundStyle(LinearGradient(colors: [.blue, .purple],
                                                            startPoint: .leading,
                                                            endPoint: .trailing))
                            .multilineTextAlignment(.center)
                        
                        Text("@\(admin.username)")
                            .foregroundColor(.gray)
                            .font(.subheadline)
                    }
                    .padding(.top, isWide ? 50 : 30)
                    
                    // MARK: - Info & Actions in adaptive layout
                    if isWide {
                        HStack(alignment: .top, spacing: 32) {
                            infoCard
                                .frame(maxWidth: geo.size.width * 0.4)
                            actionsCard
                                .frame(maxWidth: geo.size.width * 0.5)
                        }
                        .padding(.horizontal)
                    } else {
                        VStack(spacing: 20) {
                            infoCard
                            actionsCard
                        }
                        .padding(.horizontal)
                    }
                    
                    Spacer()
                }
                .frame(width: geo.size.width)
            }
        }
        .navigationTitle("Admin Profile")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Are you sure you want to logout?", isPresented: $showLogoutAlert) {
            Button("Logout", role: .destructive) {
                withAnimation {
                    appState.isLoggedIn = false
                    appState.rootViewState = .login
                }
            }
            Button("Cancel", role: .cancel) { }
        }
        .alert("Delete this admin?", isPresented: $showDeleteConfirm) {
            Button("Delete", role: .destructive) {
                // TODO: API call to delete admin
                print("Admin deleted")
            }
            Button("Cancel", role: .cancel) { }
        }
        .sheet(isPresented: $showAddAdminSheet) {
            AddAdminView()
        }
    }
    
    // MARK: - Info Card
    private var infoCard: some View {
        VStack(alignment: .leading, spacing: 18) {
            infoRow(title: "ID", value: "\(admin.id)", icon: "number.circle.fill", color: .blue)
            infoRow(title: "Email", value: admin.mail_id, icon: "envelope.fill", color: .orange)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 5)
        )
    }
    
    // MARK: - Actions Card
    private var actionsCard: some View {
        VStack(spacing: 16) {
            Button {
                showAddAdminSheet = true
            } label: {
                Label("Add New Admin", systemImage: "person.badge.plus")
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(LinearGradient(colors: [.green, .mint],
                                               startPoint: .topLeading,
                                               endPoint: .bottomTrailing))
                    .foregroundColor(.white)
                    .cornerRadius(16)
                    .shadow(color: .green.opacity(0.3), radius: 6, x: 0, y: 4)
            }
            
            Button {
                showDeleteConfirm = true
            } label: {
                Label("Delete Admin", systemImage: "trash.fill")
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(LinearGradient(colors: [.red, .pink],
                                               startPoint: .topLeading,
                                               endPoint: .bottomTrailing))
                    .foregroundColor(.white)
                    .cornerRadius(16)
                    .shadow(color: .red.opacity(0.3), radius: 6, x: 0, y: 4)
            }
            
            Button("Logout") {
                showLogoutAlert = true
            }
            .font(.headline)
            .padding()
            .frame(maxWidth: .infinity)
            .background(LinearGradient(colors: [.blue, .cyan],
                                       startPoint: .leading,
                                       endPoint: .trailing))
            .foregroundColor(.white)
            .cornerRadius(16)
            .shadow(color: .blue.opacity(0.3), radius: 6, x: 0, y: 4)
        }
    }
    
    @ViewBuilder
    private func infoRow(title: String, value: String, icon: String, color: Color) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.system(size: 20))
            
            VStack(alignment: .leading) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(value)
                    .font(.body)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
        }
    }
}

// MARK: - Add Admin View (unchanged)
struct AddAdminView: View {
    @Environment(\.dismiss) var dismiss
    @State private var name = ""
    @State private var username = ""
    @State private var email = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Admin Details")) {
                    TextField("Full Name", text: $name)
                    TextField("Username", text: $username)
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                }
            }
            .navigationTitle("Add Admin")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        // TODO: API call to add admin
                        print("Admin added: \(name)")
                        dismiss()
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    NavigationView {
        AdminView(
            admin: Admin(
                id: 1,
                name: "Maanoj Palani",
                username: "admin123",
                mail_id: "admin@gmail.com"
            )
        )
        .environmentObject(AppState())
    }
    .navigationViewStyle(.stack)   // 👈 must be applied here
}
