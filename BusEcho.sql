-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: localhost
-- Generation Time: Oct 03, 2025 at 07:28 AM
-- Server version: 10.4.28-MariaDB
-- PHP Version: 8.2.4

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `busreview`
--

-- --------------------------------------------------------

--
-- Table structure for table `adminUser`
--

CREATE TABLE `adminUser` (
  `id` int(11) NOT NULL,
  `name` varchar(255) NOT NULL,
  `username` varchar(50) NOT NULL,
  `mail_id` varchar(100) NOT NULL,
  `password` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `adminUser`
--

INSERT INTO `adminUser` (`id`, `name`, `username`, `mail_id`, `password`) VALUES
(1, 'Maanoj', 'Maanoj123', 'maanojpalani@gmail.com', 'Maanoj@1234');

-- --------------------------------------------------------

--
-- Table structure for table `applogin`
--

CREATE TABLE `applogin` (
  `id` int(11) NOT NULL,
  `username` varchar(50) NOT NULL,
  `mail_id` varchar(100) NOT NULL,
  `password` varchar(255) NOT NULL,
  `phone_num` bigint(10) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `applogin`
--

INSERT INTO `applogin` (`id`, `username`, `mail_id`, `password`, `phone_num`) VALUES
(8, 'Maanoj2004', 'maanojpalani@gmail.com', '$2y$10$hMb.YI/FSm8EDPEcwiEd3.r61cg1rUCL6b9iAr7y3MI/mAZYsQ.kW', 8300162272);

-- --------------------------------------------------------

--
-- Table structure for table `buses`
--

CREATE TABLE `buses` (
  `bus_id` int(11) NOT NULL,
  `bus_operator` varchar(100) NOT NULL,
  `boarding_point` varchar(100) NOT NULL,
  `dropping_point` varchar(100) NOT NULL,
  `bus_type` enum('Sleeper','Seater') NOT NULL,
  `ac_type` enum('AC','Non AC') NOT NULL,
  `average_rating` float DEFAULT 0,
  `total_reviews` int(11) DEFAULT 0,
  `status` enum('pending','approved','rejected') DEFAULT 'pending'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `buses`
--

INSERT INTO `buses` (`bus_id`, `bus_operator`, `boarding_point`, `dropping_point`, `bus_type`, `ac_type`, `average_rating`, `total_reviews`, `status`) VALUES
(1, 'Krishna Travels', 'Chennai', 'Vellore', 'Seater', 'AC', 4, 2, 'approved'),
(3, 'KPN Travels', 'Chennai', 'Vellore', 'Sleeper', 'AC', 0, 0, 'approved'),
(4, 'VPN Travels', 'Chennai', 'Vellore', 'Sleeper', 'AC', 0, 0, 'approved');

-- --------------------------------------------------------

--
-- Table structure for table `bus_reviews`
--

CREATE TABLE `bus_reviews` (
  `id` int(11) NOT NULL,
  `user_id` int(11) DEFAULT NULL,
  `bus_operator` varchar(100) DEFAULT NULL,
  `bus_id` int(11) DEFAULT NULL,
  `bus_type` enum('Seater','Sleeper') DEFAULT NULL,
  `bus_number` varchar(50) DEFAULT NULL,
  `ticket_number` varchar(100) DEFAULT NULL,
  `boarding_point` varchar(100) DEFAULT NULL,
  `dropping_point` varchar(100) DEFAULT NULL,
  `date_of_travel` date DEFAULT NULL,
  `ac_type` enum('AC','Non AC') DEFAULT NULL,
  `overall_rating` double DEFAULT NULL,
  `punctuality_rating` double DEFAULT NULL,
  `cleanliness_rating` double DEFAULT NULL,
  `comfort_rating` double DEFAULT NULL,
  `staff_behaviour_rating` double DEFAULT NULL,
  `review_text` text DEFAULT NULL,
  `confirmed` tinyint(1) DEFAULT 0,
  `status` enum('pending','approved','rejected') DEFAULT 'approved',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `bus_reviews`
--

INSERT INTO `bus_reviews` (`id`, `user_id`, `bus_operator`, `bus_id`, `bus_type`, `bus_number`, `ticket_number`, `boarding_point`, `dropping_point`, `date_of_travel`, `ac_type`, `overall_rating`, `punctuality_rating`, `cleanliness_rating`, `comfort_rating`, `staff_behaviour_rating`, `review_text`, `confirmed`, `status`, `created_at`) VALUES
(45, 15, 'Krishna Travels', 1, 'Seater', 'UNKNOWN', 'TEMP-45', 'Chennai', 'Vellore', '2025-05-15', 'AC', 4, 3, 4, 3, 1, 'The bus is comfortable and travel time is low', 1, 'approved', '2025-07-30 07:39:57'),
(47, 15, 'Krishna Travels', 1, 'Seater', 'UNKNOWN', 'TEMP-47', 'Chennai', 'Coimbatore', '2025-05-15', 'AC', 3, 4, 3, 4, 5, 'The bus was late and dirty.', 0, 'approved', '2025-08-07 07:58:55'),
(64, 15, 'Krishna Travels', 1, 'Seater', 'TN23DH2314', 'TS240919190800754117USVN', 'Chennai', 'Coimbatore', '2025-05-15', 'AC', 4, 4, 3, 4, 5, 'The bus was good', 1, 'approved', '2025-09-16 08:57:23');

--
-- Triggers `bus_reviews`
--
DELIMITER $$
CREATE TRIGGER `update_bus_rating_after_insert` AFTER INSERT ON `bus_reviews` FOR EACH ROW BEGIN
  IF NEW.confirmed = 1 AND NEW.status = 'approved' THEN
    UPDATE buses
    SET 
      average_rating = (
        SELECT AVG(overall_rating)
        FROM bus_reviews
        WHERE 
          bus_id = NEW.bus_id AND 
          bus_operator = NEW.bus_operator AND 
          confirmed = 1 AND status = 'active'
      ),
      total_reviews = (
        SELECT COUNT(*)
        FROM bus_reviews
        WHERE 
          bus_id = NEW.bus_id AND 
          bus_operator = NEW.bus_operator AND 
          confirmed = 1 AND status = 'approved'
      )
    WHERE 
      bus_id = NEW.bus_id AND 
      bus_operator = NEW.bus_operator;
  END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `update_bus_rating_after_update` AFTER UPDATE ON `bus_reviews` FOR EACH ROW BEGIN
  -- Only recalculate if the review is confirmed and active after update
  IF NEW.confirmed = 1 AND NEW.status = 'active' THEN
    UPDATE buses
    SET 
      average_rating = (
        SELECT AVG(overall_rating)
        FROM bus_reviews
        WHERE 
          bus_id = NEW.bus_id AND 
          bus_operator = NEW.bus_operator AND 
          confirmed = 1 AND status = 'active'
      ),
      total_reviews = (
        SELECT COUNT(*)
        FROM bus_reviews
        WHERE 
          bus_id = NEW.bus_id AND 
          bus_operator = NEW.bus_operator AND 
          confirmed = 1 AND status = 'active'
      )
    WHERE 
      bus_id = NEW.bus_id AND 
      bus_operator = NEW.bus_operator;
   ELSE
    -- If the updated review is no longer confirmed/active, still recalculate
    UPDATE buses
    SET 
      average_rating = (
        SELECT AVG(overall_rating)
        FROM bus_reviews
        WHERE 
          bus_id = OLD.bus_id AND 
          bus_operator = OLD.bus_operator AND 
          confirmed = 1 AND status = 'active'
      ),
      total_reviews = (
        SELECT COUNT(*)
        FROM bus_reviews
        WHERE 
          bus_id = OLD.bus_id AND 
          bus_operator = OLD.bus_operator AND 
          confirmed = 1 AND status = 'active'
      )
    WHERE 
      bus_id = OLD.bus_id AND 
      bus_operator = OLD.bus_operator;
  END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `ratings`
--

CREATE TABLE `ratings` (
  `id` int(11) NOT NULL,
  `rating` int(11) NOT NULL,
  `feedback` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `ratings`
--

INSERT INTO `ratings` (`id`, `rating`, `feedback`, `created_at`) VALUES
(1, 3, 'Decent app', '2025-09-11 03:10:23'),
(2, 4, 'The app is good', '2025-09-27 10:57:44');

-- --------------------------------------------------------

--
-- Table structure for table `review_comments`
--

CREATE TABLE `review_comments` (
  `id` int(11) NOT NULL,
  `review_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `comment_text` text NOT NULL,
  `created_at` datetime DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `review_comments`
--

INSERT INTO `review_comments` (`id`, `review_id`, `user_id`, `comment_text`, `created_at`) VALUES
(1, 45, 15, 'the service is good', '2025-08-02 08:48:48'),
(5, 45, 17, 'Poor service', '2025-08-02 15:06:37'),
(6, 45, 15, 'Bad service', '2025-08-02 15:06:55'),
(7, 47, 15, 'Hi', '2025-08-12 14:29:11'),
(9, 47, 15, 'Hi', '2025-08-21 15:08:32');

-- --------------------------------------------------------

--
-- Table structure for table `review_images`
--

CREATE TABLE `review_images` (
  `id` int(11) NOT NULL,
  `review_id` int(11) DEFAULT NULL,
  `image_path` varchar(500) DEFAULT NULL,
  `uploaded_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `review_images`
--

INSERT INTO `review_images` (`id`, `review_id`, `image_path`, `uploaded_at`) VALUES
(42, 45, 'uploads/review_6889cc4db2d90_0.jpg', '2025-07-30 07:39:57'),
(43, 45, 'uploads/review_6889cc4db348b_1.png', '2025-07-30 07:39:57'),
(48, 47, 'uploads/review_68945cbfb7627_0.jpg', '2025-08-07 07:58:55'),
(49, 47, 'uploads/review_68945cbfb7ba2_1.jpeg', '2025-08-07 07:58:55'),
(68, 64, 'uploads/review_68c926735c02c_0.jpg', '2025-09-16 08:57:23'),
(69, 64, 'uploads/review_68c926735c245_1.jpeg', '2025-09-16 08:57:23');

-- --------------------------------------------------------

--
-- Table structure for table `review_likes`
--

CREATE TABLE `review_likes` (
  `id` int(11) NOT NULL,
  `review_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `created_at` datetime DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `review_likes`
--

INSERT INTO `review_likes` (`id`, `review_id`, `user_id`, `created_at`) VALUES
(16, 45, 19, '2025-08-05 12:52:34'),
(24, 47, 20, '2025-08-23 09:48:22'),
(25, 45, 20, '2025-08-23 09:48:23'),
(118, 45, 15, '2025-08-23 11:49:11'),
(120, 47, 15, '2025-09-09 12:01:36'),
(123, 64, 15, '2025-09-25 09:58:41');

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `id` int(11) NOT NULL,
  `name` varchar(100) NOT NULL,
  `username` varchar(50) NOT NULL,
  `mail_id` varchar(100) NOT NULL,
  `password` varchar(255) NOT NULL,
  `phone_num` varchar(20) NOT NULL,
  `bio` text DEFAULT NULL,
  `is_deleted` tinyint(1) DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `name`, `username`, `mail_id`, `password`, `phone_num`, `bio`, `is_deleted`) VALUES
(15, 'Maanoj', 'Maanoj21', 'maanojpalani@gmail.com', '$2y$10$rkFmXo7b9em7qVMObmA4F.n4InK7hiGvX0jj.c.37pzPklcOo8uyW', '8300162272', 'Frequent intercity traveller', 0),
(16, 'Bavya', 'Bavya2307', 'mbavya2317@gmail.com', '$2y$10$aGQIEJMjBpM8BMsLu1tyz.7j0La.CIwH.l1kjzlGogjZq1BfT/i/2', '9444471523', NULL, 0),
(17, 'Santhosh', 'Santhosh12', 'santhoshmanoharan236@gmail.com', '$2y$10$LXLOSq4gq5iaYOlLApube.ccqieatIydFzV14w.X3Q9TNvuKGqmtu', '8072145013', NULL, 0),
(19, 'Maanoj', 'Maanoj123', 'maanojp4285.sse@saveetha.com', '$2y$10$9.XUjbh3TG.hUG9.4byqzOcpMEsh7Led281z3AJWg9o3nrGOx.BZi', '9597120570', NULL, 1),
(20, 'Akshaya', 'Akshaya14', 'akshayapalani9955@gmail.com', '$2y$10$xrYqgW0xiqLdi3.QYGOFduNN8m4vbLLXv3T4vPUMiae136GXN.Q6e', '9894437072', NULL, 0);

--
-- Indexes for dumped tables
--

--
-- Indexes for table `adminUser`
--
ALTER TABLE `adminUser`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `username` (`username`),
  ADD UNIQUE KEY `mail_id` (`mail_id`);

--
-- Indexes for table `applogin`
--
ALTER TABLE `applogin`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `username` (`username`),
  ADD UNIQUE KEY `email` (`mail_id`);

--
-- Indexes for table `buses`
--
ALTER TABLE `buses`
  ADD PRIMARY KEY (`bus_id`);

--
-- Indexes for table `bus_reviews`
--
ALTER TABLE `bus_reviews`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `ticket_number` (`ticket_number`),
  ADD KEY `fk_user_id` (`user_id`),
  ADD KEY `fk_bus_id` (`bus_id`);

--
-- Indexes for table `ratings`
--
ALTER TABLE `ratings`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `review_comments`
--
ALTER TABLE `review_comments`
  ADD PRIMARY KEY (`id`),
  ADD KEY `review_id` (`review_id`),
  ADD KEY `fk_comment_user` (`user_id`);

--
-- Indexes for table `review_images`
--
ALTER TABLE `review_images`
  ADD PRIMARY KEY (`id`),
  ADD KEY `review_id` (`review_id`);

--
-- Indexes for table `review_likes`
--
ALTER TABLE `review_likes`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `review_id` (`review_id`,`user_id`),
  ADD KEY `fk_user_review_likes` (`user_id`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `username` (`username`),
  ADD UNIQUE KEY `email` (`mail_id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `adminUser`
--
ALTER TABLE `adminUser`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `applogin`
--
ALTER TABLE `applogin`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT for table `buses`
--
ALTER TABLE `buses`
  MODIFY `bus_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `bus_reviews`
--
ALTER TABLE `bus_reviews`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=65;

--
-- AUTO_INCREMENT for table `ratings`
--
ALTER TABLE `ratings`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `review_comments`
--
ALTER TABLE `review_comments`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT for table `review_images`
--
ALTER TABLE `review_images`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=70;

--
-- AUTO_INCREMENT for table `review_likes`
--
ALTER TABLE `review_likes`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=124;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=21;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `bus_reviews`
--
ALTER TABLE `bus_reviews`
  ADD CONSTRAINT `bus_reviews_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  ADD CONSTRAINT `fk_bus_id` FOREIGN KEY (`bus_id`) REFERENCES `buses` (`bus_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_review_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_user_id` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  ADD CONSTRAINT `fk_user_reviews` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `review_comments`
--
ALTER TABLE `review_comments`
  ADD CONSTRAINT `fk_comment_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_user_review_comments` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `review_comments_ibfk_1` FOREIGN KEY (`review_id`) REFERENCES `bus_reviews` (`id`),
  ADD CONSTRAINT `review_comments_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`);

--
-- Constraints for table `review_images`
--
ALTER TABLE `review_images`
  ADD CONSTRAINT `review_images_ibfk_1` FOREIGN KEY (`review_id`) REFERENCES `bus_reviews` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `review_likes`
--
ALTER TABLE `review_likes`
  ADD CONSTRAINT `fk_user_review_likes` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `review_likes_ibfk_1` FOREIGN KEY (`review_id`) REFERENCES `bus_reviews` (`id`),
  ADD CONSTRAINT `review_likes_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
