CREATE TABLE IF NOT EXISTS `crafting_player_profiles` (
  `identifier` varchar(80) NOT NULL,
  `global_xp` int NOT NULL DEFAULT 0,
  `global_level` int NOT NULL DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`identifier`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `crafting_player_category_xp` (
  `identifier` varchar(80) NOT NULL,
  `category_id` varchar(64) NOT NULL,
  `xp` int NOT NULL DEFAULT 0,
  `level` int NOT NULL DEFAULT 1,
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`identifier`, `category_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `crafting_player_blueprints` (
  `id` int NOT NULL AUTO_INCREMENT,
  `identifier` varchar(80) NOT NULL,
  `blueprint_id` varchar(64) NOT NULL,
  `uses_remaining` int DEFAULT NULL,
  `learned_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `identifier_blueprint` (`identifier`, `blueprint_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `crafting_recipes` (
  `id` int NOT NULL AUTO_INCREMENT,
  `slug` varchar(64) NOT NULL,
  `label` varchar(128) NOT NULL,
  `description` varchar(255) DEFAULT NULL,
  `category_id` varchar(64) NOT NULL,
  `craft_time_ms` int NOT NULL DEFAULT 10000,
  `global_xp` int NOT NULL DEFAULT 0,
  `category_xp` int NOT NULL DEFAULT 0,
  `required_global_level` int NOT NULL DEFAULT 1,
  `required_category_level` int NOT NULL DEFAULT 1,
  `blueprint_id` varchar(64) DEFAULT NULL,
  `enabled` tinyint(1) NOT NULL DEFAULT 1,
  PRIMARY KEY (`id`),
  UNIQUE KEY `slug` (`slug`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `crafting_recipe_ingredients` (
  `id` int NOT NULL AUTO_INCREMENT,
  `recipe_id` int NOT NULL,
  `item_name` varchar(64) NOT NULL,
  `amount` int NOT NULL,
  PRIMARY KEY (`id`),
  CONSTRAINT `fk_ingredient_recipe` FOREIGN KEY (`recipe_id`) REFERENCES `crafting_recipes` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `crafting_recipe_tools` (
  `id` int NOT NULL AUTO_INCREMENT,
  `recipe_id` int NOT NULL,
  `item_name` varchar(64) NOT NULL,
  `amount` int NOT NULL DEFAULT 1,
  PRIMARY KEY (`id`),
  CONSTRAINT `fk_tool_recipe` FOREIGN KEY (`recipe_id`) REFERENCES `crafting_recipes` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `crafting_recipe_results` (
  `id` int NOT NULL AUTO_INCREMENT,
  `recipe_id` int NOT NULL,
  `item_name` varchar(64) NOT NULL,
  `amount` int NOT NULL,
  PRIMARY KEY (`id`),
  CONSTRAINT `fk_result_recipe` FOREIGN KEY (`recipe_id`) REFERENCES `crafting_recipes` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `crafting_benches` (
  `id` int NOT NULL AUTO_INCREMENT,
  `bench_type` varchar(64) NOT NULL,
  `coords` longtext NOT NULL,
  `heading` float NOT NULL DEFAULT 0,
  `owner_identifier` varchar(80) DEFAULT NULL,
  `is_portable` tinyint(1) NOT NULL DEFAULT 0,
  `enabled` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO `crafting_recipes`
  (`slug`, `label`, `description`, `category_id`, `craft_time_ms`, `global_xp`, `category_xp`, `required_global_level`, `required_category_level`, `blueprint_id`, `enabled`)
VALUES
  ('meta_glasses', 'Meta Glasses', 'Refurbished smart glasses assembled from salvaged components.', 'electronics', 30000, 20, 32, 3, 2, NULL, 1)
ON DUPLICATE KEY UPDATE `label` = VALUES(`label`);

SET @meta_glasses_recipe_id = (SELECT `id` FROM `crafting_recipes` WHERE `slug` = 'meta_glasses' LIMIT 1);

DELETE FROM `crafting_recipe_ingredients` WHERE `recipe_id` = @meta_glasses_recipe_id;
INSERT INTO `crafting_recipe_ingredients` (`recipe_id`, `item_name`, `amount`) VALUES
  (@meta_glasses_recipe_id, 'brokenglasses', 2),
  (@meta_glasses_recipe_id, 'battery', 2),
  (@meta_glasses_recipe_id, 'cheap_phone_charger', 1);

DELETE FROM `crafting_recipe_tools` WHERE `recipe_id` = @meta_glasses_recipe_id;
INSERT INTO `crafting_recipe_tools` (`recipe_id`, `item_name`, `amount`) VALUES
  (@meta_glasses_recipe_id, 'screwdriver', 1);

DELETE FROM `crafting_recipe_results` WHERE `recipe_id` = @meta_glasses_recipe_id;
INSERT INTO `crafting_recipe_results` (`recipe_id`, `item_name`, `amount`) VALUES
  (@meta_glasses_recipe_id, 'meta_glasses', 1);
