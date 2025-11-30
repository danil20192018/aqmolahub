<?php
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    exit(0);
}

$path = $_GET['path'] ?? '';

if (empty($path)) {
    http_response_code(404);
    exit('нет патча');
}

$path = str_replace(['../', '..\\'], '', $path);
$fullPath = __DIR__ . '/' . $path;

if (!file_exists($fullPath)) {
    http_response_code(404);
    exit('файла нет');
}

$ext = strtolower(pathinfo($fullPath, PATHINFO_EXTENSION));
$contentTypes = [
    'jpg' => 'image/jpeg',
    'jpeg' => 'image/jpeg',
    'png' => 'image/png',
    'gif' => 'image/gif',
    'webp' => 'image/webp'
];

$contentType = $contentTypes[$ext] ?? 'application/octet-stream';
header('Content-Type: ' . $contentType);
header('Content-Length: ' . filesize($fullPath));

readfile($fullPath);
?>
