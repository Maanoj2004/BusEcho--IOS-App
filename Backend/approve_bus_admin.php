<?php
include 'config.php';

header("Content-Type: application/json");

// Validate input
if (!isset($_POST['bus_id'], $_POST['status'])) {
    echo json_encode(["status" => "error", "message" => "Missing bus_id or status"]);
    exit;
}

$bus_id = intval($_POST['bus_id']);
$new_status = $_POST['status']; // should be 'approved' or 'rejected'

// Check allowed values
$allowed_status = ['approved', 'rejected', 'pending'];
if (!in_array($new_status, $allowed_status)) {
    echo json_encode(["status" => "error", "message" => "Invalid status value"]);
    exit;
}

// --- Update bus status ---
$stmt = $conn->prepare("UPDATE buses SET status = ? WHERE bus_id = ?");
if (!$stmt) {
    echo json_encode(["status" => "error", "message" => "Prepare failed: " . $conn->error]);
    exit;
}
$stmt->bind_param("si", $new_status, $bus_id);

if (!$stmt->execute()) {
    echo json_encode(["status" => "error", "message" => "Execution failed: " . $stmt->error]);
    exit;
}

if ($stmt->affected_rows === 0) {
    echo json_encode(["status" => "error", "message" => "No bus updated. Check bus_id"]);
    exit;
}

// --- Update reviews depending on bus status ---
if ($new_status === 'approved') {
    $stmt2 = $conn->prepare("UPDATE bus_reviews 
                             SET status = 'approved' 
                             WHERE bus_id = ? AND status = 'pending'");
    if (!$stmt2) {
        echo json_encode(["status" => "error", "message" => "Prepare failed (reviews): " . $conn->error]);
        exit;
    }
    $stmt2->bind_param("i", $bus_id);
    if (!$stmt2->execute()) {
        echo json_encode(["status" => "error", "message" => "Execution failed (reviews): " . $stmt2->error]);
        exit;
    }

} elseif ($new_status === 'rejected') {
    $stmt2 = $conn->prepare("UPDATE bus_reviews 
                             SET status = 'rejected' 
                             WHERE bus_id = ?");
    if (!$stmt2) {
        echo json_encode(["status" => "error", "message" => "Prepare failed (reviews): " . $conn->error]);
        exit;
    }
    $stmt2->bind_param("i", $bus_id);
    if (!$stmt2->execute()) {
        echo json_encode(["status" => "error", "message" => "Execution failed (reviews): " . $stmt2->error]);
        exit;
    }
}

echo json_encode(["status" => "success", "message" => "Bus and related reviews updated"]);
?>
