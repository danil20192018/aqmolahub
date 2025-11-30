-- phpMyAdmin SQL Dump
-- version 5.2.3
-- https://www.phpmyadmin.net/
--
-- Хост: localhost:3306
-- Время создания: Ноя 30 2025 г., 07:37
-- Версия сервера: 10.6.22-MariaDB
-- Версия PHP: 8.4.14

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- База данных: `broldru_baze`
--

-- --------------------------------------------------------

--
-- Структура таблицы `comments`
--

CREATE TABLE `comments` (
  `id` int(11) NOT NULL,
  `news_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `user_name` varchar(255) NOT NULL,
  `txt` text NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;

--
-- Дамп данных таблицы `comments`
--

INSERT INTO `comments` (`id`, `news_id`, `user_id`, `user_name`, `txt`, `created_at`) VALUES
(5, 3, 2, 'Ansar', 'xxxc', '2025-11-28 23:11:08'),
(7, 5, 1, 'Данил Шилов', 'Круто дальше меньше!', '2025-11-30 01:24:53');

-- --------------------------------------------------------

--
-- Структура таблицы `events`
--

CREATE TABLE `events` (
  `id` int(11) NOT NULL,
  `title` varchar(255) NOT NULL,
  `descr` text DEFAULT NULL,
  `date` varchar(50) DEFAULT NULL,
  `time` varchar(50) DEFAULT NULL,
  `location` varchar(255) DEFAULT NULL,
  `image` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;

--
-- Дамп данных таблицы `events`
--

INSERT INTO `events` (`id`, `title`, `descr`, `date`, `time`, `location`, `image`, `created_at`) VALUES
(6, 'IDEA BATTLE', 'We invite you to IDEA BATTLE — an event where the most ambitious projects of the Akmola region will clash in a battle of ideas.\n\n???? What to Expect?\n\n– 5-Minute Pitches: Participants will present their innovative ideas in a dynamic, fast-paced format.\n– Hot Questions: The expert jury and audience will challenge the project authors with a blitz Q&A session.\n– Networking: A unique opportunity to connect with developers, investors, and key players of the startup ecosystem.\n– Inspiration: Discover how ideas can grow into real businesses after their very first pitch.\n\n???? Date: November 27\n⏰ Time: 17:00\n???? Location: Aqmola Hub, Kokshetau\n\nFree admission. Registration — via the link in our profile.', '06.06.06', '13 00', 'Aqmola Hub', 'https://aqmolarp.kz/backendapplication/image.php?path=uploads/events/event_1764465010.jpg', '2025-11-30 01:10:37');

-- --------------------------------------------------------

--
-- Структура таблицы `event_registrations`
--

CREATE TABLE `event_registrations` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `event_id` int(11) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;

--
-- Дамп данных таблицы `event_registrations`
--

INSERT INTO `event_registrations` (`id`, `user_id`, `event_id`, `created_at`) VALUES
(1, 1, 5, '2025-11-29 10:20:50'),
(7, 1, 6, '2025-11-30 01:31:36');

-- --------------------------------------------------------

--
-- Структура таблицы `ittok_likes`
--

CREATE TABLE `ittok_likes` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `video_id` int(11) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;

--
-- Дамп данных таблицы `ittok_likes`
--

INSERT INTO `ittok_likes` (`id`, `user_id`, `video_id`, `created_at`) VALUES
(4, 1, 1, '2025-11-30 02:00:17');

-- --------------------------------------------------------

--
-- Структура таблицы `ittok_videos`
--

CREATE TABLE `ittok_videos` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `title` varchar(255) DEFAULT NULL,
  `description` text DEFAULT NULL,
  `video_url` varchar(500) NOT NULL,
  `thumbnail` varchar(500) DEFAULT NULL,
  `views` int(11) DEFAULT 0,
  `status` varchar(20) DEFAULT 'active',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;

--
-- Дамп данных таблицы `ittok_videos`
--

INSERT INTO `ittok_videos` (`id`, `user_id`, `title`, `description`, `video_url`, `thumbnail`, `views`, `status`, `created_at`) VALUES
(1, 1, 'Новое видео', '', 'https://aqmolarp.kz/backendapplication/uploads/videos/692b807d75650.mp4', '', 7, 'active', '2025-11-29 23:23:41');

-- --------------------------------------------------------

--
-- Структура таблицы `likes`
--

CREATE TABLE `likes` (
  `id` int(11) NOT NULL,
  `news_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;

--
-- Дамп данных таблицы `likes`
--

INSERT INTO `likes` (`id`, `news_id`, `user_id`) VALUES
(5, 1, 1),
(6, 5, 1);

-- --------------------------------------------------------

--
-- Структура таблицы `market_listings`
--

CREATE TABLE `market_listings` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `type` varchar(10) NOT NULL,
  `title` varchar(255) NOT NULL,
  `description` text DEFAULT NULL,
  `price` int(11) NOT NULL DEFAULT 0,
  `status` varchar(20) DEFAULT 'active',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;

--
-- Дамп данных таблицы `market_listings`
--

INSERT INTO `market_listings` (`id`, `user_id`, `type`, `title`, `description`, `price`, `status`, `created_at`) VALUES
(1, 1, 'offer', '3', '3', 222, 'active', '2025-11-29 15:47:45'),
(2, 1, 'request', '2', '2', 2, 'active', '2025-11-29 15:48:08');

-- --------------------------------------------------------

--
-- Структура таблицы `market_transactions`
--

CREATE TABLE `market_transactions` (
  `id` int(11) NOT NULL,
  `buyer_id` int(11) NOT NULL,
  `seller_id` int(11) NOT NULL,
  `listing_id` int(11) NOT NULL,
  `amount` int(11) NOT NULL,
  `commission` int(11) NOT NULL DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;

-- --------------------------------------------------------

--
-- Структура таблицы `networking_cards`
--

CREATE TABLE `networking_cards` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `user_name` varchar(255) NOT NULL,
  `user_avatar` varchar(500) DEFAULT NULL,
  `role_needed` varchar(255) NOT NULL,
  `description` text NOT NULL,
  `contact_info` varchar(255) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;

--
-- Дамп данных таблицы `networking_cards`
--

INSERT INTO `networking_cards` (`id`, `user_id`, `user_name`, `user_avatar`, `role_needed`, `description`, `contact_info`, `created_at`) VALUES
(6, 1, 'Данил Шилов', 'https://aqmolarp.kz/backendapplication/image.php?path=uploads/avatars/1_1764465868.jpg', 'Разработчика', 'Создать игру', '+77779524694', '2025-11-30 01:36:23');

-- --------------------------------------------------------

--
-- Структура таблицы `news`
--

CREATE TABLE `news` (
  `id` int(11) NOT NULL,
  `title` varchar(255) NOT NULL,
  `descr` text NOT NULL,
  `image` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;

--
-- Дамп данных таблицы `news`
--

INSERT INTO `news` (`id`, `title`, `descr`, `image`, `created_at`) VALUES
(5, 'GameDev нового поколения: 15-летний разработчик из Кокшетау покоряет индустрию', '15-летний Данил Мирошниченко из Кокшетау уже не просто увлечённый подросток — он настоящий талант в мире геймдева. Сейчас он создаёт свою третью игру в жанре Roleplay, но на этом его достижения не заканчиваются.\n\nДанил стал известен благодаря своему проекту Alash RP, который буквально взорвал интернет. В первый же день после запуска он собрал 4500 регистраций и привлёк сотни игроков со всего Казахстана. Сейчас он активно развивает свои навыки в региональном IT-хабе Aqmola Hub, где совершенствует свои знания и учится у лучших.\n\nС самого детства Данил был увлечён программированием. Уже в 7-8 лет он экспериментировал с установкой Telegram-ботов на Python, а позже изучал Lua и адаптировал чужие скрипты под свои нужды. В 9 лет он освоил Node.js и начал разрабатывать и продавать ботов.\n\n\"Меня всегда привлекало, как работает код изнутри. Я любил копаться в программах, разбирать их и создавать что-то своё\", — рассказывает Данил.\n\nВ 11 лет Данил заинтересовался игровой индустрией и стал играть на сервере BLACK RUSSIA — одном из первых CRMP-проектов. Постепенно он начал занимать различные должности на сервере, а в 12 лет создал свой первый проект — WOLF BONUS. Правда, его аудитория не превышала 50 игроков, и проект был не таким успешным, как хотелось бы.\n\n\"Я понял, что для успеха недостаточно просто запустить сервер. Нужно предложить что-то уникальное и востребованное\", — делится Данил.\n\nПереосмыслив подход, Данил запустил Alash RP — сервер с казахстанской тематикой. Открытие оказалось настоящим фурором:\n\nБолее 500 игроков одновременно в онлайне.\n1000-1500 игроков в очереди на подключение.\n4500 регистраций в первый день.\n6500 подписчиков в Telegram за сутки до старта.\nПопулярность проекта стремительно росла, благодаря сотрудничеству с казахстанскими блогерами. Но, несмотря на успех, проект столкнулся с проблемами из-за частых перезапусков и был закрыт.\n\nПосле закрытия Alash RP Данил не сдался. Он углубился в веб-разработку, освоил HTML, CSS, PHP и создал несколько успешных сайтов для отслеживания карго из Китая. В 14 лет он привлёк 30 клиентов и заработал 1,5 миллиона тенге всего за месяц.\n\nОдновременно Данил обучался в школе программирования, где получил структурированные знания и развил свои навыки.\n\nВдохновлённый предыдущими проектами, Данил начал работать над новым амбициозным проектом — BROLD, который стал переосмыслением классического BLACK RUSSIA. Несмотря на технические трудности, проект собрал 2700 регистраций в день и привлёк 50-100 игроков в онлайн, но также был закрыт.\n\nСегодня Данил активно развивает новый проект и участвует в IT-соревнованиях, где уже успел занять призовые места:\n\nФиналист Decentrathon 2.0 (BLOCKCHAIN + Telegram Mini Apps)\n3 место на Startup Battle «Digital Aqmola»\n3 место на Inform Defence Hackathon\n2 место на AI Traveltech Hackathon\nНа данный момент Данил владеет рядом технологий, включая PHP, HTML, CSS, JavaScript, Node.js, Dart, Flutter и базовые знания PAWN. Он также осваивает Java и C++ для разработки своего нового проекта.\n\n\"Моя цель — создать продукт, который будет независим от чужих решений. Это не просто очередной CRMP-проект, а нечто уникальное\", — говорит Данил.\n\nКто знает, возможно, именно он станет тем человеком, который изменит индустрию онлайн-игр, не только в Казахстане, но и за его пределами. Одно точно ясно: за этим школьником стоит следить!', 'https://aqmolarp.kz/backendapplication/image.php?path=uploads/news/news_1764464644.jpg', '2025-11-30 01:04:05');

-- --------------------------------------------------------

--
-- Структура таблицы `notifications`
--

CREATE TABLE `notifications` (
  `id` int(11) NOT NULL,
  `title` varchar(255) NOT NULL,
  `message` text NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;

-- --------------------------------------------------------

--
-- Структура таблицы `qr_cards`
--

CREATE TABLE `qr_cards` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `qr_code` varchar(100) NOT NULL,
  `name` varchar(255) NOT NULL,
  `role` varchar(255) DEFAULT NULL,
  `bio` text DEFAULT NULL,
  `skills` text DEFAULT NULL,
  `contact` varchar(255) DEFAULT NULL,
  `avatar` varchar(500) DEFAULT NULL,
  `theme` varchar(50) DEFAULT 'blue',
  `scans` int(11) DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;

--
-- Дамп данных таблицы `qr_cards`
--

INSERT INTO `qr_cards` (`id`, `user_id`, `qr_code`, `name`, `role`, `bio`, `skills`, `contact`, `avatar`, `theme`, `scans`, `created_at`, `updated_at`) VALUES
(1, 1, 'QR_692b8690e40ca', 'danil', 'danil', 'danil', 'danil', 'danil', 'https://aqmolarp.kz/backendapplication/image.php?path=uploads/avatars/1_1764428075.jpg', 'blue', 57, '2025-11-29 23:49:36', '2025-11-30 02:26:45');

-- --------------------------------------------------------

--
-- Структура таблицы `qr_codes`
--

CREATE TABLE `qr_codes` (
  `id` int(11) NOT NULL,
  `code` varchar(255) NOT NULL,
  `coins` int(11) NOT NULL DEFAULT 10,
  `label` varchar(255) DEFAULT NULL,
  `active` tinyint(4) DEFAULT 1,
  `created_by` int(11) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;

--
-- Дамп данных таблицы `qr_codes`
--

INSERT INTO `qr_codes` (`id`, `code`, `coins`, `label`, `active`, `created_by`, `created_at`) VALUES
(1, '9826cf1f93db3230f5ef67ba9a6bcb29', 10, NULL, 1, 1, '2025-11-29 14:02:10');

-- --------------------------------------------------------

--
-- Структура таблицы `qr_scans`
--

CREATE TABLE `qr_scans` (
  `id` int(11) NOT NULL,
  `qr_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `scanned_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;

-- --------------------------------------------------------

--
-- Структура таблицы `startups`
--

CREATE TABLE `startups` (
  `id` int(11) NOT NULL,
  `name` varchar(255) NOT NULL,
  `description` text NOT NULL,
  `image` varchar(500) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `founder` varchar(255) DEFAULT NULL,
  `website` varchar(500) DEFAULT NULL,
  `stage` varchar(100) DEFAULT NULL,
  `funding` varchar(100) DEFAULT NULL,
  `team_size` varchar(50) DEFAULT NULL,
  `contact_email` varchar(255) DEFAULT NULL,
  `full_description` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;

--
-- Дамп данных таблицы `startups`
--

INSERT INTO `startups` (`id`, `name`, `description`, `image`, `created_at`, `founder`, `website`, `stage`, `funding`, `team_size`, `contact_email`, `full_description`) VALUES
(3, 'AQMOLA RP', 'RolePlay проект про Казахстан ', 'https://aqmolarp.kz/backendapplication/image.php?path=uploads/startups/startup_1764465366.jpg', '2025-11-30 01:16:11', 'Данил мирошниченко', 'aqmolarp.kz', 'MVP', '-', '1', '-', 'RolePlay проект про Казахстан где ты можешь окунуться в большой мир Акмолинскую область');

-- --------------------------------------------------------

--
-- Структура таблицы `users`
--

CREATE TABLE `users` (
  `id` int(11) NOT NULL,
  `name` varchar(255) NOT NULL,
  `email` varchar(255) NOT NULL,
  `pass` varchar(255) NOT NULL,
  `avatar` text DEFAULT NULL,
  `role` varchar(50) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `coins` int(11) DEFAULT 0,
  `telegram_id` bigint(20) DEFAULT NULL,
  `telegram_username` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;

--
-- Дамп данных таблицы `users`
--

INSERT INTO `users` (`id`, `name`, `email`, `pass`, `avatar`, `role`, `created_at`, `coins`, `telegram_id`, `telegram_username`) VALUES
(1, 'Данил Шилов', 'a@a.a', '$2y$10$DQxStTjJDrEHvVYBR88nRu1Svj2sxX5Gvje72MuOdYF./L6BI4z1W', 'https://aqmolarp.kz/backendapplication/image.php?path=uploads/avatars/1_1764465868.jpg', 'Админ', '2025-11-28 19:26:04', 100, 7590971918, ''),
(2, 'Ansar', 'negmetansar4@gmail.com', '$2y$10$4mPQ3G8PSNCWCEE8bEk82uKtRm0KC85c73SyeJZcA42StZtbErtya', 'https://aqmolarp.kz/backendapplication/uploads/avatars/2_1764371479.jpg', 'Команда', '2025-11-28 23:10:52', 0, NULL, NULL),
(3, 'Валерия ', 'valeriakipke10@gmail.com ', '$2y$10$8t/z7HefYYaZsVuXs6VXBODNbewx9Y/XuopmVo7Jrv7OixTH5Qtie', NULL, 'Стартап', '2025-11-29 17:39:29', 0, NULL, NULL),
(4, 'Tuleubek ', 'tassov19@gmail.com', '$2y$10$SQk.aAJAieJrB/ILpevTY.YTJGB362JscZOlQ1ema7ygRPHSOPphC', NULL, 'Стартап', '2025-11-29 17:44:08', 0, NULL, NULL);

-- --------------------------------------------------------

--
-- Структура таблицы `vacancies`
--

CREATE TABLE `vacancies` (
  `id` int(11) NOT NULL,
  `title` varchar(255) NOT NULL,
  `company` varchar(255) DEFAULT NULL,
  `salary` varchar(100) DEFAULT NULL,
  `descr` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;

--
-- Дамп данных таблицы `vacancies`
--

INSERT INTO `vacancies` (`id`, `title`, `company`, `salary`, `descr`, `created_at`) VALUES
(3, 'Стажер Программист', 'AQMOLAHUB', '-', 'Помогать в развитие стартапов', '2025-11-30 01:13:20');

-- --------------------------------------------------------

--
-- Структура таблицы `vacancy_responses`
--

CREATE TABLE `vacancy_responses` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `vacancy_id` int(11) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;

--
-- Дамп данных таблицы `vacancy_responses`
--

INSERT INTO `vacancy_responses` (`id`, `user_id`, `vacancy_id`, `created_at`) VALUES
(2, 1, 2, '2025-11-29 10:47:59'),
(4, 1, 3, '2025-11-30 01:34:54');

--
-- Индексы сохранённых таблиц
--

--
-- Индексы таблицы `comments`
--
ALTER TABLE `comments`
  ADD PRIMARY KEY (`id`);

--
-- Индексы таблицы `events`
--
ALTER TABLE `events`
  ADD PRIMARY KEY (`id`);

--
-- Индексы таблицы `event_registrations`
--
ALTER TABLE `event_registrations`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `unique_registration` (`user_id`,`event_id`);

--
-- Индексы таблицы `ittok_likes`
--
ALTER TABLE `ittok_likes`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `unique_like` (`user_id`,`video_id`),
  ADD KEY `video_id` (`video_id`);

--
-- Индексы таблицы `ittok_videos`
--
ALTER TABLE `ittok_videos`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_videos_created` (`created_at`),
  ADD KEY `idx_videos_user` (`user_id`);

--
-- Индексы таблицы `likes`
--
ALTER TABLE `likes`
  ADD PRIMARY KEY (`id`);

--
-- Индексы таблицы `market_listings`
--
ALTER TABLE `market_listings`
  ADD PRIMARY KEY (`id`);

--
-- Индексы таблицы `market_transactions`
--
ALTER TABLE `market_transactions`
  ADD PRIMARY KEY (`id`);

--
-- Индексы таблицы `networking_cards`
--
ALTER TABLE `networking_cards`
  ADD PRIMARY KEY (`id`);

--
-- Индексы таблицы `news`
--
ALTER TABLE `news`
  ADD PRIMARY KEY (`id`);

--
-- Индексы таблицы `notifications`
--
ALTER TABLE `notifications`
  ADD PRIMARY KEY (`id`);

--
-- Индексы таблицы `qr_cards`
--
ALTER TABLE `qr_cards`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `qr_code` (`qr_code`),
  ADD UNIQUE KEY `unique_user` (`user_id`),
  ADD KEY `idx_qr_code` (`qr_code`);

--
-- Индексы таблицы `qr_codes`
--
ALTER TABLE `qr_codes`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `code` (`code`);

--
-- Индексы таблицы `qr_scans`
--
ALTER TABLE `qr_scans`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `unique_scan` (`qr_id`,`user_id`);

--
-- Индексы таблицы `startups`
--
ALTER TABLE `startups`
  ADD PRIMARY KEY (`id`);

--
-- Индексы таблицы `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `email` (`email`),
  ADD KEY `idx_telegram_id` (`telegram_id`);

--
-- Индексы таблицы `vacancies`
--
ALTER TABLE `vacancies`
  ADD PRIMARY KEY (`id`);

--
-- Индексы таблицы `vacancy_responses`
--
ALTER TABLE `vacancy_responses`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `unique_response` (`user_id`,`vacancy_id`);

--
-- AUTO_INCREMENT для сохранённых таблиц
--

--
-- AUTO_INCREMENT для таблицы `comments`
--
ALTER TABLE `comments`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT для таблицы `events`
--
ALTER TABLE `events`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT для таблицы `event_registrations`
--
ALTER TABLE `event_registrations`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT для таблицы `ittok_likes`
--
ALTER TABLE `ittok_likes`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT для таблицы `ittok_videos`
--
ALTER TABLE `ittok_videos`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT для таблицы `likes`
--
ALTER TABLE `likes`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT для таблицы `market_listings`
--
ALTER TABLE `market_listings`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT для таблицы `market_transactions`
--
ALTER TABLE `market_transactions`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT для таблицы `networking_cards`
--
ALTER TABLE `networking_cards`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT для таблицы `news`
--
ALTER TABLE `news`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT для таблицы `notifications`
--
ALTER TABLE `notifications`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT для таблицы `qr_cards`
--
ALTER TABLE `qr_cards`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT для таблицы `qr_codes`
--
ALTER TABLE `qr_codes`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT для таблицы `qr_scans`
--
ALTER TABLE `qr_scans`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT для таблицы `startups`
--
ALTER TABLE `startups`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT для таблицы `users`
--
ALTER TABLE `users`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT для таблицы `vacancies`
--
ALTER TABLE `vacancies`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT для таблицы `vacancy_responses`
--
ALTER TABLE `vacancy_responses`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- Ограничения внешнего ключа сохраненных таблиц
--

--
-- Ограничения внешнего ключа таблицы `ittok_likes`
--
ALTER TABLE `ittok_likes`
  ADD CONSTRAINT `ittok_likes_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  ADD CONSTRAINT `ittok_likes_ibfk_2` FOREIGN KEY (`video_id`) REFERENCES `ittok_videos` (`id`);

--
-- Ограничения внешнего ключа таблицы `ittok_videos`
--
ALTER TABLE `ittok_videos`
  ADD CONSTRAINT `ittok_videos_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`);

--
-- Ограничения внешнего ключа таблицы `qr_cards`
--
ALTER TABLE `qr_cards`
  ADD CONSTRAINT `qr_cards_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
