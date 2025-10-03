<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json");

require 'config.php';

$status = isset($_GET['status']) ? $_GET['status'] : null; // e.g. approved, pending, rejected

$buses = [];

$busQuery = "
    SELECT bus_id, bus_operator, boarding_point, dropping_point,
           bus_type, ac_type, average_rating, total_reviews, status
    FROM buses
";

// Add filter if status is passed
if ($status) {
    $busQuery .= " WHERE status = ?";
}

$busQuery .= " ORDER BY bus_operator ASC";

if ($status) {
    $stmt = $conn->prepare($busQuery);
    $stmt->bind_param("s", $status);
    $stmt->execute();
    $resultBus = $stmt->get_result();
} else {
    $resultBus = $conn->query($busQuery);
}

while ($bus = $resultBus->fetch_assoc()) {
    $reviews = [];

    $reviewStmt = $conn->prepare("
        SELECT 
            id,
            user_id,
            review_text,
            overall_rating,
            punctuality_rating,
            cleanliness_rating,
            comfort_rating,
            staff_behaviour_rating,
            date_of_travel
        FROM bus_reviews
        WHERE bus_id = ? AND status = 'approved' AND confirmed = 1
        ORDER BY id DESC
    ");
    $reviewStmt->bind_param("i", $bus['bus_id']);
    $reviewStmt->execute();
    $reviewResult = $reviewStmt->get_result();

    while ($row = $reviewResult->fetch_assoc()) {
        $reviews[] = $row;
    }
    $reviewStmt->close();

    $buses[] = [
        "bus_id"          => (int)$bus["bus_id"],
        "bus_operator"    => $bus["bus_operator"],
        "boarding_point"  => $bus["boarding_point"],
        "dropping_point"  => $bus["dropping_point"],
        "bus_type"        => $bus["bus_type"],
        "ac_type"         => $bus["ac_type"],
        "average_rating"  => (double)$bus["average_rating"],
        "total_reviews"   => (int)$bus["total_reviews"],
        "status"          => $bus["status"], // 👈 now included
        "reviews"         => $reviews
    ];
}

echo json_encode($buses, JSON_UNESCAPED_UNICODE);

$conn->close();
