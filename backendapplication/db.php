<?php
$h = 'localhost';
$d = 'broldru_baze';
$u = 'broldru_baze';
$p = 'hackathon2025';

$dsn = "mysql:host=$h;dbname=$d;charset=utf8";
$opt = [
    PDO::ATTR_ERRMODE            => PDO::ERRMODE_EXCEPTION,
    PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
    PDO::ATTR_EMULATE_PREPARES   => false,
];

try {
     $pdo = new PDO($dsn, $u, $p, $opt);
} catch (\PDOException $e) {
     die('ошибка базы данных братан');
}
