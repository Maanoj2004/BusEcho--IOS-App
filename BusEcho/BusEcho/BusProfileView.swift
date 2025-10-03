import SwiftUI

struct BusProfileView: View {
    let bus: Bus

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {

                // MARK: - Bus Info
                VStack(alignment: .leading, spacing: 8) {
                    Text(bus.bus_operator)
                        .font(.largeTitle.bold())
                        .foregroundColor(Color(hex: "2A3B7F"))

                    HStack(spacing: 12) {
                        Label("Seater: \(bus.bus_type)", systemImage: "chair.lounge.fill")
                        Label("AC: \(bus.ac_type)", systemImage: "wind")
                    }
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                    HStack(spacing: 6) {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                        Text(String(format: "%.1f", bus.average_rating))
                            .fontWeight(.semibold)
                        Text("(\(bus.total_reviews) reviews)")
                            .foregroundColor(.secondary)
                    }
                    .font(.subheadline)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(
                    LinearGradient(colors: [Color.blue.opacity(0.15), Color.purple.opacity(0.15)],
                                   startPoint: .topLeading,
                                   endPoint: .bottomTrailing)
                )
                .cornerRadius(14)
                .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)

                Divider()

                // MARK: - Reviews Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("Reviews")
                        .font(.title2.bold())
                        .foregroundStyle(
                            LinearGradient(colors: [Color.blue, Color.purple],
                                           startPoint: .leading, endPoint: .trailing)
                        )

                    if bus.reviews.isEmpty {
                        HStack {
                            Image(systemName: "text.bubble")
                                .foregroundColor(.gray)
                            Text("No reviews available.")
                                .foregroundColor(.secondary)
                        }
                        .padding(.top, 10)
                    } else {
                        LazyVStack(spacing: 16) {
                            ForEach(bus.reviews) { review in
                                ReviewCard(review: review)
                            }
                        }
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Bus Profile")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct ReviewCard: View {
    let review: Review

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            
            // Header Row
            HStack {
                Label(review.date_of_travel, systemImage: "calendar")
                    .font(.caption)
                    .foregroundColor(.gray)

                Spacer()

                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                    Text(String(format: "%.1f", review.overall_rating))
                        .font(.caption)
                        .foregroundColor(.blue)
                }
            }

            // Review Text
            Text(review.review_text)
                .font(.body)
                .foregroundColor(.primary)
                .padding(10)
                .background(Color.gray.opacity(0.05))
                .cornerRadius(10)

            // Ratings Breakdown
            VStack(alignment: .leading, spacing: 6) {
                RatingsRow(label: "Punctuality", rating: review.punctuality_rating, color: .green)
                RatingsRow(label: "Cleanliness", rating: review.cleanliness_rating, color: .blue)
                RatingsRow(label: "Comfort", rating: review.comfort_rating, color: .orange)
                RatingsRow(label: "Staff", rating: review.staff_behaviour_rating, color: .purple)
            }
        }
        .padding()
        .background(
            LinearGradient(colors: [Color.white, Color.gray.opacity(0.05)],
                           startPoint: .topLeading,
                           endPoint: .bottomTrailing)
        )
        .cornerRadius(14)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 3)
    }
}

struct RatingsRow: View {
    let label: String
    let rating: Double
    var color: Color = .blue

    var body: some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundColor(.secondary)

            Spacer()

            HStack(spacing: 3) {
                ForEach(0..<5, id: \.self) { index in
                    Image(systemName: index < Int(rating) ? "star.fill" : "star")
                        .foregroundColor(color)
                        .font(.caption)
                }
            }
        }
        .padding(.vertical, 4)
        .padding(.horizontal, 8)
        .background(color.opacity(0.08))
        .cornerRadius(8)
    }
}
