<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json");

require 'config.php'; // Contains DB connection `$conn`

if ($_SERVER["REQUEST_METHOD"] === "GET") {
    if (!isset($_GET['id']) || empty($_GET['id'])) {
        echo json_encode(["status" => "error", "message" => "User ID is required"]);
        exit;
    }

    $user_id = intval($_GET['id']); // Safely cast to int

    $stmt = $conn->prepare("SELECT name, username, mail_id, phone_num, bio FROM users WHERE id = ?");
    $stmt->bind_param("i", $user_id);
    $stmt->execute();

    $result = $stmt->get_result();
    $user_id = $_GET['id'] ?? $_POST['id'] ?? null;

    if (!$user_id || !is_numeric($user_id)) {
        echo json_encode(["status" => "error", "message" => "User ID is required"]);
        exit;
    }

    if ($result->num_rows === 1) {
        $user = $result->fetch_assoc();

        echo json_encode([
            "status" => "success",
            "user" => $user
        ]);
    } else {
        echo json_encode(["status" => "error", "message" => "User not found"]);
    }
    $stmt->close();
    $conn->close();
} else {
    echo json_encode(["status" => "error", "message" => "Only GET method is allowed"]);
}
?>
