<?php
session_start();

header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: Content-Type");
header("Access-Control-Allow-Methods: POST");
header("Content-Type: application/json");

require 'OTP.php'; // Your sendOTP function lives here

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    if (isset($_POST['email'])) {
        $email = $_POST['email'];

        // Generate OTP
        $otp = rand(100000, 999999);
        $_SESSION["reset_otp_$email"] = $otp; // Save OTP to session

        // Prepare email
        $subject = "Bus Echo - Password Reset OTP";
        $message = "Your OTP for password reset is: $otp";

        // Call sendOTP (returns true or error message string)
        $result = sendOTP($email, $subject, $message);

        if ($result === true) {
            echo json_encode([
                "status" => "success",
                "message" => "OTP sent successfully",
                "otp" => "$otp"
            ]);
        } else {
            echo json_encode([
                "status" => "error",
                "message" => "Failed to send OTP: $result"
            ]);
        }
    } else {
        echo json_encode([
            "status" => "error",
            "message" => "Email is required"
        ]);
    }
} else {
    echo json_encode([
        "status" => "error",
        "message" => "Invalid request method"
    ]);
}
?>
