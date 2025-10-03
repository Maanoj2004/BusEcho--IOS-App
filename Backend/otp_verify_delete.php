<?php
ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);
session_start();
include 'config.php';

header('Content-Type: application/json');

$id = $_POST['id'];
$enteredOtp = $_POST['otp'];

// Step 1: Validate input
if (empty($id) || empty($enteredOtp)) {
    echo json_encode(["status" => "error", "message" => "Missing ID or OTP."]);
    exit;
}

// Step 2: Check OTP presence
if (!isset($_SESSION["delete_otp_$id"])) {
    echo json_encode(["status" => "error", "message" => "No OTP session found."]);
    exit;
}

// Step 3: Match OTP
if ($_SESSION["delete_otp_$id"] != $enteredOtp) {
    echo json_encode(["status" => "error", "message" => "Invalid OTP."]);
    exit;
}

// Step 4: Check expiration
if (time() - $_SESSION["delete_otp_time_$id"] > 300) {
    unset($_SESSION["delete_otp_$id"]);
    unset($_SESSION["delete_otp_time_$id"]);
    echo json_encode(["status" => "error", "message" => "OTP expired."]);
    exit;
}

// Step 5: Soft delete
$conn->begin_transaction();

$stmt = $conn->prepare("UPDATE users SET is_deleted = 1 WHERE id = ?");
if (!$stmt) {
    echo json_encode(["status" => "error", "message" => "Failed to prepare statement."]);
    exit;
}

$stmt->bind_param("i", $id);

if ($stmt->execute()) {
    $conn->commit();
    unset($_SESSION["delete_otp_$id"]);
    unset($_SESSION["delete_otp_time_$id"]);
    echo json_encode(["status" => "success", "message" => "Account deleted successfully."]);
} else {
    $conn->rollback();
    echo json_encode(["status" => "error", "message" => "Account Deletion failed. Try again."]);
}
?>
