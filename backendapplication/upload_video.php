<?php
header('Access-Control-Allow-Origin: *');
header('Content-Type: application/json');

if ($_SERVER['REQUEST_METHOD'] == 'POST' && isset($_FILES['video'])) {
    $dir = __DIR__ . '/uploads/videos/';
    if (!is_dir($dir)) mkdir($dir, 0777, true);
    
    $ext = pathinfo($_FILES['video']['name'], PATHINFO_EXTENSION);
    $allowed = ['mp4', 'mov', 'avi', 'webm'];
    
    if (!in_array(strtolower($ext), $allowed)) {
        echo json_encode(['res' => false, 'err' => 'неправильный формат']);
        exit;
    }
    
    if ($_FILES['video']['size'] > 100 * 1024 * 1024) {
        echo json_encode(['res' => false, 'err' => 'файл слишком большой ']);
        exit;
    }
    
    $name = uniqid() . '.' . $ext;
    $path = $dir . $name;
    
    if (move_uploaded_file($_FILES['video']['tmp_name'], $path)) {
        $url = 'https://aqmolarp.kz/backendapplication/uploads/videos/' . $name;
        echo json_encode(['res' => true, 'url' => $url]);
    } else {
        echo json_encode(['res' => false, 'err' => 'ошика загрузки']);
    }
} else {
    echo json_encode(['res' => false, 'err' => 'нет файла']);
}
?>
