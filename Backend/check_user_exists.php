<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json");

require 'config.php';

$field = $_GET['field'] ?? '';
$value = $_GET['value'] ?? '';

// Basic validation
if (!$field || !$value) {
    echo json_encode(["status" => "error", "message" => "Missing field or value"]);
    exit;
}

// Only allow specific fields to be queried
$validFields = ["username", "mail_id", "phone_num"];
if (!in_array($field, $validFields)) {
    echo json_encode(["status" => "error", "message" => "Invalid field"]);
    exit;
}

// Use a switch statement for mapping to avoid SQL injection via $field
switch ($field) {
    case "username":
        $query = "SELECT id FROM users WHERE username = ?";
        break;
    case "mail_id":
        $query = "SELECT id FROM users WHERE mail_id = ?";
        break;
    case "phone_num":
        $query = "SELECT id FROM users WHERE phone_num = ?";
        break;
}

// Prepare and execute the query
$stmt = $conn->prepare($query);
$stmt->bind_param("s", $value);
$stmt->execute();
$stmt->store_result();

// Check if the value exists
if ($stmt->num_rows > 0) {
    echo json_encode(["status" => "exists", "message" => "$field already exists"]);
} else {
    echo json_encode(["status" => "ok"]);
}

// Close
$stmt->close();
$conn->close();
?>
