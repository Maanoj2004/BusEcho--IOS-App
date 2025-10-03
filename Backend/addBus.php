<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json");
ini_set('display_errors', 0); // prevent notices from breaking JSON

require 'config.php';

$busOperator   = $_POST['bus_operator'] ?? '';
$boardingPoint = $_POST['boarding_point'] ?? '';
$droppingPoint = $_POST['dropping_point'] ?? '';
$busType       = $_POST['bus_type'] ?? '';
$acType        = $_POST['ac_type'] ?? '';

if (empty($busOperator) || empty($boardingPoint) || empty($droppingPoint) || empty($busType) || empty($acType)) {
    echo json_encode([
        "status" => "error",
        "message" => "All fields are required"
    ]);
    exit;
}

$stmt = $conn->prepare("INSERT INTO buses (bus_operator, boarding_point, dropping_point, bus_type, ac_type) VALUES (?, ?, ?, ?, ?)");
$stmt->bind_param("sssss", $busOperator, $boardingPoint, $droppingPoint, $busType, $acType);

if ($stmt->execute()) {
    echo json_encode([
        "status" => "success",
        "message" => "Bus added successfully"
    ]);
} else {
    echo json_encode([
        "status" => "error",
        "message" => "Database error: " . $stmt->error
    ]);
}

$stmt->close();
$conn->close();
