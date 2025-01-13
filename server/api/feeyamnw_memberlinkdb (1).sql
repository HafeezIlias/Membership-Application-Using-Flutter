-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: localhost:3306
-- Generation Time: Jan 13, 2025 at 04:29 PM
-- Server version: 10.3.39-MariaDB-cll-lve
-- PHP Version: 8.1.31

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `feeyamnw_memberlinkdb`
--

-- --------------------------------------------------------

--
-- Table structure for table `tbl_cart`
--

CREATE TABLE `tbl_cart` (
  `cart_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `product_id` int(11) NOT NULL,
  `quantity` int(11) NOT NULL DEFAULT 1,
  `date_added` timestamp NOT NULL DEFAULT current_timestamp(),
  `cart_status` enum('New','Paid') NOT NULL DEFAULT 'New'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `tbl_cart`
--

INSERT INTO `tbl_cart` (`cart_id`, `user_id`, `product_id`, `quantity`, `date_added`, `cart_status`) VALUES
(1, 1, 3, 1, '2024-12-11 20:06:00', 'New'),
(3, 1, 2, 2, '2024-12-11 20:08:47', 'Paid'),
(5, 1, 7, 1, '2024-12-12 06:47:13', 'Paid'),
(19, 1, 6, 4, '2025-01-11 04:26:37', 'Paid'),
(20, 19, 7, 3, '2025-01-12 13:29:29', 'New'),
(21, 19, 5, 1, '2025-01-12 13:29:32', 'Paid'),
(22, 19, 6, 1, '2025-01-12 13:29:36', 'Paid'),
(23, 1, 5, 1, '2025-01-12 15:10:55', 'New');

-- --------------------------------------------------------

--
-- Table structure for table `tbl_events`
--

CREATE TABLE `tbl_events` (
  `event_title` varchar(70) NOT NULL,
  `event_description` varchar(255) NOT NULL,
  `event_startdate` datetime(6) NOT NULL,
  `event_enddate` datetime(6) NOT NULL,
  `event_type` varchar(50) NOT NULL,
  `event_location` varchar(255) NOT NULL,
  `event_filename` varchar(255) NOT NULL,
  `event_id` int(255) NOT NULL,
  `event_date` datetime(6) DEFAULT current_timestamp(6)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `tbl_events`
--

INSERT INTO `tbl_events` (`event_title`, `event_description`, `event_startdate`, `event_enddate`, `event_type`, `event_location`, `event_filename`, `event_id`, `event_date`) VALUES
('aaaaaaaaaaaaaaa', 'aaaaaaaaaaaaaaa', '2024-12-26 14:48:00.000000', '2024-12-27 14:48:00.000000', 'Conference', 'aaaaaaaaaaaaa', 'event-igthpjbtdo.jpg', 4, '2024-12-10 22:49:08.574338'),
('sssssssssssssssss', 'vvvvvvvvvvvvvvv', '2024-12-24 14:55:00.000000', '2024-12-21 14:55:00.000000', 'Conference', 'aaaaaaaaaaaaa', 'event-bvbl61y0m7.jpg', 5, '2024-12-10 22:55:39.800582');

-- --------------------------------------------------------

--
-- Table structure for table `tbl_likes_dislike_user`
--

CREATE TABLE `tbl_likes_dislike_user` (
  `news_id` int(255) NOT NULL,
  `likes` tinyint(1) DEFAULT NULL,
  `dislike` tinyint(1) DEFAULT NULL,
  `user_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_memberships`
--

CREATE TABLE `tbl_memberships` (
  `membership_id` int(11) NOT NULL,
  `name` varchar(100) NOT NULL,
  `description` text DEFAULT NULL,
  `price` decimal(10,2) NOT NULL,
  `duration` int(11) DEFAULT NULL COMMENT 'Duration in days',
  `benefits` text DEFAULT NULL,
  `terms` text DEFAULT NULL,
  `membership_filename` varchar(255) NOT NULL,
  `membership_sold` int(11) NOT NULL,
  `membership_rating` double NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `tbl_memberships`
--

INSERT INTO `tbl_memberships` (`membership_id`, `name`, `description`, `price`, `duration`, `benefits`, `terms`, `membership_filename`, `membership_sold`, `membership_rating`) VALUES
(1, 'Mythical Honor Membership', 'Access to premium features', 99.99, 365, 'Priority Support, Exclusive Access', 'Non-refundable', 'mythical_Honor.jpg', 80, 4.5),
(2, 'Mythical Membership', 'Access to standard features', 49.99, 180, 'Standard Support', 'Non-refundable', 'mythical.jpg', 50, 4),
(3, 'Silver Membership', 'Access to basic features', 19.99, 90, 'Basic Support', 'Refundable within 7 days', 'silver.jpg', 150, 5);

-- --------------------------------------------------------

--
-- Table structure for table `tbl_news`
--

CREATE TABLE `tbl_news` (
  `news_id` int(3) NOT NULL,
  `news_title` varchar(300) NOT NULL,
  `news_details` varchar(800) NOT NULL,
  `news_date` datetime(6) NOT NULL DEFAULT current_timestamp(6),
  `likes` int(100) NOT NULL,
  `dislikes` int(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `tbl_news`
--

INSERT INTO `tbl_news` (`news_id`, `news_title`, `news_details`, `news_date`, `likes`, `dislikes`) VALUES
(13, 'Global Economic Forum 2024 Discusses Post-Pandemic Recovery Plans', 'Leaders from around the globe have gathered to discuss strategies for economic recovery following the pandemic. Emphasis was placed on job creation and sustainable development.', '2024-12-21 18:45:50.000000', 871, 32),
(14, 'Scientists Discover Water Traces on a Distant Exoplanet', 'Astronomers have detected traces of water vapor in the atmosphere of an exoplanet 120 light-years away, increasing hopes of finding habitable planets.', '2024-12-21 18:45:50.000000', 1100, 25),
(15, 'Tech Startup Raises $500 Million for Clean Energy Innovation', 'A Silicon Valley startup has raised $500 million in funding to develop cutting-edge solar panel technologies aimed at reducing energy costs worldwide.', '2024-12-21 18:45:50.000000', 760, 15),
(16, 'World Health Organization Launches Global Mental Health Initiative', 'WHO has announced a global mental health initiative to improve access to mental health resources and reduce stigma around mental health conditions.', '2024-12-21 18:45:50.000000', 950, 28),
(17, 'New Electric Vehicle Sets Record for Longest Range on a Single Charge', 'A new electric car model has set a record by traveling over 1,200 kilometers on a single charge, marking a milestone in EV technology.', '2024-12-21 18:45:50.000000', 890, 19),
(18, 'Government Announces Subsidies for Small Business Owners', 'Small business owners will receive financial support under a new government initiative designed to help businesses recover post-pandemic.', '2024-12-21 18:45:50.000000', 670, 22),
(19, 'Renowned Author Wins International Literary Award', 'Celebrated author Jane Smith has won the International Literary Award for her latest novel, which has captivated audiences worldwide.', '2024-12-21 18:45:50.000000', 980, 14),
(20, 'Cybersecurity Breach Exposes Data of 5 Million Users', 'A major cybersecurity breach has resulted in the exposure of sensitive data from 5 million users. Authorities are investigating the breach.', '2024-12-21 18:45:50.000000', 430, 78),
(21, 'Major Airline Introduces Carbon-Neutral Flights', 'A leading airline has introduced carbon-neutral flights by investing in sustainable aviation fuel and carbon offset projects.', '2024-12-21 18:45:50.000000', 720, 16),
(22, 'Global Protests Erupt Over Rising Fuel Prices', 'Protests have erupted in multiple cities worldwide over rising fuel prices, causing disruptions in daily life and transportation.', '2024-12-21 18:45:50.000000', 560, 34),
(23, 'AI-Powered Robots Now Assisting in Disaster Recovery Efforts', 'AI-powered robots have been deployed in disaster-hit areas to assist with search and rescue operations, improving response times and safety.', '2024-12-21 18:45:50.000000', 870, 21),
(24, 'Breakthrough in Alzheimer\'s Treatment Offers New Hope', 'Researchers have discovered a promising treatment for Alzheimer\'s disease that could slow down cognitive decline significantly.', '2024-12-21 18:45:50.000000', 1230, 9),
(25, 'Wildfire in California Forces Thousands to Evacuate', 'A massive wildfire in California has spread rapidly, forcing thousands of residents to evacuate their homes as firefighters battle the blaze.', '2024-12-21 18:45:50.000000', 460, 52),
(26, 'World Cup Final Attracts Record-Breaking 1 Billion Viewers', 'The World Cup Final set a new record with over 1 billion viewers tuning in to witness the thrilling championship match.', '2024-12-21 18:45:50.000000', 1350, 12),
(27, 'Scientists Successfully Clone Endangered Animal Species', 'In a groundbreaking scientific achievement, researchers have successfully cloned an endangered species, offering hope for conservation efforts.', '2024-12-21 18:45:50.000000', 920, 18),
(28, 'Global Renewable Energy Adoption Hits All-Time High', 'Renewable energy now accounts for 40% of global energy production, marking a significant step towards sustainability.', '2024-12-21 18:45:50.000000', 850, 14),
(29, 'Tech Conference 2024 Unveils Next-Gen Virtual Reality Devices', 'Tech enthusiasts were thrilled as next-gen VR devices were unveiled at the annual Tech Conference, promising immersive digital experiences.', '2024-12-21 18:45:50.000000', 770, 8),
(30, 'Massive Oil Spill Threatens Marine Ecosystem', 'An oil spill off the coast of Florida is causing environmental devastation, with marine life severely affected by the contamination.', '2024-12-21 18:45:50.000000', 320, 65),
(31, 'Education Ministry Launches Free Online Learning Platform', 'The Ministry of Education has launched a free online learning platform to make quality education accessible to students worldwide.', '2024-12-21 18:45:50.000000', 880, 10),
(32, 'New Study Reveals Link Between Sleep and Brain Health', 'Researchers have discovered a strong link between sleep quality and long-term brain health, emphasizing the importance of rest.', '2024-12-21 18:45:50.000000', 950, 6),
(33, 'E-Sports Championship Breaks Global Streaming Records', 'The International E-Sports Championship broke streaming records this year, with millions of viewers tuning in live.', '2024-12-21 18:45:50.000000', 1140, 15),
(34, 'National Park Sees Record Number of Visitors This Year', 'A popular national park saw record-breaking visitor numbers this year, boosting local tourism and revenue.', '2024-12-21 18:45:50.000000', 670, 11),
(35, 'Tech Companies Pledge to Reduce E-Waste by 50%', 'Leading tech companies have pledged to cut e-waste in half by adopting better recycling methods and sustainable designs.', '2024-12-21 18:45:50.000000', 780, 9),
(36, 'Artificial Intelligence Outperforms Humans in Medical Diagnosis', 'An AI-powered system has achieved higher accuracy rates than human doctors in diagnosing medical conditions from imaging scans.', '2024-12-21 18:45:50.000000', 1280, 5),
(37, 'Government Increases Funding for Space Exploration Programs', 'The government has increased funding for national space programs to support ambitious missions to Mars and beyond.', '2024-12-21 18:45:50.000000', 930, 7),
(38, 'Severe Flooding Displaces Thousands in South America', 'Heavy rains have caused severe flooding in South America, displacing thousands and causing extensive damage.', '2024-12-21 18:45:50.000000', 520, 30),
(39, 'World Leaders Sign Historic Peace Treaty', 'A long-standing conflict has come to an end with the signing of a historic peace treaty, bringing hope for lasting stability.', '2024-12-21 18:45:50.000000', 870, 4),
(40, 'Scientists Develop Plant-Based Plastic Alternatives', 'Researchers have developed a plant-based plastic alternative that is fully biodegradable and environmentally friendly.', '2024-12-21 18:45:50.000000', 970, 12),
(41, 'Tech Giant Fined $1 Billion for Antitrust Violations', 'A major tech corporation has been fined $1 billion for violating antitrust laws, raising questions about tech monopolies.', '2024-12-21 18:45:50.000000', 430, 55),
(42, 'Rare Meteor Shower Visible Across the Globe Tonight', 'A rare meteor shower will light up the night sky tonight, offering stargazers a spectacular view.', '2024-12-21 18:45:50.000000', 890, 3),
(43, 'Global Hunger Levels Drop Thanks to Sustainable Agriculture Practices', 'Sustainable farming practices have significantly reduced global hunger levels over the past decade.', '2024-12-21 18:45:50.000000', 720, 6),
(44, 'National Museum Reopens with State-of-the-Art Exhibits', 'The National Museum has reopened with advanced technology exhibits, drawing visitors from all over the country.', '2024-12-21 18:45:50.000000', 810, 4);

-- --------------------------------------------------------

--
-- Table structure for table `tbl_products`
--

CREATE TABLE `tbl_products` (
  `product_title` varchar(50) NOT NULL,
  `product_description` varchar(255) NOT NULL,
  `product_type` varchar(50) NOT NULL,
  `product_filename` varchar(60) NOT NULL,
  `product_price` double NOT NULL,
  `product_id` int(255) NOT NULL,
  `product_date` datetime NOT NULL DEFAULT current_timestamp(),
  `product_stock` int(255) NOT NULL,
  `product_sold` int(11) NOT NULL,
  `product_rating` double NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `tbl_products`
--

INSERT INTO `tbl_products` (`product_title`, `product_description`, `product_type`, `product_filename`, `product_price`, `product_id`, `product_date`, `product_stock`, `product_sold`, `product_rating`) VALUES
('Anjing British Short Hair', 'Baka England', 'Electronics', 'product-otm75nyjzc.jpg', 123, 1, '2024-12-11 19:16:37', 5, 10, 3.5),
('Kerusi Empuk', 'Limited Edition', 'Furniture', 'product-7wyrzdgodb.jpg', 250, 2, '2024-12-11 20:41:13', 3, 20, 4.5),
('TV 30\" LG 2024', 'TVPaling Limted Fans 2024', 'Electronics', 'product-wsc6lq73pd.jpg', 500, 3, '2024-12-11 20:52:23', 10, 30, 5),
('Kucing Amerka', 'Baka Satu je di dunia', 'Others', 'product-fy0wu2tf4t.jpg', 2000, 4, '2024-12-12 12:07:37', 0, 25, 4),
('Rak Premium', 'Tempat Letak Buku Premium', 'Furniture', 'product-si13gxf2f8.jpg', 200, 5, '2024-12-12 14:15:45', 3, 50, 4.5),
('Wall Decoration Pad', 'Only Available in Gray', 'Others', 'product-n6elbiwqet.jpg', 50, 6, '2024-12-12 14:19:02', 11, 100, 3),
('Peti 2 Pintu LG', 'Second Hand', 'Electronics', 'product-11z0xju7hb.jpg', 500, 7, '2024-12-12 14:45:55', 1, 10, 5);

-- --------------------------------------------------------

--
-- Table structure for table `tbl_purchases`
--

CREATE TABLE `tbl_purchases` (
  `purchase_id` int(11) NOT NULL,
  `user_id` int(11) DEFAULT NULL,
  `membership_id` int(11) DEFAULT NULL,
  `purchase_date` timestamp NOT NULL DEFAULT current_timestamp(),
  `payment_amount` decimal(10,2) DEFAULT NULL,
  `payment_status` enum('Pending','Paid') DEFAULT 'Pending'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `tbl_purchases`
--

INSERT INTO `tbl_purchases` (`purchase_id`, `user_id`, `membership_id`, `purchase_date`, `payment_amount`, `payment_status`) VALUES
(1, 1, 1, '2025-01-09 02:58:12', 99.99, 'Paid'),
(2, 1, 2, '2025-01-09 02:58:12', 49.99, 'Pending'),
(3, 2, 3, '2025-01-09 02:58:12', 19.99, 'Paid'),
(4, 1, 2, '2025-01-10 09:19:43', 49.99, 'Paid'),
(16, 1, 2, '2025-01-10 13:17:00', 49.99, 'Paid'),
(22, 1, 2, '2025-01-10 14:16:25', 49.99, 'Paid'),
(23, 1, NULL, '2025-01-10 16:56:48', 2000.00, 'Paid'),
(24, 1, NULL, '2025-01-10 16:58:45', 2000.00, 'Paid'),
(25, 1, NULL, '2025-01-10 16:59:42', 2000.00, 'Paid'),
(26, 1, NULL, '2025-01-10 17:00:32', 2000.00, 'Paid'),
(27, 1, NULL, '2025-01-10 17:06:04', 2000.00, 'Paid'),
(28, 1, NULL, '2025-01-10 17:08:28', 2000.00, 'Paid'),
(29, 1, NULL, '2025-01-10 17:17:48', 2000.00, 'Paid'),
(30, 1, NULL, '2025-01-11 04:26:52', 50.00, 'Paid'),
(31, 1, 1, '2025-01-12 04:54:23', 99.99, 'Paid'),
(32, 19, 1, '2025-01-12 13:13:06', 99.99, 'Paid'),
(33, 19, 1, '2025-01-12 13:14:07', 99.99, 'Paid'),
(34, 19, 1, '2025-01-12 13:18:35', 99.99, 'Paid'),
(35, 19, 1, '2025-01-12 13:22:29', 99.99, 'Paid'),
(36, 19, 1, '2025-01-12 13:25:30', 99.99, 'Paid'),
(37, 19, 1, '2025-01-12 13:27:54', 99.99, 'Paid'),
(38, 19, NULL, '2025-01-12 13:29:52', 750.00, 'Paid'),
(39, 19, 1, '2025-01-12 13:37:59', 99.99, 'Paid'),
(40, 19, 1, '2025-01-12 13:42:04', 99.99, 'Paid'),
(41, 19, 1, '2025-01-12 13:45:58', 99.99, 'Paid'),
(42, 19, 1, '2025-01-12 13:48:47', 99.99, 'Paid'),
(43, 1, 1, '2025-01-12 13:58:17', 99.99, 'Paid'),
(44, 1, 1, '2025-01-12 15:09:28', 99.99, 'Paid'),
(45, 19, 1, '2025-01-12 16:28:54', 99.99, 'Paid'),
(46, 19, NULL, '2025-01-12 16:30:42', 1050.00, 'Paid'),
(47, 19, 2, '2025-01-13 02:56:27', 49.99, 'Paid');

-- --------------------------------------------------------

--
-- Table structure for table `tbl_selected_items`
--

CREATE TABLE `tbl_selected_items` (
  `id` int(11) NOT NULL,
  `purchase_id` int(11) DEFAULT NULL,
  `product_id` int(11) DEFAULT NULL,
  `quantity` int(11) DEFAULT NULL,
  `price` decimal(10,2) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Dumping data for table `tbl_selected_items`
--

INSERT INTO `tbl_selected_items` (`id`, `purchase_id`, `product_id`, `quantity`, `price`) VALUES
(29, 28, 7, 2, 500.00),
(30, 28, 2, 2, 250.00),
(31, 29, 3, 1, 500.00),
(32, 29, 7, 2, 500.00),
(33, 29, 2, 2, 250.00),
(34, 30, 6, 1, 50.00),
(35, 38, 7, 1, 500.00),
(36, 38, 5, 1, 200.00),
(37, 38, 6, 1, 50.00),
(38, 46, 7, 2, 500.00),
(39, 46, 6, 1, 50.00);

-- --------------------------------------------------------

--
-- Table structure for table `tbl_user`
--

CREATE TABLE `tbl_user` (
  `user_id` int(5) NOT NULL,
  `user_email` varchar(50) NOT NULL,
  `user_phone` int(12) NOT NULL,
  `user_date_register` date NOT NULL DEFAULT current_timestamp(),
  `user_username` varchar(20) NOT NULL,
  `user_pass` varchar(50) NOT NULL,
  `user_address` varchar(255) NOT NULL,
  `user_role` enum('Admin','User') NOT NULL DEFAULT 'User',
  `user_profile_image` varchar(255) DEFAULT NULL,
  `user_ranking` varchar(255) NOT NULL DEFAULT 'Member'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `tbl_user`
--

INSERT INTO `tbl_user` (`user_id`, `user_email`, `user_phone`, `user_date_register`, `user_username`, `user_pass`, `user_address`, `user_role`, `user_profile_image`, `user_ranking`) VALUES
(1, 'HafeezIlias.1@gmail.com', 104540525, '2024-10-30', 'Hafeez Ilias', 'b3aeb5fb26e03c0d91620ef72f7c53f23752abec', 'TMN SRI BAUNG', 'Admin', 'profile_1_1736691221.jpg', 'Administrator'),
(15, 'a@gmail.com', 102323232, '2024-11-16', ' Tok Ayoh', 'f33d8037cb548f7afd397be6ac2cb014203dd4d0', '', 'User', 'a.jpg', 'President'),
(16, 'NasiLemak@gmail.com', 145622341, '2025-01-08', 'Nasi Lemak', 'ebae8baffe5302182ed6c8f67144faf63c09203e', '', 'Admin', NULL, ''),
(19, 'pendakwahimam@gmail.com', 104540525, '2025-01-12', 'KingHoney', 'ff587eaff56e8e387dd0d94834158cf51771927d', '', 'User', 'profile-19-yhcu9hwniz.jpg', 'Member');

-- --------------------------------------------------------

--
-- Table structure for table `tbl_user_membership_status`
--

CREATE TABLE `tbl_user_membership_status` (
  `user_membership_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL COMMENT 'References the user owning the membership',
  `membership_id` int(11) NOT NULL COMMENT 'References the membership type',
  `start_date` date NOT NULL COMMENT 'The date when the membership starts',
  `end_date` date NOT NULL COMMENT 'The date when the membership ends',
  `status` enum('Active','Expired') NOT NULL DEFAULT 'Active' COMMENT 'Status of the membership',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp() COMMENT 'Record creation timestamp',
  `updated_at` timestamp NULL DEFAULT NULL ON UPDATE current_timestamp() COMMENT 'Last update timestamp'
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Dumping data for table `tbl_user_membership_status`
--

INSERT INTO `tbl_user_membership_status` (`user_membership_id`, `user_id`, `membership_id`, `start_date`, `end_date`, `status`, `created_at`, `updated_at`) VALUES
(1, 19, 1, '2025-01-12', '2026-01-12', 'Active', '2025-01-12 13:48:47', NULL),
(2, 1, 1, '2025-01-12', '2026-01-12', 'Active', '2025-01-12 13:58:17', NULL),
(3, 1, 1, '2025-01-12', '2026-01-12', 'Active', '2025-01-12 15:09:28', NULL),
(4, 19, 1, '2025-01-12', '2026-01-12', 'Active', '2025-01-12 16:28:54', NULL),
(5, 19, 2, '2025-01-13', '2025-07-12', 'Active', '2025-01-13 02:56:27', NULL);

--
-- Indexes for dumped tables
--

--
-- Indexes for table `tbl_cart`
--
ALTER TABLE `tbl_cart`
  ADD PRIMARY KEY (`cart_id`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `product_id` (`product_id`);

--
-- Indexes for table `tbl_events`
--
ALTER TABLE `tbl_events`
  ADD PRIMARY KEY (`event_id`);

--
-- Indexes for table `tbl_likes_dislike_user`
--
ALTER TABLE `tbl_likes_dislike_user`
  ADD UNIQUE KEY `news_id` (`news_id`),
  ADD UNIQUE KEY `user_id` (`user_id`);

--
-- Indexes for table `tbl_memberships`
--
ALTER TABLE `tbl_memberships`
  ADD PRIMARY KEY (`membership_id`);

--
-- Indexes for table `tbl_news`
--
ALTER TABLE `tbl_news`
  ADD PRIMARY KEY (`news_id`);

--
-- Indexes for table `tbl_products`
--
ALTER TABLE `tbl_products`
  ADD PRIMARY KEY (`product_id`);

--
-- Indexes for table `tbl_purchases`
--
ALTER TABLE `tbl_purchases`
  ADD PRIMARY KEY (`purchase_id`),
  ADD KEY `membership_id` (`membership_id`);

--
-- Indexes for table `tbl_selected_items`
--
ALTER TABLE `tbl_selected_items`
  ADD PRIMARY KEY (`id`),
  ADD KEY `purchase_id` (`purchase_id`);

--
-- Indexes for table `tbl_user`
--
ALTER TABLE `tbl_user`
  ADD PRIMARY KEY (`user_id`),
  ADD UNIQUE KEY `user_email` (`user_email`);

--
-- Indexes for table `tbl_user_membership_status`
--
ALTER TABLE `tbl_user_membership_status`
  ADD PRIMARY KEY (`user_membership_id`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `membership_id` (`membership_id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `tbl_cart`
--
ALTER TABLE `tbl_cart`
  MODIFY `cart_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=24;

--
-- AUTO_INCREMENT for table `tbl_events`
--
ALTER TABLE `tbl_events`
  MODIFY `event_id` int(255) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=23;

--
-- AUTO_INCREMENT for table `tbl_memberships`
--
ALTER TABLE `tbl_memberships`
  MODIFY `membership_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `tbl_news`
--
ALTER TABLE `tbl_news`
  MODIFY `news_id` int(3) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=60;

--
-- AUTO_INCREMENT for table `tbl_products`
--
ALTER TABLE `tbl_products`
  MODIFY `product_id` int(255) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=26;

--
-- AUTO_INCREMENT for table `tbl_purchases`
--
ALTER TABLE `tbl_purchases`
  MODIFY `purchase_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=48;

--
-- AUTO_INCREMENT for table `tbl_selected_items`
--
ALTER TABLE `tbl_selected_items`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=40;

--
-- AUTO_INCREMENT for table `tbl_user`
--
ALTER TABLE `tbl_user`
  MODIFY `user_id` int(5) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=20;

--
-- AUTO_INCREMENT for table `tbl_user_membership_status`
--
ALTER TABLE `tbl_user_membership_status`
  MODIFY `user_membership_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `tbl_cart`
--
ALTER TABLE `tbl_cart`
  ADD CONSTRAINT `tbl_cart_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `tbl_user` (`user_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `tbl_cart_ibfk_2` FOREIGN KEY (`product_id`) REFERENCES `tbl_products` (`product_id`) ON DELETE CASCADE;

--
-- Constraints for table `tbl_purchases`
--
ALTER TABLE `tbl_purchases`
  ADD CONSTRAINT `tbl_purchases_ibfk_1` FOREIGN KEY (`membership_id`) REFERENCES `tbl_memberships` (`membership_id`);

--
-- Constraints for table `tbl_selected_items`
--
ALTER TABLE `tbl_selected_items`
  ADD CONSTRAINT `tbl_selected_items_ibfk_1` FOREIGN KEY (`purchase_id`) REFERENCES `tbl_purchases` (`purchase_id`) ON DELETE CASCADE;

--
-- Constraints for table `tbl_user_membership_status`
--
ALTER TABLE `tbl_user_membership_status`
  ADD CONSTRAINT `tbl_user_membership_status_ibfk_1` FOREIGN KEY (`membership_id`) REFERENCES `tbl_memberships` (`membership_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `tbl_user_membership_status_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `tbl_user` (`user_id`) ON DELETE CASCADE ON UPDATE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
