<?php
ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

include 'config.php';
header('Content-Type: application/json');

$sql = "SELECT bus_id as id, bus_operator FROM buses ORDER BY bus_operator ASC";
$result = mysqli_query($conn, $sql);

$buses = [];
while ($row = mysqli_fetch_assoc($result)) {
    $buses[] = $row;
}

echo json_encode(["status" => "success", "buses" => $buses]);
?>
