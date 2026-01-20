<?php
// config/conexion.php
// Conexión segura a la base de datos MySQL usando PDO

$host = 'localhost';
$dbname = 'helpdesk';
$username = 'root';      // ← Cambiar según entorno del alumno
$password = '';          // ← Cambiar si usan contraseña

try {
    $pdo = new PDO("mysql:host=$host;dbname=$dbname;charset=utf8mb4", $username, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    $pdo->setAttribute(PDO::ATTR_DEFAULT_FETCH_MODE, PDO::FETCH_ASSOC);
} catch (PDOException $e) {
    // En producción, no mostrar detalles del error
    http_response_code(500);
    echo json_encode(['error' => 'Error al conectar con la base de datos']);
    exit();
}
?>