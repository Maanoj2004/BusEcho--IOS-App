<?php
session_start();
include 'config.php';
include 'OTP.php';

header('Content-Type: application/json');

// Collect inputs
$id        = $_POST['id'];
$name      = $_POST['name'];
$username  = $_POST['username'];
$mail_id   = $_POST['mail_id'];
$phone_num = $_POST['phone_num'];
$bio       = $_POST['bio'];

// Step 1: Get old user data
$stmt = $conn->prepare("SELECT username, mail_id, phone_num FROM users WHERE id = ?");
$stmt->bind_param("i", $id);
$stmt->execute();
$result = $stmt->get_result();
$oldData = $result->fetch_assoc();

if (!$oldData) {
    echo json_encode([
        "status" => "error",
        "message" => "Sorry, we couldn't find your account. Please try again or contact support."
    ]);
    exit;
}

$oldUsername = $oldData['username'];
$oldEmail    = $oldData['mail_id'];
$oldPhone    = $oldData['phone_num'];

// Step 2: Check for duplicate username
if ($username !== $oldUsername) {
    $stmt = $conn->prepare("SELECT id FROM users WHERE username = ? AND id != ?");
    $stmt->bind_param("si", $username, $id);
    $stmt->execute();
    if ($stmt->get_result()->num_rows > 0) {
        echo json_encode([
            "status" => "error",
            "message" => "That username is already taken. Please choose a different one."
        ]);
        exit;
    }
}

// Step 3: Check for duplicate email
if ($mail_id !== $oldEmail) {
    $stmt = $conn->prepare("SELECT id FROM users WHERE mail_id = ? AND id != ?");
    $stmt->bind_param("si", $mail_id, $id);
    $stmt->execute();
    if ($stmt->get_result()->num_rows > 0) {
        echo json_encode([
            "status" => "error",
            "message" => "This email is already registered with another account."
        ]);
        exit;
    }
}

// Step 4: Check for duplicate phone number
if ($phone_num !== $oldPhone) {
    $stmt = $conn->prepare("SELECT id FROM users WHERE phone_num = ? AND id != ?");
    $stmt->bind_param("si", $phone_num, $id);
    $stmt->execute();
    if ($stmt->get_result()->num_rows > 0) {
        echo json_encode([
            "status" => "error",
            "message" => "This phone number is already linked to another account."
        ]);
        exit;
    }
}

// Step 5: If email OR phone changed → trigger OTP
if ($mail_id !== $oldEmail || $phone_num !== $oldPhone) {
    $_SESSION["pending_update_$id"] = [
        "name"      => $name,
        "username"  => $username,
        "mail_id"   => $mail_id,
        "phone_num" => $phone_num,
        "bio"       => $bio
    ];

    $otp = rand(100000, 999999);
    $_SESSION["otp_$id"] = $otp;
    $_SESSION["otp_time_$id"] = time();

    $subject = "Verify Your Profile Changes";
    $body = "Hi $name,\n\nTo confirm the changes to your profile, please enter this OTP:\n\n$otp\n\nIf you did not request this, please ignore this email.";

    $mailStatus = sendOTP($mail_id, $subject, $body);

    if ($mailStatus === true) {
        echo json_encode([
            "status" => "otp_required",
            "message" => "We’ve sent a verification code to your new email. Please enter the OTP to confirm your changes."
        ]);
    } else {
        // Log detailed error for debugging, show friendly message to user
        error_log("OTP send error for user $id: $mailStatus");
        echo json_encode([
            "status" => "error",
            "message" => "We couldn’t send the OTP right now. Please try again later or contact support."
        ]);
    }
    exit;
}

// Step 6: If no email/phone change → update directly
$stmt = $conn->prepare("UPDATE users SET name = ?, username = ?, bio = ? WHERE id = ?");
$stmt->bind_param("sssi", $name, $username, $bio, $id);

if ($stmt->execute()) {
    echo json_encode([
        "status" => "success",
        "message" => "Your profile has been updated successfully."
    ]);
} else {
    error_log("DB update error for user $id: " . $stmt->error);
    echo json_encode([
        "status" => "error",
        "message" => "Something went wrong while updating your profile. Please try again later."
    ]);
}
?>
