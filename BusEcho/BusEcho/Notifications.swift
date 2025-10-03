import SwiftUI

struct NotificationsView: View {
    @StateObject private var fetcher = NotificationFetcher()
    @AppStorage("storedUserID") private var storedUserID: Int?

    var body: some View {
        List(fetcher.notifications) { notif in
            VStack(alignment: .leading) {
                Text(notif.message)
                    .font(.body)
                Text(notif.created_at)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding(.vertical, 4)
        }
        .onAppear {
            if let id = storedUserID {
                fetcher.fetch(userID: id)
            }
        }
        .navigationTitle("Notifications")
    }
}

