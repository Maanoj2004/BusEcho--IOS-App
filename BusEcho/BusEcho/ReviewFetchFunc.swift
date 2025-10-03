import Foundation

@MainActor
class ReviewFetch: ObservableObject {
    @Published var reviews: [ReviewModel] = []
    @Published var isLoading = false
    @Published var errorMessage: String? = nil
    
    /// Async version for refreshable
    func fetchReviews(viewerId: Int, filterUserId: Int? = nil) async {
        isLoading = true
        errorMessage = nil
        
        var components = URLComponents(string: API.Endpoints.fetchreviews)!
        
        // Always send viewer_id
        var queryItems = [URLQueryItem(name: "viewer_id", value: "\(viewerId)")]
        
        // Add user_id filter (optional)
        if let filterUserId = filterUserId {
            queryItems.append(URLQueryItem(name: "user_id", value: "\(filterUserId)"))
        }
        
        components.queryItems = queryItems
        
        guard let url = components.url else {
            errorMessage = "Something went wrong. Please try again later."
            isLoading = false
            return
        }
        
        print("➡️ Fetching from: \(url)")
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let reviews = try JSONDecoder().decode([ReviewModel].self, from: data)
            self.reviews = reviews
            print("✅ Decoded \(reviews.count) reviews")
        } catch let error as DecodingError {
            self.errorMessage = "We couldn't process the data. Please try again."
            print("❌ JSON decoding error:", error)
        } catch let urlError as URLError {
            switch urlError.code {
            case .notConnectedToInternet:
                self.errorMessage = "No internet connection. Please check your network."
            case .timedOut:
                self.errorMessage = "The request timed out. Please try again."
            case .cannotFindHost, .cannotConnectToHost:
                self.errorMessage = "Cannot reach the server. Please try again later."
            default:
                self.errorMessage = "Something went wrong. Please try again."
            }
            print("❌ Network error:", urlError)
        } catch {
            self.errorMessage = "Unexpected error occurred. Please try again."
            print("❌ Other error:", error)
        }
        
        isLoading = false
    }
}
