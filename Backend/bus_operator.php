<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

require_once("config.php");

$sql = "SELECT bus_id, bus_operator, boarding_point, dropping_point, bus_type, ac_type FROM buses";
$result = $conn->query($sql);

$operators = [];

if ($result && $result->num_rows > 0) {
    while ($row = $result->fetch_assoc()) {
        $operators[] = $row;
    }
    echo json_encode($operators);
} else {
    echo json_encode([]);
}

$conn->close();
?>
