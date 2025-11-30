<?php
header('Access-Control-Allow-Origin: *');
header('Content-Type: application/json');
require 'db.php';

$act = $_GET['act'] ?? '';
$json = file_get_contents('php://input');
$d = json_decode($json, true);

if ($act == 'create_qr') {
    $code = bin2hex(random_bytes(16));
    $coins = $d['coins'] ?? 10;
    $label = $d['label'] ?? null;
    $q = $pdo->prepare("INSERT INTO qr_codes (code, coins, label, created_by) VALUES (?, ?, ?, ?)");
    $q->execute([$code, $coins, $label, $d['admin_id']]);
    echo json_encode(['res' => true, 'code' => $code]);
} elseif ($act == 'scan_qr') {
    $code = $d['code'];
    $uid = $d['user_id'];
    
    $q = $pdo->prepare("SELECT * FROM qr_codes WHERE code = ?");
    $q->execute([$code]);
    $qr = $q->fetch();
    
    if (!$qr) {
        echo json_encode(['res' => false, 'err' => 'неверный код']);
        exit;
    }
    
    if ($qr['active'] == 0) {
        echo json_encode(['res' => false, 'err' => 'QR деактивирован']);
        exit;
    }
    
    $q = $pdo->prepare("SELECT * FROM qr_scans WHERE qr_id = ? AND user_id = ?");
    $q->execute([$qr['id'], $uid]);
    $already = $q->fetch();
    
    if ($already) {
        echo json_encode(['res' => false, 'err' => 'ты уже сканировал этот QR']);
    } else {
        $q = $pdo->prepare("INSERT INTO qr_scans (qr_id, user_id) VALUES (?, ?)");
        $q->execute([$qr['id'], $uid]);
        
        $q = $pdo->prepare("UPDATE users SET coins = coins + ? WHERE id = ?");
        $q->execute([$qr['coins'], $uid]);
        
        echo json_encode(['res' => true, 'coins' => $qr['coins']]);
    }
} elseif ($act == 'get_balance') {
    $uid = $_GET['user_id'];
    $q = $pdo->prepare("SELECT coins FROM users WHERE id = ?");
    $q->execute([$uid]);
    $u = $q->fetch();
    echo json_encode(['coins' => $u['coins'] ?? 0]);
} elseif ($act == 'list_qr') {
    $q = $pdo->query("SELECT q.*, 
        (SELECT COUNT(*) FROM qr_scans WHERE qr_id = q.id) as scan_count,
        (SELECT GROUP_CONCAT(u.name SEPARATOR ', ') FROM qr_scans s JOIN users u ON s.user_id = u.id WHERE s.qr_id = q.id) as scanned_by
        FROM qr_codes q ORDER BY q.id DESC");
    echo json_encode($q->fetchAll());
} elseif ($act == 'get_scans') {
    $qr_id = $_GET['qr_id'];
    $q = $pdo->prepare("SELECT s.*, u.name, u.email FROM qr_scans s JOIN users u ON s.user_id = u.id WHERE s.qr_id = ? ORDER BY s.scanned_at DESC");
    $q->execute([$qr_id]);
    echo json_encode($q->fetchAll());
} elseif ($act == 'update_label') {
    $q = $pdo->prepare("UPDATE qr_codes SET label = ? WHERE id = ?");
    $q->execute([$d['label'], $d['qr_id']]);
    echo json_encode(['res' => true]);
} elseif ($act == 'delete_qr') {
    $q = $pdo->prepare("DELETE FROM qr_scans WHERE qr_id = ?");
    $q->execute([$d['qr_id']]);
    $q = $pdo->prepare("DELETE FROM qr_codes WHERE id = ?");
    $q->execute([$d['qr_id']]);
    echo json_encode(['res' => true]);
} elseif ($act == 'toggle_active') {
    $q = $pdo->prepare("UPDATE qr_codes SET active = ? WHERE id = ?");
    $q->execute([$d['active'], $d['qr_id']]);
    echo json_encode(['res' => true]);
}
?>
