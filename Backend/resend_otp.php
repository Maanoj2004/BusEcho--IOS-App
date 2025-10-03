<?php
session_start();
include 'config.php'; // For database connection
include 'OTP.php';    // Assumes this handles OTP generation and email/SMS sending

header('Content-Type: application/json');

if (!isset($_POST['id'])) {
    echo json_encode(["status" => "error", "message" => "User ID is required."]);
    exit;
}

$id = $_POST['id'];

// Step 1: Fetch user details (email or phone) using ID
$stmt = $conn->prepare("SELECT mail_id, phone_num FROM users WHERE id = ?");
$stmt->bind_param("i", $id);
$stmt->execute();
$result = $stmt->get_result();

if ($result->num_rows === 0) {
    echo json_encode(["status" => "error", "message" => "User not found."]);
    exit;
}

$user = $result->fetch_assoc();
$email = $user['mail_id'];
$phone = $user['phone_num'];

// Step 2: Generate OTP
$otp = rand(100000, 999999);

// Step 3: Save OTP in session
$_SESSION["otp_$id"] = $otp;

// Optional: You can also store the timestamp for throttling
$_SESSION["otp_time_$id"] = time();

// Step 4: Send OTP via your function
$success = sendOTP($email, $otp); // You can modify this to send via SMS if needed

if ($success) {
    echo json_encode(["status" => "success", "message" => "OTP resent successfully."]);
} else {
    echo json_encode(["status" => "error", "message" => "Failed to send OTP."]);
}
