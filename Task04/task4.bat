#!/bin/bash
chcp 65001

sqlite3 movies_rating.db < db_init.sql

echo "1. Найти все пары пользователей, оценивших один и тот же фильм. Устранить дубликаты, проверить отсутствие пар с самим собой. Для каждой пары должны быть указаны имена пользователей и название фильма. В списке оставить первые 100 записей."
echo --------------------------------------------------
sqlite3 movies_rating.db -box -echo "SELECT DISTINCT u1.name AS user1, u2.name AS user2, m.title AS movie FROM ratings r1 JOIN ratings r2 ON r1.movie_id = r2.movie_id AND r1.user_id < r2.user_id JOIN users u1 ON r1.user_id = u1.id JOIN users u2 ON r2.user_id = u2.id JOIN movies m ON r1.movie_id = m.id LIMIT 100;"
echo " "

echo "2. Найти 10 самых свежих оценок от разных пользователей, вывести названия фильмов, имена пользователей, оценку, дату отзыва в формате ГГГГ-ММ-ДД."
echo --------------------------------------------------
 sqlite3 movies_rating.db -box -echo "SELECT m.title, u.name, r.rating, DATE(r.timestamp, 'unixepoch') AS review_date FROM ratings r JOIN users u ON r.user_id = u.id JOIN movies m ON r.movie_id = m.id WHERE r.timestamp IN (SELECT MAX(timestamp) FROM ratings GROUP BY user_id) ORDER BY r.timestamp DESC LIMIT 10;"

echo "3. Вывести в одном списке все фильмы с максимальным средним рейтингом и все фильмы с минимальным средним рейтингом. Общий список отсортировать по году выпуска и названию фильма. В зависимости от рейтинга в колонке 'Рекомендуем' для фильмов должно быть написано 'Да' или 'Нет'."
echo --------------------------------------------------
sqlite3 movies_rating.db -box -echo "WITH avg_ratings AS (SELECT movie_id, AVG(rating) AS avg_rating FROM ratings GROUP BY movie_id), max_avg AS (SELECT MAX(avg_rating) AS max_val FROM avg_ratings), min_avg AS (SELECT MIN(avg_rating) AS min_val FROM avg_ratings) SELECT m.title, m.year, ar.avg_rating, CASE WHEN ar.avg_rating = (SELECT max_val FROM max_avg) THEN 'Да' ELSE 'Нет' END AS recommended FROM movies m JOIN avg_ratings ar ON m.id = ar.movie_id WHERE ar.avg_rating = (SELECT max_val FROM max_avg) OR ar.avg_rating = (SELECT min_val FROM min_avg) ORDER BY m.year, m.title;"
echo " "

echo "4. Вычислить количество оценок и среднюю оценку, которую дали фильмам пользователи-женщины в период с 2010 по 2012 год."
echo --------------------------------------------------
sqlite3 movies_rating.db -box -echo "SELECT COUNT(*) AS rating_count, AVG(r.rating) AS avg_rating FROM ratings r JOIN users u ON r.user_id = u.id WHERE u.gender = 'female' AND DATE(r.timestamp, 'unixepoch') BETWEEN '2010-01-01' AND '2012-12-31';"
echo " "

echo "5. Составить список фильмов с указанием их средней оценки и места в рейтинге по средней оценке. Полученный список отсортировать по году выпуска и названиям фильмов. В списке оставить первые 20 записей."
echo --------------------------------------------------
sqlite3 movies_rating.db -box -echo "WITH movie_stats AS (SELECT movie_id, AVG(rating) AS avg_rating FROM ratings GROUP BY movie_id), ranked AS (SELECT movie_id, avg_rating, RANK() OVER (ORDER BY avg_rating DESC) AS rank_position FROM movie_stats) SELECT m.title, m.year, rs.avg_rating, rs.rank_position FROM ranked rs JOIN movies m ON rs.movie_id = m.id ORDER BY m.year, m.title LIMIT 20;"
echo " "

echo "6. Вывести список из 10 последних зарегистрированных пользователей в формате 'Фамилия Имя|Дата регистрации' (сначала фамилия, потом имя)."
echo --------------------------------------------------
sqlite3 movies_rating.db -box -echo "SELECT SUBSTR(name, INSTR(name, ' ') + 1) || ' ' || SUBSTR(name, 1, INSTR(name, ' ') - 1) || '|' || register_date AS formatted_info FROM users ORDER BY register_date DESC LIMIT 10;"
echo " "

echo "7. С помощью рекурсивного CTE составить таблицу умножения для чисел от 1 до 10."
echo --------------------------------------------------
sqlite3 movies_rating.db -box -echo "WITH RECURSIVE multiplication(x, y, result) AS (SELECT 1, 1, 1 UNION ALL SELECT CASE WHEN y = 10 THEN x + 1 ELSE x END, CASE WHEN y = 10 THEN 1 ELSE y + 1 END, CASE WHEN y = 10 THEN (x + 1) * 1 ELSE x * (y + 1) END FROM multiplication WHERE x < 10 OR (x = 10 AND y < 10)) SELECT x || 'x' || y || '=' || result AS multiplication_table FROM multiplication;"
echo " "

echo "8. С помощью рекурсивного CTE выделить все жанры фильмов, имеющиеся в таблице movies (каждый жанр в отдельной строке)."
echo --------------------------------------------------
sqlite3 movies_rating.db -box -echo "WITH RECURSIVE split_genres(movie_id, genre, rest) AS (SELECT id, CASE WHEN INSTR(genres, '|') > 0 THEN SUBSTR(genres, 1, INSTR(genres, '|') - 1) ELSE genres END, CASE WHEN INSTR(genres, '|') > 0 THEN SUBSTR(genres, INSTR(genres, '|') + 1) ELSE '' END FROM movies UNION ALL SELECT movie_id, CASE WHEN INSTR(rest, '|') > 0 THEN SUBSTR(rest, 1, INSTR(rest, '|') - 1) ELSE rest END, CASE WHEN INSTR(rest, '|') > 0 THEN SUBSTR(rest, INSTR(rest, '|') + 1) ELSE '' END FROM split_genres WHERE rest <> '') SELECT DISTINCT genre AS all_genres FROM split_genres ORDER BY genre;"