<?php
include 'config.php'; // database connection

header("Content-Type: application/json");

// Get the POSTed JSON data
$data = json_decode(file_get_contents("php://input"), true);

$review_id = isset($data['review_id']) ? intval($data['review_id']) : null;
$user_id   = isset($data['user_id'])   ? intval($data['user_id'])   : null;

if (!$review_id || !$user_id) {
    echo json_encode([
        "success" => false,
        "liked"   => null,
        "message" => "Missing review_id or user_id"
    ]);
    exit;
}

try {
    // Check if user already liked this review
    $check_sql = "SELECT 1 FROM review_likes WHERE review_id = ? AND user_id = ? LIMIT 1";
    $stmt = $conn->prepare($check_sql);
    $stmt->bind_param("ii", $review_id, $user_id);
    $stmt->execute();
    $result = $stmt->get_result();

    if ($result && $result->num_rows > 0) {
        // Unlike (delete)
        $delete_sql = "DELETE FROM review_likes WHERE review_id = ? AND user_id = ?";
        $delete_stmt = $conn->prepare($delete_sql);
        $delete_stmt->bind_param("ii", $review_id, $user_id);
        $delete_stmt->execute();

        echo json_encode([
            "success" => true,
            "liked"   => false
        ]);
    } else {
        // Like (insert)
        $insert_sql = "INSERT INTO review_likes (review_id, user_id) VALUES (?, ?)";
        $insert_stmt = $conn->prepare($insert_sql);
        $insert_stmt->bind_param("ii", $review_id, $user_id);
        $insert_stmt->execute();

        echo json_encode([
            "success" => true,
            "liked"   => true
        ]);
    }
} catch (Exception $e) {
    echo json_encode([
        "success" => false,
        "liked"   => null,
        "message" => $e->getMessage()
    ]);
}
?>
