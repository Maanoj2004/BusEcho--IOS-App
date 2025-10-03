<?php
header("Content-Type: application/json");

include ('config.php');

if ($conn->connect_error) {
    echo json_encode(["success" => false, "message" => "Database connection failed"]);
    exit();
}

// Get POST data
$rating   = isset($_POST['rating']) ? intval($_POST['rating']) : 0;
$feedback = isset($_POST['feedback']) ? trim($_POST['feedback']) : "";

// Validate input
if ($rating < 1 || $rating > 5) {
    echo json_encode(["success" => false, "message" => "Invalid rating"]);
    exit();
}

// Insert into DB
$stmt = $conn->prepare("INSERT INTO ratings (rating, feedback) VALUES (?, ?)");
$stmt->bind_param("is", $rating, $feedback);

if ($stmt->execute()) {
    echo json_encode(["success" => true, "message" => "Thank you for your feedback!"]);
} else {
    echo json_encode(["success" => false, "message" => "Failed to save feedback"]);
}

$stmt->close();
$conn->close();
?>
