<?php
// Enable error reporting
ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json");
error_log(print_r($_POST, true));
error_log(print_r($_FILES, true));

require 'config.php';
require 'profanityFilter.php';
require 'vendor/autoload.php'; // PDF parser

use Smalot\PdfParser\Parser;

// Upload directory
$upload_dir = rtrim(__DIR__, '/') . '/uploads/';
if (!is_dir($upload_dir) && !mkdir($upload_dir, 0777, true)) {
    echo json_encode(["status" => "error", "message" => "Failed to create uploads directory"]);
    exit;
}

// -------------------- Collect form data --------------------
$user_id        = intval($_POST['user_id'] ?? 0);
$bus_operator   = $_POST['bus_operator'] ?? '';
$bus_type       = $_POST['bus_type'] ?? '';
$bus_number     = $_POST['bus_number'] ?? '';
$boarding_point = $_POST['boarding_point'] ?? '';
$dropping_point = $_POST['dropping_point'] ?? '';
$date_of_travel = $_POST['date_of_travel'] ?? '';
$ac_type        = $_POST['ac_type'] ?? '';
$punctuality    = floatval($_POST['punctuality'] ?? 0);
$cleanliness    = floatval($_POST['cleanliness'] ?? 0);
$comfort        = floatval($_POST['comfort'] ?? 0);
$staff_behaviour= floatval($_POST['staff_behaviour'] ?? 0);
$review_text    = $_POST['review_text'] ?? '';
$confirmation   = isset($_POST['confirmation']) ? 1 : 0;

// -------------------- Profanity & AI moderation --------------------
if (containsBadWords($review_text) || checkProfanityWithAI($review_text)) {
    echo json_encode([
        "status" => "error",
        "message" => "❌ Review blocked due to harmful or hateful content."
    ]);
    exit;
}

// -------------------- Fetch bus_id --------------------
$bus_id = 0;
$busCheck = $conn->prepare("SELECT bus_id FROM buses WHERE bus_operator = ? LIMIT 1");
$busCheck->bind_param("s", $bus_operator);
$busCheck->execute();
$busCheck->bind_result($bus_id_result);

if ($busCheck->fetch()) {
    $bus_id = $bus_id_result;
    $status = 'approved';
} else {
    $status = 'pending';
}
$busCheck->close();

// -------------------- Extract ticket number from PDF --------------------
$ticket_number = null;
if (isset($_FILES['ticket_pdf']) && $_FILES['ticket_pdf']['error'] === UPLOAD_ERR_OK) {
    $tmp_name      = $_FILES['ticket_pdf']['tmp_name'];
    $original_name = basename($_FILES['ticket_pdf']['name']);
    $ext           = strtolower(pathinfo($original_name, PATHINFO_EXTENSION));

    if ($ext === "pdf") {
        $new_name    = uniqid("ticket_") . ".pdf";
        $target_path = $upload_dir . $new_name;

        if (move_uploaded_file($tmp_name, $target_path)) {
            try {
                $parser = new Parser();
                $pdf    = $parser->parseFile($target_path);
                $text   = $pdf->getText();

                $patterns = [
                    '/Ticket\s*(No|Number|ID)[:\-]?\s*([A-Z0-9\-]+)/i',
                    '/PNR[:\-]?\s*([A-Z0-9\-]+)/i',
                    '/Booking\s*ID[:\-]?\s*([A-Z0-9\-]+)/i',
                    '/Reference[:\-]?\s*([A-Z0-9\-]+)/i'
                ];
                foreach ($patterns as $pattern) {
                    if (preg_match($pattern, $text, $matches)) {
                        $ticket_number = $matches[count($matches) - 1];
                        break;
                    }
                }

                if (!$ticket_number && preg_match('/\b[A-Z0-9]{6,}\b/', $text, $matches)) {
                    $ticket_number = $matches[0];
                }
            } catch (Exception $e) {
                $ticket_number = null;
            }
        }
    }
}
$ticket_number = $ticket_number ?? "";

// -------------------- Sentiment Analysis (Python) --------------------
$pythonData = json_encode([
    "review_text" => $review_text,
    "punctuality" => $punctuality,
    "cleanliness" => $cleanliness,
    "comfort" => $comfort,
    "staff_behaviour" => $staff_behaviour
]);

$descriptorSpec = [
    0 => ["pipe", "r"],
    1 => ["pipe", "w"],
    2 => ["pipe", "w"]
];

$pythonPath = '/Library/Frameworks/Python.framework/Versions/3.13/bin/python3';
$scriptPath = __DIR__ . '/sentimentAnalysis.py';

$process = proc_open("$pythonPath $scriptPath", $descriptorSpec, $pipes, __DIR__);
if (is_resource($process)) {
    fwrite($pipes[0], $pythonData);
    fclose($pipes[0]);

    $result      = stream_get_contents($pipes[1]);
    $errorOutput = stream_get_contents($pipes[2]);

    fclose($pipes[1]);
    fclose($pipes[2]);

    $returnCode = proc_close($process);

    if ($returnCode === 0) {
        $output          = json_decode($result, true);
        $overall_rating  = $output['overall_rating'];
        $sentimentRating = $output['sentiment_rating'];
    } else {
        echo json_encode(["status" => "error", "message" => "Python script failed", "error" => $errorOutput]);
        exit;
    }
} else {
    echo json_encode(["status" => "error", "message" => "Could not start Python process"]);
    exit;
}
// -------------------- Check for duplicate ticket number --------------------
if (!empty($ticket_number)) {
    $dupCheck = $conn->prepare("SELECT id FROM bus_reviews WHERE ticket_number = ?");
    $dupCheck->bind_param("s", $ticket_number);
    $dupCheck->execute();
    $dupCheck->store_result();

    if ($dupCheck->num_rows > 0) {
        echo json_encode([
            "status" => "error",
            "message" => "❌ A review with this ticket number already exists."
        ]);
        $dupCheck->close();
        exit;
    }
    $dupCheck->close();
}

// -------------------- Insert review --------------------
$stmt = $conn->prepare("
    INSERT INTO bus_reviews (
        user_id,
        bus_operator,
        bus_id,
        bus_type,
        bus_number,
        ticket_number,
        boarding_point,
        dropping_point,
        date_of_travel,
        ac_type,
        overall_rating,
        punctuality_rating,
        cleanliness_rating,
        comfort_rating,
        staff_behaviour_rating,
        review_text,
        confirmed,
        status
    ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
");


if (!$stmt) {
    echo json_encode(["status" => "error", "message" => "Prepare failed", "error" => $conn->error]);
    exit;
}

$stmt->bind_param(
    "isisssssssdddddsss",
    $user_id,
    $bus_operator,
    $bus_id,
    $bus_type,
    $bus_number,
    $ticket_number,
    $boarding_point,
    $dropping_point,
    $date_of_travel,
    $ac_type,
    $overall_rating,
    $punctuality,
    $cleanliness,
    $comfort,
    $staff_behaviour,
    $review_text,
    $confirmation,
    $status
);

if ($stmt->execute()) {
    $review_id  = $stmt->insert_id;
    $image_paths = [];

    // Upload review images
    if (isset($_FILES['review_images'])) {
        $count = count($_FILES['review_images']['name']);
        for ($i = 0; $i < $count; $i++) {
            $tmp_name      = $_FILES['review_images']['tmp_name'][$i];
            $original_name = basename($_FILES['review_images']['name'][$i]);
            $ext           = strtolower(pathinfo($original_name, PATHINFO_EXTENSION));

            if (!in_array($ext, ['jpg','jpeg','png'])) continue;
            if ($_FILES['review_images']['size'][$i] > 5 * 1024 * 1024) continue;

            $new_name    = uniqid("review_") . "_$i." . $ext;
            $target_path = $upload_dir . $new_name;

            if (move_uploaded_file($tmp_name, $target_path)) {
                $imgPath = "uploads/$new_name";
                $image_paths[] = $imgPath;

                $imgStmt = $conn->prepare("INSERT INTO review_images (review_id, image_path) VALUES (?, ?)");
                $imgStmt->bind_param("is", $review_id, $imgPath);
                $imgStmt->execute();
                $imgStmt->close();
            }
        }
    }

    // Update bus average rating
    $aggQuery = "
        SELECT AVG(overall_rating) AS avg_rating, COUNT(*) AS total_reviews
        FROM bus_reviews
        WHERE bus_id = ? AND confirmed = 1 AND status = 'approved'
    ";
    $aggStmt = $conn->prepare($aggQuery);
    $aggStmt->bind_param("i", $bus_id);
    $aggStmt->execute();
    $aggResult = $aggStmt->get_result()->fetch_assoc();

    $newAvgRating  = round($aggResult['avg_rating'], 1);
    $newTotalCount = $aggResult['total_reviews'];

    $updateBus = $conn->prepare("
        UPDATE buses
        SET average_rating = ?, total_reviews = ?
        WHERE bus_id = ?
    ");
    $updateBus->bind_param("dii", $newAvgRating, $newTotalCount, $bus_id);
    $updateBus->execute();

    $aggStmt->close();
    $updateBus->close();

    echo json_encode([
        "status"        => "success",
        "message"       => "Review submitted",
        "review_id"     => $review_id,
        "bus_number"    => $bus_number,
        "ticket_number" => $ticket_number,
        "image_paths"   => $image_paths,
        "status_set"    => $status,
        "average_rating_updated" => $newAvgRating,
        "total_reviews_updated"  => $newTotalCount
    ]);
} else {
    echo json_encode([
        "status" => "error",
        "message" => "Execution failed",
        "error" => $stmt->error
    ]);
}

$stmt->close();
$conn->close();
?>
