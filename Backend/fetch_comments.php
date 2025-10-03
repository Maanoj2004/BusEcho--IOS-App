<?php
ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);
header('Content-Type: application/json');

include 'config.php';

if (!isset($_GET['review_id']) || !is_numeric($_GET['review_id'])) {
    echo json_encode([
        "status" => "error",
        "message" => "Invalid or missing review_id"
    ]);
    exit;
}

$review_id = (int)$_GET['review_id'];

function timeAgo($datetime) {
    date_default_timezone_set("Asia/Kolkata");
    $now = new DateTime();
    $created = new DateTime($datetime);
    $diff = $now->diff($created);

    if ($diff->y > 0) return $created->format("F j, Y");
    if ($diff->m > 0) return $diff->m . " months ago";
    if ($diff->d > 2) return $diff->d . " days ago";
    if ($diff->d > 0) return "Yesterday";
    if ($diff->h > 0) return $diff->h . " hours ago";
    if ($diff->i > 0) return $diff->i . " minutes ago";
    return "Just now";
}

$stmt = $conn->prepare("
    SELECT 
        review_comments.id AS comment_id,
        review_comments.user_id,
        users.username,
        review_comments.comment_text, 
        review_comments.created_at
    FROM review_comments
    JOIN users ON review_comments.user_id = users.id
    WHERE review_comments.review_id = ?
    ORDER BY review_comments.created_at DESC
");
$stmt->bind_param("i", $review_id);
$stmt->execute();
$res = $stmt->get_result();

$comments = [];

while ($row = $res->fetch_assoc()) {
    $comments[] = [
        "comment_id" => (int)$row['comment_id'],
        "user_id" => (int)$row['user_id'],  // ✅ Fix here
        "username" => $row['username'],
        "comment_text" => $row['comment_text'],
        "commented_at" => timeAgo($row['created_at'])
    ];
}

if (empty($comments)) {
    echo json_encode([
        "status" => "no_comments",
        "message" => "No comments found."
    ]);
}
else {
    echo json_encode([
        "status" => "success",
        "comments" => $comments
    ], JSON_PRETTY_PRINT);
}

?>
