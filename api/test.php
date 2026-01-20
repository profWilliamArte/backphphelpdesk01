<?php
require_once '../config/conexion.php';
echo json_encode(['status' => 'Conexión exitosa', 'time' => date('Y-m-d H:i:s')]);
?>