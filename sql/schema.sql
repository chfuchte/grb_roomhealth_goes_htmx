CREATE TABLE `users` (
    `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
    `username` VARCHAR(12) NOT NULL UNIQUE,
    `email` VARCHAR(255) UNIQUE,
    `first_name` VARCHAR(50) NOT NULL,
    `last_name` VARCHAR(50) NOT NULL,
    `password_hash` VARCHAR(255) NOT NULL,
    `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP(),
    PRIMARY KEY (`id`)
);

CREATE INDEX `idx_users_username` ON `users` (`username`);

CREATE TABLE `sessions` (
    `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `token` VARCHAR(255) NOT NULL UNIQUE,
    `user_id` INT UNSIGNED NOT NULL,
    `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP(),
    PRIMARY KEY (`id`),
    FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
);

CREATE INDEX `idx_sessions_token` ON `sessions` (`token`);

CREATE TABLE `permissions` (
    `id` TINYINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `name` VARCHAR(50) NOT NULL UNIQUE,
    `description` TEXT NOT NULL,
    PRIMARY KEY (`id`)
);

CREATE INDEX `idx_permissions_name` ON `permissions` (`name`);

CREATE TABLE `user_permissions` (
    `user_id` INT UNSIGNED NOT NULL,
    `permission_id` TINYINT UNSIGNED NOT NULL,
    PRIMARY KEY (`user_id`, `permission_id`),
    FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
    FOREIGN KEY (`permission_id`) REFERENCES `permissions` (`id`) ON DELETE CASCADE
);

CREATE INDEX `idx_user_permissions_user_id` ON `user_permissions` (`user_id`);

CREATE INDEX `idx_user_permissions_permission_id` ON `user_permissions` (`permission_id`);

CREATE TABLE `rooms` (
    `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
    `roomnr` VARCHAR(4) NOT NULL UNIQUE,
    `section` ENUM ("A", "B", "C", "D", "E", "F", "SPH") NOT NULL,
    `floor` TINYINT NOT NULL CHECK (`floor` BETWEEN -1 AND 2),
    `description` TEXT NOT NULL,
    PRIMARY KEY (`id`),
    UNIQUE (`section`, `floor`)
);

CREATE INDEX `idx_rooms_section_floor` ON `rooms` (`section`, `floor`);

CREATE INDEX `idx_rooms_roomnr` ON `rooms` (`roomnr`);

CREATE TABLE `device_types` (
    `id` TINYINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `name` VARCHAR(50) NOT NULL UNIQUE,
    PRIMARY KEY (`id`)
);

CREATE INDEX `idx_device_types_name` ON `device_types` (`name`);

CREATE TABLE `devices` (
    `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
    `name` VARCHAR(255) NOT NULL,
    `notes` TEXT,
    `device_type_id` TINYINT UNSIGNED NOT NULL,
    `status` ENUM ("OK", "LIMITED", "CORRUPTED", "DEFECT") NOT NULL,
    `room_id` INT UNSIGNED NOT NULL,
    `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP(),
    `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP() ON UPDATE CURRENT_TIMESTAMP(),
    PRIMARY KEY (`id`),
    FOREIGN KEY (`room_id`) REFERENCES `rooms` (`id`) ON DELETE CASCADE,
    FOREIGN KEY (`device_type_id`) REFERENCES `device_types` (`id`) ON DELETE RESTRICT
);

CREATE INDEX `idx_devices_room_id` ON `devices` (`room_id`);
