-- MySQL dump 10.13  Distrib 8.0.45, for Win64 (x86_64)
--
-- Host: localhost    Database: smart_parking
-- ------------------------------------------------------
-- Server version	8.0.45

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `audit_log`
--

DROP TABLE IF EXISTS `audit_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `audit_log` (
  `log_id` int NOT NULL AUTO_INCREMENT,
  `slot_id` int DEFAULT NULL,
  `old_status` varchar(20) DEFAULT NULL,
  `new_status` varchar(20) DEFAULT NULL,
  `change_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `changed_by` varchar(100) DEFAULT 'system',
  PRIMARY KEY (`log_id`),
  KEY `slot_id` (`slot_id`),
  CONSTRAINT `audit_log_ibfk_1` FOREIGN KEY (`slot_id`) REFERENCES `parking_slots` (`slot_id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `audit_log`
--

LOCK TABLES `audit_log` WRITE;
/*!40000 ALTER TABLE `audit_log` DISABLE KEYS */;
INSERT INTO `audit_log` VALUES (1,8,'AVAILABLE','OCCUPIED','2026-11-02 08:38:24','system'),(2,6,'AVAILABLE','OCCUPIED','2026-11-02 08:38:26','system'),(3,4,'AVAILABLE','OCCUPIED','2026-11-02 08:38:28','system'),(4,8,'OCCUPIED','AVAILABLE','2026-11-02 08:39:19','system'),(5,6,'OCCUPIED','AVAILABLE','2026-11-02 08:39:24','system');
/*!40000 ALTER TABLE `audit_log` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `parking_records`
--

DROP TABLE IF EXISTS `parking_records`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `parking_records` (
  `record_id` int NOT NULL AUTO_INCREMENT,
  `reservation_id` int NOT NULL,
  `entry_time` datetime DEFAULT NULL,
  `exit_time` datetime DEFAULT NULL,
  `duration_hours` decimal(8,2) DEFAULT '0.00',
  `parking_fee` decimal(10,2) DEFAULT '0.00',
  PRIMARY KEY (`record_id`),
  UNIQUE KEY `reservation_id` (`reservation_id`),
  CONSTRAINT `parking_records_ibfk_1` FOREIGN KEY (`reservation_id`) REFERENCES `reservations` (`reservation_id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `parking_records`
--

LOCK TABLES `parking_records` WRITE;
/*!40000 ALTER TABLE `parking_records` DISABLE KEYS */;
INSERT INTO `parking_records` VALUES (1,1,NULL,NULL,0.00,0.00),(2,2,'2026-11-02 14:08:28',NULL,0.00,0.00),(3,3,'2026-11-02 14:08:26','2026-11-02 14:09:24',1.00,20.00),(4,4,'2026-11-02 14:08:24','2026-11-02 14:09:19',1.00,20.00);
/*!40000 ALTER TABLE `parking_records` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `parking_slots`
--

DROP TABLE IF EXISTS `parking_slots`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `parking_slots` (
  `slot_id` int NOT NULL AUTO_INCREMENT,
  `slot_number` varchar(20) NOT NULL,
  `floor_number` int NOT NULL DEFAULT '1',
  `slot_type` enum('CAR','BIKE','EV') NOT NULL,
  `slot_status` enum('AVAILABLE','OCCUPIED','MAINTENANCE') NOT NULL DEFAULT 'AVAILABLE',
  PRIMARY KEY (`slot_id`),
  UNIQUE KEY `slot_number` (`slot_number`)
) ENGINE=InnoDB AUTO_INCREMENT=16 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `parking_slots`
--

LOCK TABLES `parking_slots` WRITE;
/*!40000 ALTER TABLE `parking_slots` DISABLE KEYS */;
INSERT INTO `parking_slots` VALUES (1,'A-01',1,'CAR','AVAILABLE'),(2,'A-02',1,'CAR','AVAILABLE'),(3,'A-03',1,'CAR','AVAILABLE'),(4,'B-01',1,'BIKE','OCCUPIED'),(5,'B-02',1,'BIKE','AVAILABLE'),(6,'E-01',2,'EV','AVAILABLE'),(7,'E-02',2,'EV','MAINTENANCE'),(8,'A-04',1,'CAR','AVAILABLE'),(9,'A-05',1,'CAR','AVAILABLE'),(10,'A-06',1,'CAR','AVAILABLE'),(11,'B-03',1,'BIKE','AVAILABLE'),(12,'B-04',1,'BIKE','AVAILABLE'),(13,'B-05',1,'BIKE','AVAILABLE'),(14,'E-03',2,'EV','AVAILABLE'),(15,'E-04',2,'EV','AVAILABLE');
/*!40000 ALTER TABLE `parking_slots` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `payments`
--

DROP TABLE IF EXISTS `payments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `payments` (
  `payment_id` int NOT NULL AUTO_INCREMENT,
  `record_id` int NOT NULL,
  `amount` decimal(10,2) NOT NULL DEFAULT '0.00',
  `payment_status` enum('PENDING','PAID') NOT NULL DEFAULT 'PENDING',
  `payment_date` datetime DEFAULT NULL,
  PRIMARY KEY (`payment_id`),
  KEY `record_id` (`record_id`),
  CONSTRAINT `payments_ibfk_1` FOREIGN KEY (`record_id`) REFERENCES `parking_records` (`record_id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `payments`
--

LOCK TABLES `payments` WRITE;
/*!40000 ALTER TABLE `payments` DISABLE KEYS */;
INSERT INTO `payments` VALUES (1,4,20.00,'PAID','2026-11-02 14:10:39'),(2,3,20.00,'PAID','2026-11-02 14:10:38');
/*!40000 ALTER TABLE `payments` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `reservations`
--

DROP TABLE IF EXISTS `reservations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `reservations` (
  `reservation_id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `vehicle_id` int NOT NULL,
  `slot_id` int NOT NULL,
  `start_time` datetime NOT NULL,
  `end_time` datetime NOT NULL,
  `booking_status` enum('BOOKED','ACTIVE','COMPLETED','CANCELLED') NOT NULL DEFAULT 'BOOKED',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`reservation_id`),
  KEY `user_id` (`user_id`),
  KEY `vehicle_id` (`vehicle_id`),
  KEY `slot_id` (`slot_id`),
  CONSTRAINT `reservations_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`),
  CONSTRAINT `reservations_ibfk_2` FOREIGN KEY (`vehicle_id`) REFERENCES `vehicles` (`vehicle_id`),
  CONSTRAINT `reservations_ibfk_3` FOREIGN KEY (`slot_id`) REFERENCES `parking_slots` (`slot_id`),
  CONSTRAINT `reservations_chk_1` CHECK ((`end_time` > `start_time`))
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `reservations`
--

LOCK TABLES `reservations` WRITE;
/*!40000 ALTER TABLE `reservations` DISABLE KEYS */;
INSERT INTO `reservations` VALUES (1,1,1,1,'2026-11-03 14:02:56','2026-11-03 17:02:57','BOOKED','2026-11-02 08:32:57'),(2,2,2,4,'2026-11-04 14:02:57','2026-11-04 16:02:57','ACTIVE','2026-11-02 08:32:57'),(3,3,3,6,'2026-11-05 14:02:57','2026-11-05 18:02:57','COMPLETED','2026-11-02 08:32:57'),(4,4,4,8,'2026-11-06 14:02:57','2026-11-06 16:02:57','COMPLETED','2026-11-02 08:32:57');
/*!40000 ALTER TABLE `reservations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `users` (
  `user_id` int NOT NULL AUTO_INCREMENT,
  `full_name` varchar(100) NOT NULL,
  `email` varchar(150) NOT NULL,
  `phone` varchar(20) DEFAULT NULL,
  PRIMARY KEY (`user_id`),
  UNIQUE KEY `email` (`email`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES (1,'Arshdeep Kaur','arshdeep@example.com','9876500001'),(2,'Simran Kaur','simran@example.com','9876500002'),(3,'Manpreet Singh','manpreet@example.com','9876500003'),(4,'Rahul Sharma','rahul@example.com','9876500004'),(5,'Priya Verma','priya@example.com','9876500005'),(6,'Amanpreet Singh','aman@example.com','9876500006'),(7,'Neha Gupta','neha@example.com','9876500007'),(8,'Karan Malhotra','karan@example.com','9876500008');
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `vehicles`
--

DROP TABLE IF EXISTS `vehicles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `vehicles` (
  `vehicle_id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `vehicle_number` varchar(30) NOT NULL,
  `vehicle_type` enum('CAR','BIKE','EV') NOT NULL,
  PRIMARY KEY (`vehicle_id`),
  UNIQUE KEY `vehicle_number` (`vehicle_number`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `vehicles_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `vehicles`
--

LOCK TABLES `vehicles` WRITE;
/*!40000 ALTER TABLE `vehicles` DISABLE KEYS */;
INSERT INTO `vehicles` VALUES (1,1,'PB65AB1234','CAR'),(2,2,'PB65CD5678','BIKE'),(3,3,'PB65EF9012','EV'),(4,4,'PB65GH3456','CAR'),(5,5,'PB65IJ7890','BIKE'),(6,6,'PB65KL2345','CAR'),(7,7,'PB65MN6789','EV'),(8,8,'PB65OP0123','CAR');
/*!40000 ALTER TABLE `vehicles` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-11-02 14:19:15
