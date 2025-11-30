<?php
header('Access-Control-Allow-Origin: *');
header('Content-Type: application/json');
require 'db.php';

$act = $_GET['act'] ?? '';

if ($act == 'list') {
    $offset = (int)($_GET['offset'] ?? 0);
    $limit = 10;
    
    $stmt = $pdo->prepare("
        SELECT v.*, u.name as author_name, u.avatar as author_avatar,
        (SELECT COUNT(*) FROM ittok_likes WHERE video_id = v.id) as likes_count
        FROM ittok_videos v
        JOIN users u ON v.user_id = u.id
        WHERE v.status = 'active'
        ORDER BY v.created_at DESC
        LIMIT ? OFFSET ?
    ");
    $stmt->execute([$limit, $offset]);
    echo json_encode(['res' => true, 'data' => $stmt->fetchAll()]);
    
} elseif ($act == 'upload') {
    $d = json_decode(file_get_contents('php://input'), true);
    $uid = $d['user_id'];
    $title = $d['title'] ?? '';
    $desc = $d['description'] ?? '';
    $videoUrl = $d['video_url'];
    $thumb = $d['thumbnail'] ?? '';
    
    $stmt = $pdo->prepare("INSERT INTO ittok_videos (user_id, title, description, video_url, thumbnail) VALUES (?, ?, ?, ?, ?)");
    if ($stmt->execute([$uid, $title, $desc, $videoUrl, $thumb])) {
        echo json_encode(['res' => true, 'id' => $pdo->lastInsertId()]);
    } else {
        echo json_encode(['res' => false, 'err' => 'Ошибка загрузки']);
    }
    
} elseif ($act == 'like') {
    $d = json_decode(file_get_contents('php://input'), true);
    $uid = $d['user_id'];
    $vid = $d['video_id'];
    
    $check = $pdo->prepare("SELECT * FROM ittok_likes WHERE user_id = ? AND video_id = ?");
    $check->execute([$uid, $vid]);
    
    if ($check->fetch()) {
        $stmt = $pdo->prepare("DELETE FROM ittok_likes WHERE user_id = ? AND video_id = ?");
        $stmt->execute([$uid, $vid]);
        echo json_encode(['res' => true, 'action' => 'unliked']);
    } else {
        $stmt = $pdo->prepare("INSERT INTO ittok_likes (user_id, video_id) VALUES (?, ?)");
        $stmt->execute([$uid, $vid]);
        echo json_encode(['res' => true, 'action' => 'liked']);
    }
    
} elseif ($act == 'view') {
    $d = json_decode(file_get_contents('php://input'), true);
    $vid = $d['video_id'];
    
    $stmt = $pdo->prepare("UPDATE ittok_videos SET views = views + 1 WHERE id = ?");
    $stmt->execute([$vid]);
    echo json_encode(['res' => true]);
}
?>
