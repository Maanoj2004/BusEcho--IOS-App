<?php
session_start();
include 'config.php';
include 'OTP.php'; // contains generateOTP()

header('Content-Type: application/json');

$id = $_POST['id'];

// Fetch email from DB based on ID
$stmt = $conn->prepare("SELECT mail_id FROM users WHERE id = ?");
$stmt->bind_param("i", $id);
$stmt->execute();
$result = $stmt->get_result();

if ($result->num_rows === 0) {
    echo json_encode(["status" => "error", "message" => "User not found."]);
    exit;
}

$row = $result->fetch_assoc();
$email = $row['mail_id'];

$otp = rand(100000, 999999);
$_SESSION["delete_otp_$id"] = $otp;
$_SESSION["delete_otp_time_$id"] = time();
$subject = "OTP for Account Deletion";
$body = "Your OTP for account deletion is: $otp";
sendOTP($email, $subject, $body);

echo json_encode(["status" => "success", "message" => "OTP sent to your registered email."]);
?>

