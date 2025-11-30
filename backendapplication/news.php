<?php
header('Access-Control-Allow-Origin: *');
header('Content-Type: application/json');
require 'db.php';

$method = $_SERVER['REQUEST_METHOD'];
$act = $_GET['act'] ?? '';

if ($method == 'GET' && $act == 'list') {
    $q = $pdo->query("SELECT n.*, 
        (SELECT COUNT(*) FROM likes WHERE news_id = n.id) as likes_count,
        (SELECT COUNT(*) FROM comments WHERE news_id = n.id) as comments_count
        FROM news n ORDER BY created_at DESC");
    echo json_encode($q->fetchAll());
} elseif ($method == 'GET' && $act == 'comments') {
    $id = $_GET['id'];
    $q = $pdo->prepare("SELECT c.*, u.avatar as user_avatar FROM comments c LEFT JOIN users u ON c.user_id = u.id WHERE c.news_id = ? ORDER BY c.created_at DESC");
    $q->execute([$id]);
    echo json_encode($q->fetchAll());
} elseif ($method == 'POST') {
    $json = file_get_contents('php://input');
    $d = json_decode($json, true);
    
    if ($act == 'comment') {
        $q = $pdo->prepare("INSERT INTO comments (news_id, user_id, user_name, txt) VALUES (?, ?, ?, ?)");
        $q->execute([$d['news_id'], $d['user_id'], $d['user_name'], $d['txt']]);
        echo json_encode(['res' => true]);
    } elseif ($act == 'editcomment') {
        $q = $pdo->prepare("UPDATE comments SET txt = ? WHERE id = ? AND user_id = ?");
        $q->execute([$d['txt'], $d['comment_id'], $d['user_id']]);
        echo json_encode(['success' => true]);
    } elseif ($act == 'deletecomment') {
        $q = $pdo->prepare("DELETE FROM comments WHERE id = ? AND user_id = ?");
        $q->execute([$d['comment_id'], $d['user_id']]);
        echo json_encode(['success' => true]);
    } elseif ($act == 'like') {
        $q = $pdo->prepare("SELECT * FROM likes WHERE news_id = ? AND user_id = ?");
        $q->execute([$d['news_id'], $d['user_id']]);
        if ($q->fetch()) {
             $q = $pdo->prepare("DELETE FROM likes WHERE news_id = ? AND user_id = ?");
             $q->execute([$d['news_id'], $d['user_id']]);
             echo json_encode(['res' => 'unliked']);
        } else {
             $q = $pdo->prepare("INSERT INTO likes (news_id, user_id) VALUES (?, ?)");
             $q->execute([$d['news_id'], $d['user_id']]);
             echo json_encode(['res' => 'liked']);
        }
    }
}
