<?php
error_reporting(E_ALL);
ini_set('display_errors', 1);

header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json");

$xmlFile = "trendingStocks.xml";

if (!file_exists($xmlFile)) {
    echo json_encode(["error" => "File not found: $xmlFile"]);
    exit;
}

libxml_use_internal_errors(true);
$xml = simplexml_load_file($xmlFile);
$errors = libxml_get_errors();
libxml_clear_errors();

if ($xml === false) {
    $errorMessages = [];
    foreach ($errors as $error) {
        $errorMessages[] = $error->message;
    }
    echo json_encode([
        "error" => "Failed to load XML file",
        "details" => $errorMessages,
        "path" => realpath($xmlFile) ?: "Path not resolved"
    ]);
    exit;
}

$watchlist = [];

foreach ($xml->stock as $stock) {
    $watchlist[] = [
        "symbol" => (string)$stock->symbol,
        "name" => (string)$stock->name,
        "price" => (float)$stock->price
    ];
}

echo json_encode($watchlist);
?>