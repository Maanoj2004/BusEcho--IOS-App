<?php
require 'config.php';
header("Content-Type: application/json");

$user_id = isset($_POST['user_id']) ? intval($_POST['user_id']) : 0;
$review_id = isset($_POST['review_id']) ? intval($_POST['review_id']) : 0;
$comment_text = isset($_POST['comment_text']) ? trim($_POST['comment_text']) : '';

if ($user_id && $review_id && !empty($comment_text)) {
    $stmt = $conn->prepare("INSERT INTO review_comments (review_id, user_id, comment_text, created_at) VALUES (?, ?, ?, NOW())");
    $stmt->bind_param("iis", $review_id, $user_id, $comment_text);
    $stmt->execute();
    echo json_encode(["status" => "comment_added"]);
} else {
    echo json_encode(["error" => "Missing fields"]);
}
?>
