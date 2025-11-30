<?php
header('Access-Control-Allow-Origin: *');
header('Content-Type: application/json');
require 'db.php';

$method = $_SERVER['REQUEST_METHOD'];
$act = $_GET['act'] ?? '';

if ($method == 'GET' && $act == 'users') {
    $q = $pdo->query("SELECT id, name, email, role, avatar, created_at FROM users ORDER BY created_at DESC");
    echo json_encode($q->fetchAll());
} elseif ($method == 'POST' && $act == 'createnews') {
    $json = file_get_contents('php://input');
    $data = json_decode($json, true);
    
    $title = $data['title'];
    $descr = $data['descr'];
    $image = $data['image'] ?? null;
    
    $stmt = $pdo->prepare("INSERT INTO news (title, descr, image) VALUES (?, ?, ?)");
    $stmt->execute([$title, $descr, $image]);
    
    echo json_encode(['success' => true]);
} elseif ($method == 'GET' && $act == 'listnews') {
    $q = $pdo->query("SELECT * FROM news ORDER BY created_at DESC");
    echo json_encode($q->fetchAll(PDO::FETCH_ASSOC));
} elseif ($method == 'POST' && $act == 'deletenews') {
    $data = json_decode(file_get_contents('php://input'), true);
    $stmt = $pdo->prepare("DELETE FROM news WHERE id = ?");
    $stmt->execute([$data['id']]);
    echo json_encode(['success' => true]);
}
