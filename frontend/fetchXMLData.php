<?php

header("Access-Control-Allow-Origin: *"); // Allow all origins (or set your domain instead)
header("Content-Type: application/json");

header("Content-Type: application/json");

$xmlFile = "trendingStocks.xml";

if (!file_exists($xmlFile)) {
    echo json_encode(["error" => "File not found: $xmlFile"]);
    exit;
}

$xml = simplexml_load_file($xmlFile);

if ($xml === false) {
    echo json_encode(["error" => "Failed to load XML file"]);
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
