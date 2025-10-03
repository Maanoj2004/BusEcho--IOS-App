import SwiftUI
import Foundation

class NotificationFetcher: ObservableObject {
    @Published var notifications: [NotificationModel] = []

    func fetch(userID: Int) {
        guard let url = URL(string: API.Endpoints.notifications+"?user_id=\(userID)") else { return }

        URLSession.shared.dataTask(with: url) { data, _, _ in
            if let data = data {
                if let decoded = try? JSONDecoder().decode([NotificationModel].self, from: data) {
                    DispatchQueue.main.async {
                        self.notifications = decoded
                    }
                }
            }
        }.resume()
    }
}
