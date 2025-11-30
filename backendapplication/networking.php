<?php
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    exit(0);
}

header('Content-Type: application/json');
require 'db.php';

$act = $_GET['act'] ?? '';

if ($act == 'list') {
    $stmt = $pdo->query("SELECT * FROM networking_cards ORDER BY created_at DESC");
    echo json_encode($stmt->fetchAll(PDO::FETCH_ASSOC));
} elseif ($act == 'create') {
    $data = json_decode(file_get_contents('php://input'), true);
    $stmt = $pdo->prepare("INSERT INTO networking_cards (user_id, user_name, user_avatar, role_needed, description, contact_info) VALUES (?, ?, ?, ?, ?, ?)");
    $stmt->execute([
        $data['user_id'],
        $data['user_name'],
        $data['user_avatar'] ?? null,
        $data['role_needed'],
        $data['description'],
        $data['contact_info']
    ]);
    echo json_encode(['success' => true]);
} elseif ($act == 'delete') {
    $data = json_decode(file_get_contents('php://input'), true);
    $stmt = $pdo->prepare("DELETE FROM networking_cards WHERE id = ?");
    $stmt->execute([$data['id']]);
    echo json_encode(['success' => true]);
}
?>
