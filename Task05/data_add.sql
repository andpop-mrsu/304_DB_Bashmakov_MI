PRAGMA foreign_keys=ON;

-- =====================================================
-- 1. Добавление пяти новых пользователей
--    (я + четыре соседа по списку группы)
--    Дата регистрации определяется по системному времени
-- =====================================================
INSERT INTO users (name, email, gender_id, register_date, occupation_id)
VALUES ('Башмаков Максим', 'bashmakov.mi@student.ru',
        (SELECT id FROM genders WHERE name = 'male'),
        DATE('now'),
        (SELECT id FROM occupations WHERE name = 'student'));

INSERT INTO users (name, email, gender_id, register_date, occupation_id)
VALUES ('Иванов Иван', 'ivanov.ii@student.ru',
        (SELECT id FROM genders WHERE name = 'male'),
        DATE('now'),
        (SELECT id FROM occupations WHERE name = 'student'));

INSERT INTO users (name, email, gender_id, register_date, occupation_id)
VALUES ('Петрова Анна', 'petrova.aa@student.ru',
        (SELECT id FROM genders WHERE name = 'female'),
        DATE('now'),
        (SELECT id FROM occupations WHERE name = 'student'));

INSERT INTO users (name, email, gender_id, register_date, occupation_id)
VALUES ('Сидоров Пётр', 'sidorov.pp@student.ru',
        (SELECT id FROM genders WHERE name = 'male'),
        DATE('now'),
        (SELECT id FROM occupations WHERE name = 'student'));

INSERT INTO users (name, email, gender_id, register_date, occupation_id)
VALUES ('Козлова Мария', 'kozlova.mm@student.ru',
        (SELECT id FROM genders WHERE name = 'female'),
        DATE('now'),
        (SELECT id FROM occupations WHERE name = 'student'));

-- =====================================================
-- 2. Добавление трёх новых фильмов разных жанров
-- =====================================================
INSERT INTO movies (title, year) VALUES ('День программиста', 2025);
INSERT INTO movie_genres (movie_id, genre_id)
VALUES ((SELECT id FROM movies WHERE title = 'День программиста'),
        (SELECT id FROM genres WHERE name = 'Comedy'));

INSERT INTO movies (title, year) VALUES ('Тайны баз данных', 2025);
INSERT INTO movie_genres (movie_id, genre_id)
VALUES ((SELECT id FROM movies WHERE title = 'Тайны баз данных'),
        (SELECT id FROM genres WHERE name = 'Documentary'));

INSERT INTO movies (title, year) VALUES ('Нормализация: Начало', 2026);
INSERT INTO movie_genres (movie_id, genre_id)
VALUES ((SELECT id FROM movies WHERE title = 'Нормализация: Начало'),
        (SELECT id FROM genres WHERE name = 'Sci-Fi'));

-- =====================================================
-- 3. Добавление трёх отзывов о новых фильмах от себя
-- =====================================================
INSERT INTO ratings (user_id, movie_id, rating, timestamp)
VALUES ((SELECT id FROM users WHERE email = 'bashmakov.mi@student.ru'),
        (SELECT id FROM movies WHERE title = 'День программиста'),
        5.0, strftime('%s', 'now'));

INSERT INTO ratings (user_id, movie_id, rating, timestamp)
VALUES ((SELECT id FROM users WHERE email = 'bashmakov.mi@student.ru'),
        (SELECT id FROM movies WHERE title = 'Тайны баз данных'),
        4.5, strftime('%s', 'now'));

INSERT INTO ratings (user_id, movie_id, rating, timestamp)
VALUES ((SELECT id FROM users WHERE email = 'bashmakov.mi@student.ru'),
        (SELECT id FROM movies WHERE title = 'Нормализация: Начало'),
        4.0, strftime('%s', 'now'));