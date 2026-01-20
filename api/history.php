<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');

require_once '../config/conexion.php';

$ticket_id = $_GET['ticket_id'] ?? null;
if (!$ticket_id) {
    http_response_code(400);
    echo json_encode(['error' => 'ticket_id es requerido']);
    exit();
}

try {
    $sql = "
        SELECT 
            th.field_changed,
            th.old_value,
            th.new_value,
            th.change_date,
            p.full_name AS changed_by_name,
            p.role AS changed_by_role
        FROM ticket_history th
        JOIN profiles p ON th.changed_by = p.id
        WHERE th.ticket_id = ?
        ORDER BY th.change_date ASC
    ";

    $stmt = $pdo->prepare($sql);
    $stmt->execute([$ticket_id]);
    $history = $stmt->fetchAll();

    echo json_encode(['history' => $history]);

} catch (Exception $e) {
    http_response_code(500);
    echo json_encode(['error' => 'Error al obtener el historial']);
}
?>