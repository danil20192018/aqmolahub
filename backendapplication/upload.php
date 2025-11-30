<?php
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    exit(0);
}

header('Content-Type: application/json');

$type = $_GET['type'] ?? '';
$uploadDir = 'uploads/';

if (!file_exists($uploadDir)) {
    mkdir($uploadDir, 0777, true);
}

if ($type == 'avatar') {
    $avatarDir = $uploadDir . 'avatars/';
    if (!file_exists($avatarDir)) {
        mkdir($avatarDir, 0777, true);
    }
    
    if (isset($_FILES['file'])) {
        $userId = $_POST['user_id'] ?? 'unknown';
        $ext = pathinfo($_FILES['file']['name'], PATHINFO_EXTENSION);
        $filename = $userId . '_' . time() . '.' . $ext;
        $filepath = $avatarDir . $filename;
        
        if (move_uploaded_file($_FILES['file']['tmp_name'], $filepath)) {
            $proxyUrl = 'image.php?path=uploads/avatars/' . $filename;
            echo json_encode(['success' => true, 'url' => $proxyUrl]);
        } else {
            echo json_encode(['success' => false, 'error' => 'Upload failed']);
        }
    }
} elseif ($type == 'news') {
    $newsDir = $uploadDir . 'news/';
    if (!file_exists($newsDir)) {
        mkdir($newsDir, 0777, true);
    }
    
    if (isset($_FILES['file'])) {
        $ext = pathinfo($_FILES['file']['name'], PATHINFO_EXTENSION);
        $filename = 'news_' . time() . '.' . $ext;
        $filepath = $newsDir . $filename;
        
        if (move_uploaded_file($_FILES['file']['tmp_name'], $filepath)) {
            $proxyUrl = 'image.php?path=uploads/news/' . $filename;
            echo json_encode(['success' => true, 'url' => $proxyUrl]);
        } else {
            echo json_encode(['success' => false, 'error' => 'Upload failed']);
        }
    } else {
        echo json_encode(['success' => false, 'error' => 'No file uploaded']);
    }
} elseif ($type == 'event') {
    $eventDir = $uploadDir . 'events/';
    if (!file_exists($eventDir)) {
        mkdir($eventDir, 0777, true);
    }
    
    if (isset($_FILES['file'])) {
        $ext = pathinfo($_FILES['file']['name'], PATHINFO_EXTENSION);
        $filename = 'event_' . time() . '.' . $ext;
        $filepath = $eventDir . $filename;
        
        if (move_uploaded_file($_FILES['file']['tmp_name'], $filepath)) {
            $proxyUrl = 'image.php?path=uploads/events/' . $filename;
            echo json_encode(['success' => true, 'url' => $proxyUrl]);
        } else {
            echo json_encode(['success' => false, 'error' => 'Upload failed']);
        }
    } else {
        echo json_encode(['success' => false, 'error' => 'No file uploaded']);
    }
} elseif ($type == 'startup') {
    $startupDir = $uploadDir . 'startups/';
    if (!file_exists($startupDir)) {
        mkdir($startupDir, 0777, true);
    }
    
    if (isset($_FILES['file'])) {
        $ext = pathinfo($_FILES['file']['name'], PATHINFO_EXTENSION);
        $filename = 'startup_' . time() . '.' . $ext;
        $filepath = $startupDir . $filename;
        
        if (move_uploaded_file($_FILES['file']['tmp_name'], $filepath)) {
            $proxyUrl = 'image.php?path=uploads/startups/' . $filename;
            echo json_encode(['success' => true, 'url' => $proxyUrl]);
        } else {
            echo json_encode(['success' => false, 'error' => 'Upload failed']);
        }
    } else {
        echo json_encode(['success' => false, 'error' => 'No file uploaded']);
    }
} else {
    echo json_encode(['success' => false, 'error' => 'Invalid type']);
}
?>
