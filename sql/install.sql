CREATE TABLE IF NOT EXISTS `rs_dyno_history` (
  `id` int unsigned NOT NULL AUTO_INCREMENT, `plate` varchar(12) NOT NULL, `model` varchar(64) NOT NULL,
  `mechanic_identifier` varchar(80) NOT NULL, `mechanic_name` varchar(64) NOT NULL, `horsepower` int unsigned NOT NULL,
  `torque` int unsigned NOT NULL, `top_speed` int unsigned NOT NULL, `zero_to_hundred` decimal(5,2) NOT NULL DEFAULT 0,
  `tested_at` timestamp NOT NULL DEFAULT current_timestamp(), PRIMARY KEY (`id`), KEY `plate` (`plate`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
