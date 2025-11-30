<?php
header('Access-Control-Allow-Origin: *');
header('Content-Type: application/json');
require 'db.php';

$act = $_GET['act'] ?? '';

if ($act == 'create') {
    $d = json_decode(file_get_contents('php://input'), true);
    $uid = $d['user_id'];
    $name = $d['name'];
    $role = $d['role'];
    $bio = $d['bio'] ?? '';
    $skills = $d['skills'] ?? '';
    $contact = $d['contact'] ?? '';
    $avatar = $d['avatar'] ?? '';
    $theme = $d['theme'] ?? 'blue';
    
    $qrCode = 'QR_' . uniqid();
    
    $check = $pdo->prepare("SELECT * FROM qr_cards WHERE user_id = ?");
    $check->execute([$uid]);
    
    if ($check->fetch()) {
        $stmt = $pdo->prepare("UPDATE qr_cards SET name=?, role=?, bio=?, skills=?, contact=?, avatar=?, theme=? WHERE user_id=?");
        $stmt->execute([$name, $role, $bio, $skills, $contact, $avatar, $theme, $uid]);
    } else {
        $stmt = $pdo->prepare("INSERT INTO qr_cards (user_id, qr_code, name, role, bio, skills, contact, avatar, theme) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)");
        $stmt->execute([$uid, $qrCode, $name, $role, $bio, $skills, $contact, $avatar, $theme]);
    }
    
    $get = $pdo->prepare("SELECT * FROM qr_cards WHERE user_id = ?");
    $get->execute([$uid]);
    echo json_encode(['res' => true, 'data' => $get->fetch()]);
    
} elseif ($act == 'get') {
    $qr = $_GET['qr'] ?? '';
    $stmt = $pdo->prepare("SELECT * FROM qr_cards WHERE qr_code = ?");
    $stmt->execute([$qr]);
    $data = $stmt->fetch();
    
    if ($data) {
        $pdo->prepare("UPDATE qr_cards SET scans = scans + 1 WHERE qr_code = ?")->execute([$qr]);
        echo json_encode(['res' => true, 'data' => $data]);
    } else {
        echo json_encode(['res' => false, 'err' => 'QR не найден']);
    }
    
} elseif ($act == 'my') {
    $uid = $_GET['user_id'] ?? 0;
    $stmt = $pdo->prepare("SELECT * FROM qr_cards WHERE user_id = ?");
    $stmt->execute([$uid]);
    $data = $stmt->fetch();
    
    if ($data) {
        echo json_encode(['res' => true, 'data' => $data]);
    } else {
        echo json_encode(['res' => false]);
    }
}
?>
