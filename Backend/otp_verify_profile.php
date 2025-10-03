<?php
session_start();
include 'config.php';
header('Content-Type: application/json');

// Collect POST inputs
$id = $_POST['id'] ?? null;
$enteredOtp = $_POST['otp'] ?? null;

if (!$id || !$enteredOtp) {
    echo json_encode(["status" => "error", "message" => "User ID and OTP are required."]);
    exit;
}

// Session keys
$otpKey = "otp_$id";
$otpTimeKey = "otp_time_$id";
$pendingKey = "pending_update_$id";

// Step 1: Check if OTP exists
if (!isset($_SESSION[$otpKey]) || !isset($_SESSION[$otpTimeKey]) || !isset($_SESSION[$pendingKey])) {
    echo json_encode(["status" => "error", "message" => "OTP session not found or expired."]);
    exit;
}

// Step 2: Check OTP expiration (2 minutes)
$currentTime = time();
$otpSentTime = $_SESSION[$otpTimeKey];

if ($currentTime - $otpSentTime > 120) {
    // Cleanup expired OTP and pending changes
    unset($_SESSION[$otpKey], $_SESSION[$otpTimeKey], $_SESSION[$pendingKey]);
    echo json_encode(["status" => "error", "message" => "OTP expired. Please request a new one."]);
    exit;
}

// Step 3: Validate OTP (strict string comparison)
if (trim($enteredOtp) !== (string)$_SESSION[$otpKey]) {
    echo json_encode(["status" => "error", "message" => "Invalid OTP"]);
    exit;
}

// Step 4: OTP verified — apply pending updates
$pending = $_SESSION[$pendingKey];
if (!$pending) {
    echo json_encode(["status" => "error", "message" => "No pending changes found."]);
    exit;
}

// Update database
$stmt = $conn->prepare("UPDATE users SET name = ?, username = ?, mail_id = ?, phone_num = ?, bio = ? WHERE id = ?");
$stmt->bind_param(
    "sssssi",
    $pending['name'],
    $pending['username'],
    $pending['mail_id'],
    $pending['phone_num'],
    $pending['bio'],
    $id
);

if ($stmt->execute()) {
    // Clean up session
    unset($_SESSION[$otpKey], $_SESSION[$otpTimeKey], $_SESSION[$pendingKey]);
    echo json_encode(["status" => "success", "message" => "Your profile has been updated successfully."]);
} else {
    error_log("DB update error for user $id: " . $stmt->error);
    echo json_encode(["status" => "error", "message" => "Failed to update your profile. Please try again."]);
}
?>
