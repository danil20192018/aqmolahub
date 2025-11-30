<?php
header('Access-Control-Allow-Origin: *');
header('Content-Type: application/json');
require 'db.php';

$json = file_get_contents('php://input');
$data = json_decode($json, true);
$act = $_GET['act'] ?? '';

if ($act == 'tg') {
    $tid = $data['telegram_id'];
    $q = $pdo->prepare("SELECT * FROM users WHERE telegram_id = ?");
    $q->execute([$tid]);
    $u = $q->fetch();
    
    if ($u) {
        echo json_encode(['res' => true, 't' => bin2hex(random_bytes(16)), 'r' => $u['role'], 'name' => $u['name'], 'user_id' => $u['id'], 'avatar' => $u['avatar']]);
    } else {
        echo json_encode(['res' => false]);
    }
}
