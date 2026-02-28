-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Servidor: localhost:3306
-- Tiempo de generación: 28-02-2026 a las 17:34:12
-- Versión del servidor: 8.0.30
-- Versión de PHP: 8.2.18

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de datos: `helpdesk`
--

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `categories`
--

CREATE TABLE `categories` (
  `id` char(36) NOT NULL,
  `name` varchar(100) NOT NULL,
  `description` text,
  `color` varchar(20) DEFAULT '#2563eb',
  `icon` varchar(50) DEFAULT 'help-circle',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Volcado de datos para la tabla `categories`
--

INSERT INTO `categories` (`id`, `name`, `description`, `color`, `icon`, `created_at`) VALUES
('cat-001', 'Error de Sistema', 'Problemas técnicos y bugs', '#ef4444', 'bug', '2026-01-20 12:59:29'),
('cat-002', 'Solicitud de Compra', 'Compra de materiales', '#10b981', 'shopping-cart', '2026-01-20 12:59:29'),
('cat-003', 'Soporte Técnico', 'Asistencia técnica', '#3b82f6', 'headphones', '2026-01-20 12:59:29'),
('cat-004', 'Desarrollo', 'Nuevas funcionalidades', '#8b5cf6', 'code', '2026-01-20 12:59:29'),
('cat-005', 'General', 'Otras solicitudes', '#6b7280', 'help-circle', '2026-01-20 12:59:29');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `comments`
--

CREATE TABLE `comments` (
  `id` char(36) NOT NULL,
  `ticket_id` char(36) NOT NULL,
  `user_id` char(36) NOT NULL,
  `content` text NOT NULL,
  `is_internal` tinyint(1) DEFAULT '0',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Volcado de datos para la tabla `comments`
--

INSERT INTO `comments` (`id`, `ticket_id`, `user_id`, `content`, `is_internal`, `created_at`) VALUES
('comment-825d7660aab9fc2d', 'ticket-cf02aba3c57ebec1', 'user-001', 'prueba de un comentario', 1, '2026-01-22 00:42:31'),
('comment-993516f76b349284', 'ticket-cf02aba3c57ebec1', 'user-001', 'Otro comentario', 1, '2026-01-22 00:42:44'),
('comment-a1b2c3d4e5f67890', 'ticket-a1b2c3d4e5f67890', 'user-003', 'Esto me pasa desde ayer por la tarde', 0, '2026-01-20 12:59:29'),
('comment-b2c3d4e5f67890a1', 'ticket-a1b2c3d4e5f67890', 'user-002', 'Voy a revisar el problema, ¿puedes enviar una captura de pantalla?', 0, '2026-01-20 12:59:29'),
('comment-c3d4e5f67890a1b2', 'ticket-c3d4e5f67890a1b2', 'user-002', 'Problema solucionado en la versión 2.1', 0, '2026-01-20 12:59:29'),
('comment-d4e5f67890a1b2c3', 'ticket-a1b2c3d4e5f67890', 'user-003', 'Adjunto captura de pantalla del error.', 0, '2026-01-20 20:14:06');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `profiles`
--

CREATE TABLE `profiles` (
  `id` char(36) NOT NULL,
  `email` varchar(255) NOT NULL,
  `full_name` varchar(255) DEFAULT NULL,
  `role` varchar(20) DEFAULT 'user',
  `avatar_url` text,
  `password_hash` varchar(255) NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Volcado de datos para la tabla `profiles`
--

INSERT INTO `profiles` (`id`, `email`, `full_name`, `role`, `avatar_url`, `password_hash`, `created_at`) VALUES
('user-001', 'admin@helpdesk.com', 'Administrador', 'admin', NULL, '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', '2026-01-20 12:59:29'),
('user-002', 'agente@helpdesk.com', 'Agente Soporte', 'agent', NULL, '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', '2026-01-20 12:59:29'),
('user-003', 'usuario@helpdesk.com', 'Juan Pérez', 'user', NULL, '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', '2026-01-20 12:59:29');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tickets`
--

CREATE TABLE `tickets` (
  `id` char(36) NOT NULL,
  `title` varchar(255) NOT NULL,
  `description` text NOT NULL,
  `status` varchar(20) DEFAULT 'open',
  `priority` varchar(20) DEFAULT 'medium',
  `created_by` char(36) NOT NULL,
  `assigned_to` char(36) DEFAULT NULL,
  `category_id` char(36) DEFAULT NULL,
  `due_date` timestamp NULL DEFAULT NULL,
  `completed_at` timestamp NULL DEFAULT NULL,
  `module` varchar(20) DEFAULT 'support',
  `purchase_details` text,
  `error_details` text,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Volcado de datos para la tabla `tickets`
--

INSERT INTO `tickets` (`id`, `title`, `description`, `status`, `priority`, `created_by`, `assigned_to`, `category_id`, `due_date`, `completed_at`, `module`, `purchase_details`, `error_details`, `created_at`, `updated_at`) VALUES
('ticket-0a1b2c3d4e5f6789', 'Solicitar acceso a Base de Datos', 'Necesito permisos de lectura para el proyecto X', 'pending', 'medium', 'user-003', NULL, 'cat-004', NULL, NULL, 'development', NULL, NULL, '2026-01-20 16:23:45', '2026-01-20 16:23:45'),
('ticket-1b2c3d4e5f67890a', 'Problema con impresora', 'La impresora del piso 2 no responde', 'open', 'high', 'user-003', NULL, 'cat-003', NULL, NULL, 'support', NULL, NULL, '2026-01-20 16:35:03', '2026-01-20 16:35:03'),
('ticket-214927d97ca6fbf7', 'Prueba de un tickect desde un usuario', 'descripcion', 'open', 'medium', 'user-003', NULL, 'cat-005', NULL, NULL, 'support', NULL, NULL, '2026-01-22 19:44:16', '2026-01-22 19:44:16'),
('ticket-359f99f6b4f2f8d3', 'Revisar el cable de red del gerente de mercadeo', 'Pasar el cable a grado 6', 'open', 'medium', 'user-001', NULL, 'cat-003', NULL, NULL, 'support', NULL, NULL, '2026-01-22 18:18:02', '2026-01-22 18:18:02'),
('ticket-7890a1b2c3d4e5f6', 'Asignar laptop a nuevo empleado', 'Solicitar equipo para el nuevo desarrollador', 'open', 'medium', 'user-002', NULL, 'cat-002', NULL, NULL, 'support', NULL, NULL, '2026-01-20 16:23:45', '2026-01-20 16:23:45'),
('ticket-890a1b2c3d4e5f67', 'Capacitación en sistema de tickets', 'Preparar taller para nuevos agentes', 'resolved', 'low', 'user-002', NULL, 'cat-005', NULL, NULL, 'training', NULL, NULL, '2026-01-20 16:23:45', '2026-01-20 16:23:45'),
('ticket-8dfa9b32a5f02b48', 'Prueba de otro ticket de el agente', 'descripcion', 'open', 'medium', 'user-002', NULL, 'cat-004', NULL, NULL, 'support', NULL, NULL, '2026-01-22 19:22:24', '2026-01-22 19:22:24'),
('ticket-90a1b2c3d4e5f678', 'Error al subir archivos', 'El botón de adjuntar no responde en Chrome', 'open', 'urgent', 'user-003', NULL, 'cat-001', NULL, NULL, 'support', NULL, NULL, '2026-01-20 16:23:45', '2026-01-20 16:23:45'),
('ticket-a1b2c3d4e5f67890', 'No puedo iniciar sesión', 'El sistema me muestra error al ingresar mis credenciales', 'in_progress', 'urgent', 'user-003', 'user-002', 'cat-001', NULL, NULL, 'support', NULL, NULL, '2026-01-20 12:59:29', '2026-01-20 20:43:16'),
('ticket-b2c3d4e5f67890a1', 'Necesito una laptop nueva', 'Mi equipo actual ya no soporta el software necesario', 'resolved', 'medium', 'user-003', 'user-002', 'cat-002', NULL, NULL, 'support', NULL, NULL, '2026-01-20 12:59:29', '2026-01-20 20:36:53'),
('ticket-c3d4e5f67890a1b2', 'Error en reporte mensual', 'El reporte de ventas no genera los totales correctamente', 'resolved', 'urgent', 'user-003', NULL, 'cat-004', NULL, NULL, 'support', NULL, NULL, '2026-01-20 12:59:29', '2026-01-20 12:59:29'),
('ticket-cf02aba3c57ebec1', 'Buscar los drivers de la impresora Epson de  compras', 'Los que están instalados  dan error, son muy viejo vienen de w7', 'open', 'urgent', 'user-001', NULL, 'cat-003', NULL, NULL, 'support', NULL, NULL, '2026-01-22 00:37:49', '2026-01-22 00:37:49'),
('ticket-d4e5f67890a1b2c3', 'Prueba de filtrado', 'Este ticket fue creado por el admin', 'open', 'low', 'user-001', NULL, 'cat-005', NULL, NULL, 'support', NULL, NULL, '2026-01-20 16:20:30', '2026-01-20 16:20:30'),
('ticket-e5ab27ae2a00e3ba', 'prueba del Agente Soporte', 'este es una prueba desde el usuario Agente soporte', 'open', 'medium', 'user-002', NULL, 'cat-004', NULL, NULL, 'support', NULL, NULL, '2026-01-22 18:33:34', '2026-01-22 18:33:34'),
('ticket-e5f67890a1b2c3d4', 'Actualizar versión de PHP', 'Migrar servidor a PHP 8.3 para mayor seguridad', 'open', 'high', 'user-001', NULL, 'cat-004', NULL, NULL, 'development', NULL, NULL, '2026-01-20 16:23:45', '2026-01-20 16:23:45'),
('ticket-f67890a1b2c3d4e5', 'Revisar backups diarios', 'Verificar que los backups se estén generando correctamente', 'in_progress', 'medium', 'user-001', NULL, 'cat-001', NULL, NULL, 'support', NULL, NULL, '2026-01-20 16:23:45', '2026-01-20 16:23:45');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `ticket_history`
--

CREATE TABLE `ticket_history` (
  `id` char(36) NOT NULL,
  `ticket_id` char(36) NOT NULL,
  `changed_by` char(36) NOT NULL,
  `field_changed` varchar(100) NOT NULL,
  `old_value` text,
  `new_value` text,
  `change_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Volcado de datos para la tabla `ticket_history`
--

INSERT INTO `ticket_history` (`id`, `ticket_id`, `changed_by`, `field_changed`, `old_value`, `new_value`, `change_date`) VALUES
('hist-a1b2c3d4e5f67890', 'ticket-b2c3d4e5f67890a1', 'user-001', 'assigned_to', NULL, 'user-002', '2026-01-20 20:36:53'),
('hist-b2c3d4e5f67890a1', 'ticket-b2c3d4e5f67890a1', 'user-001', 'status', 'in_progress', 'resolved', '2026-01-20 20:36:53'),
('hist-c3d4e5f67890a1b2', 'ticket-a1b2c3d4e5f67890', 'user-001', 'status', 'resolved', 'in_progress', '2026-01-20 20:43:16');

--
-- Índices para tablas volcadas
--

--
-- Indices de la tabla `categories`
--
ALTER TABLE `categories`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `name` (`name`);

--
-- Indices de la tabla `comments`
--
ALTER TABLE `comments`
  ADD PRIMARY KEY (`id`),
  ADD KEY `ticket_id` (`ticket_id`),
  ADD KEY `user_id` (`user_id`);

--
-- Indices de la tabla `profiles`
--
ALTER TABLE `profiles`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `email` (`email`);

--
-- Indices de la tabla `tickets`
--
ALTER TABLE `tickets`
  ADD PRIMARY KEY (`id`),
  ADD KEY `created_by` (`created_by`),
  ADD KEY `assigned_to` (`assigned_to`),
  ADD KEY `category_id` (`category_id`);

--
-- Indices de la tabla `ticket_history`
--
ALTER TABLE `ticket_history`
  ADD PRIMARY KEY (`id`),
  ADD KEY `ticket_id` (`ticket_id`),
  ADD KEY `changed_by` (`changed_by`);

--
-- Restricciones para tablas volcadas
--

--
-- Filtros para la tabla `comments`
--
ALTER TABLE `comments`
  ADD CONSTRAINT `comments_ibfk_1` FOREIGN KEY (`ticket_id`) REFERENCES `tickets` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `comments_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `profiles` (`id`) ON DELETE CASCADE;

--
-- Filtros para la tabla `tickets`
--
ALTER TABLE `tickets`
  ADD CONSTRAINT `tickets_ibfk_1` FOREIGN KEY (`created_by`) REFERENCES `profiles` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `tickets_ibfk_2` FOREIGN KEY (`assigned_to`) REFERENCES `profiles` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `tickets_ibfk_3` FOREIGN KEY (`category_id`) REFERENCES `categories` (`id`) ON DELETE SET NULL;

--
-- Filtros para la tabla `ticket_history`
--
ALTER TABLE `ticket_history`
  ADD CONSTRAINT `ticket_history_ibfk_1` FOREIGN KEY (`ticket_id`) REFERENCES `tickets` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `ticket_history_ibfk_2` FOREIGN KEY (`changed_by`) REFERENCES `profiles` (`id`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
