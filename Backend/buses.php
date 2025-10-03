<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json");

require 'config.php'; // Your DB connection file

// Read POST data
$bus_operator   = $_POST['bus_operator'] ?? '';
$boarding_point = $_POST['boarding_point'] ?? '';
$dropping_point = $_POST['dropping_point'] ?? '';
$bus_type       = $_POST['bus_type'] ?? '';
$ac_type        = $_POST['ac_type'] ?? '';

// Valid options
$valid_bus_types = ['Seater', 'Sleeper'];
$valid_ac_types  = ['AC', 'Non AC'];

// Validation
if (!$bus_operator || !$boarding_point || !$dropping_point || !$bus_type || !$ac_type) {
    echo json_encode(["status" => "error", "message" => "All fields are required"]);
    exit;
}

if (!in_array($bus_type, $valid_bus_types)) {
    echo json_encode(["status" => "error", "message" => "Invalid bus type"]);
    exit;
}

if (!in_array($ac_type, $valid_ac_types)) {
    echo json_encode(["status" => "error", "message" => "Invalid AC type"]);
    exit;
}

// Insert into DB
$stmt = $conn->prepare("INSERT INTO buses (bus_operator, boarding_point, dropping_point, bus_type, ac_type, status) VALUES (?, ?, ?, ?, ?,'pending')");
$stmt->bind_param("sssss", $bus_operator, $boarding_point, $dropping_point, $bus_type, $ac_type);

if ($stmt->execute()) {
    echo json_encode(["status" => "success", "message" => "Bus added successfully"]);
} else {
    echo json_encode(["status" => "error", "message" => "Insert failed: " . $stmt->error]);
}

$stmt->close();
$conn->close();
?>
