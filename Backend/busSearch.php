<?php
include 'config.php'; // DB connection

header('Content-Type: application/json');

$busName = $_POST['bus_name'] ?? '';

if (empty($busName)) {
    echo json_encode(["status" => "error", "message" => "Bus name is required."]);
    exit;
}

// Search matching buses
$stmt = $conn->prepare("
    SELECT 
        b.bus_id,
        b.bus_operator,
        b.boarding_point,
        b.dropping_point,
        b.bus_type,
        b.ac_type,
        COALESCE(AVG(r.overall_rating), 0) AS average_rating,
        COUNT(r.id) AS total_reviews
    FROM buses b
    LEFT JOIN bus_reviews r ON b.bus_id = r.bus_id
    WHERE b.bus_operator LIKE CONCAT('%', ?, '%')
    GROUP BY b.bus_id
");

$stmt->bind_param("s", $busName);
$stmt->execute();
$result = $stmt->get_result();

$buses = [];

while ($row = $result->fetch_assoc()) {
    // Get reviews for this bus
    $reviewStmt = $conn->prepare("SELECT * FROM bus_reviews WHERE bus_id = ?");
    $reviewStmt->bind_param("i", $row['bus_id']);
    $reviewStmt->execute();
    $reviewsResult = $reviewStmt->get_result();

    $reviews = [];
    while ($review = $reviewsResult->fetch_assoc()) {
        $reviews[] = $review;
    }

    $row['reviews'] = $reviews;
    $buses[] = $row;
}

echo json_encode(["status" => "success", "buses" => $buses]);
?>
