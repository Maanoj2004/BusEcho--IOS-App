import SwiftUI
import Foundation

struct BusOperator: Identifiable, Codable, Hashable {
    var id: String { bus_id }
    let bus_id: String
    let bus_operator: String
    let boarding_point: String
    let dropping_point: String
    let bus_type: String
    let ac_type: String
}

struct ServerResponse: Decodable {
    let status: String
    let message: String
    let review_id: Int?
    let image_paths: [String]?
    let status_set: String?
}

struct Bus: Identifiable, Decodable {
    let id = UUID()
    let bus_id: Int
    let bus_operator: String
    let boarding_point: String
    let dropping_point: String
    let bus_type: String
    let ac_type: String
    let average_rating: Double
    let total_reviews: Int
    let reviews: [Review]
}

struct UserProfile: Codable {
    let name: String
    let username: String
    let mail_id: String
    let phone_num: String
    let bio: String?
}


struct Review: Identifiable, Decodable {
    let id: Int
    let user_id: Int
    let review_text: String
    let overall_rating: Double
    let punctuality_rating: Double
    let cleanliness_rating: Double
    let comfort_rating: Double
    let staff_behaviour_rating: Double
    let date_of_travel: String
}

struct CommentModel: Codable, Identifiable, Hashable {
    var id: Int { comment_id }
    let comment_id: Int
    let user_id: Int
    let username: String?
    let comment_text: String
    let commented_at: String
}

struct ReviewModel: Identifiable, Codable {
    let review_id: Int
    var id: Int { review_id }
    let bus_operator: String
    let bus_number: String
    let review_text: String
    let overall_rating: Double
    let punctuality_rating: Double
    let cleanliness_rating: Double
    let comfort_rating: Double
    let staff_behaviour_rating: Double
    let date_of_travel: String
    let boarding_point: String
    let dropping_point: String
    let created_at_formatted: String
    let like_count: Int
    let user_liked: Bool
    let comment_count: Int
    let images: [String]
    let comments: [CommentModel]
}

struct SignupResponse: Codable {
    let status: String
    let message: String?
    let name: String?
}

struct ResetResponse: Codable {
    let status: String
    let message: String?
}

struct Place: Codable, Hashable, Identifiable {
    var id: String { name + type }
    let name: String
    let type: String
    let lat: Double
    let lon: Double
}

struct User: Codable {
    let status: String
    let message: String
    let role: String
    let user_id: Int?
    let name: String?
}

struct LikeResponse: Codable {
    let success: Bool
    let liked: Bool
    let message: String?
}


struct ResponseMessage: Codable {
    let status: String
    let message: String
}

struct Admin: Identifiable, Decodable {
    let id: Int
    let name: String
    let username: String
    let mail_id: String
}

struct NotificationModel: Identifiable, Codable {
    let id = UUID() // since no single ID (union), generate locally
    let type: String
    let username: String
    let review_id: Int
    let message: String
    let created_at: String
}
