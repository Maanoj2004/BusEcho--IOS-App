import Foundation
import UIKit

func postReview(
    userID: Int,
    busOperator: String,
    busNumber: String,
    busType: String?,
    boardingPoint: String,
    droppingPoint: String,
    dateOfTravel: String,
    acType: String?,
    punctuality: Int,
    cleanliness: Int,
    comfort: Int,
    staffBehaviour: Int,
    reviewText: String,
    confirmed: Bool,
    ticketPDF: Data?,   // 📌 PDF file
    images: [Data],     // Review images
    completion: @escaping (Result<String, Error>) -> Void
) {
    guard let url = URL(string: API.Endpoints.busReview) else {
        completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
        return
    }

    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    
    let boundary = UUID().uuidString
    request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

    var body = Data()
    
    func appendFormField(_ name: String, value: String) {
        body.append("--\(boundary)\r\n")
        body.append("Content-Disposition: form-data; name=\"\(name)\"\r\n\r\n")
        body.append("\(value)\r\n")
    }

    // ----------------- Add form fields -----------------
    appendFormField("user_id", value: "\(userID)")
    appendFormField("bus_operator", value: busOperator)
    appendFormField("bus_number", value: busNumber)
    appendFormField("bus_type", value: busType ?? "")
    appendFormField("boarding_point", value: boardingPoint)
    appendFormField("dropping_point", value: droppingPoint)
    appendFormField("date_of_travel", value: dateOfTravel)
    appendFormField("ac_type", value: acType ?? "")
    appendFormField("punctuality", value: "\(punctuality)")
    appendFormField("cleanliness", value: "\(cleanliness)")
    appendFormField("comfort", value: "\(comfort)")
    appendFormField("staff_behaviour", value: "\(staffBehaviour)")
    appendFormField("review_text", value: reviewText)
    appendFormField("confirmation", value: confirmed ? "1" : "0")

    // ----------------- Add PDF file -----------------
    if let pdfData = ticketPDF {
        body.append("--\(boundary)\r\n")
        body.append("Content-Disposition: form-data; name=\"ticket_pdf\"; filename=\"ticket.pdf\"\r\n")
        body.append("Content-Type: application/pdf\r\n\r\n")
        body.append(pdfData)
        body.append("\r\n")
    }

    // ----------------- Add images -----------------
    for (index, imageData) in images.enumerated() {
        body.append("--\(boundary)\r\n")
        body.append("Content-Disposition: form-data; name=\"review_images[]\"; filename=\"image\(index).jpg\"\r\n")
        body.append("Content-Type: image/jpeg\r\n\r\n")
        body.append(imageData)
        body.append("\r\n")
    }

    body.append("--\(boundary)--\r\n")

    // ----------------- Upload task -----------------
    URLSession.shared.uploadTask(with: request, from: body) { data, response, error in
        if let error = error {
            completion(.failure(error))
            return
        }
        
        guard let data = data else {
            completion(.failure(NSError(domain: "", code: -2, userInfo: [NSLocalizedDescriptionKey: "No response data"])))
            return
        }

        do {
            let result = try JSONDecoder().decode(ServerResponse.self, from: data)
            if result.status == "success" {
                completion(.success(result.message))
            } else {
                completion(.failure(NSError(domain: "", code: -3, userInfo: [NSLocalizedDescriptionKey: result.message])))
            }
        } catch {
            if let raw = String(data: data, encoding: .utf8) {
                print("📦 Raw response: \(raw)")
            }
            completion(.failure(error))
        }
    }.resume()
}

// MARK: - Date Formatters

func formattedDate(from date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    return formatter.string(from: date)
}

func formattedTime(from date: Date?) -> String {
    guard let date = date else { return "" }
    let formatter = DateFormatter()
    formatter.dateFormat = "HH:mm:ss"
    return formatter.string(from: date)
}

// MARK: - Data Extension

extension Data {
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}


func validateReviewForm(
    busOperator: String,
    busNumber: String,
    boardingPoint: String,
    droppingPoint: String,
    selectedBusType: String,
    selectedACType: String,
    punctualityRating: Int,
    cleanlinessRating: Int,
    comfortRating: Int,
    staffBehaviorRating: Int,
    ticketURL: URL?
) -> (Bool, String) {
    if busOperator.isEmpty { return (false, "Please select a bus operator.") }
    if busNumber.isEmpty { return (false, "Please enter bus number.") }
    if boardingPoint.isEmpty || droppingPoint.isEmpty { return (false, "Please select boarding and dropping points.") }
    if boardingPoint == droppingPoint { return (false, "Boarding and Dropping points cannot be the same.") }
    if selectedBusType.isEmpty { return (false, "Please select bus type.") }
    if selectedACType.isEmpty { return (false, "Please select AC type.") }
    if punctualityRating == 0 || cleanlinessRating == 0 || comfortRating == 0 || staffBehaviorRating == 0 {
        return (false, "Please provide all ratings.")
    }
    if ticketURL == nil {
        return (false, "Please upload your bus ticket PDF.")
    }
    return (true, "")
}

