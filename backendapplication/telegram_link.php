<?php
header('Access-Control-Allow-Origin: *');
header('Content-Type: application/json');

$user_id = $_GET['user_id'] ?? 0;

if (!$user_id) {
    echo json_encode(['res' => false]);
    exit;
}

$uuid = bin2hex(random_bytes(16));
$file = 'profile_link_requests.json';
$reqs = file_exists($file) ? json_decode(file_get_contents($file), true) : [];

$reqs[$uuid] = [
    'user_id' => $user_id,
    'ts' => time()
];

file_put_contents($file, json_encode($reqs));

echo json_encode(['res' => true, 'uuid' => $uuid]);
