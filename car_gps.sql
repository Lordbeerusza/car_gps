-- ========================================
-- 🚗 Car GPS Tracker System SQL Patch
-- ========================================

-- 📌 Adds required columns to `player_vehicles` if they don't exist
-- Compatible with MySQL and MariaDB

ALTER TABLE player_vehicles
ADD COLUMN IF NOT EXISTS gps_installed TINYINT(1) NOT NULL DEFAULT 0;

ALTER TABLE player_vehicles
ADD COLUMN IF NOT EXISTS perm_gps TINYINT(1) NOT NULL DEFAULT 0;

ALTER TABLE player_vehicles
ADD COLUMN IF NOT EXISTS gps_last_x DOUBLE DEFAULT NULL;

ALTER TABLE player_vehicles
ADD COLUMN IF NOT EXISTS gps_last_y DOUBLE DEFAULT NULL;

ALTER TABLE player_vehicles
ADD COLUMN IF NOT EXISTS gps_last_z DOUBLE DEFAULT NULL;
