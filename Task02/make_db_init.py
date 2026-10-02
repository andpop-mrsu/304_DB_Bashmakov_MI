import csv
import re

sql_file = 'db_init.sql'

with open(sql_file, 'w', encoding='utf-8') as out:
    out.write("PRAGMA foreign_keys=OFF;\nBEGIN TRANSACTION;\n\n")
    out.write("DROP TABLE IF EXISTS movies;\nDROP TABLE IF EXISTS ratings;\nDROP TABLE IF EXISTS tags;\nDROP TABLE IF EXISTS users;\n\n")
    out.write("CREATE TABLE movies (id INTEGER PRIMARY KEY, title TEXT, year INTEGER, genres TEXT);\n\n")
    out.write("CREATE TABLE ratings (id INTEGER PRIMARY KEY, user_id INTEGER, movie_id INTEGER, rating REAL, timestamp INTEGER);\n\n")
    out.write("CREATE TABLE tags (id INTEGER PRIMARY KEY, user_id INTEGER, movie_id INTEGER, tag TEXT, timestamp INTEGER);\n\n")
    out.write("CREATE TABLE users (id INTEGER PRIMARY KEY, name TEXT, email TEXT, gender TEXT, register_date TEXT, occupation TEXT);\n\n")

    with open('../dataset/movies.csv', 'r', encoding='utf-8') as f:
        reader = csv.reader(f)
        next(reader)
        for row in reader:
            if not row or len(row) < 3: continue
            movie_id, title_full, genres = row[0], row[1], row[2].replace("'", "''")
            match = re.search(r'\((\d{4})\)\s*$', title_full)
            year = match.group(1) if match else 'NULL'
            title = title_full[:match.start()].strip().replace("'", "''") if match else title_full.replace("'", "''")
            out.write(f"INSERT INTO movies (id, title, year, genres) VALUES ({movie_id}, '{title}', {year}, '{genres}');\n")

    with open('../dataset/ratings.csv', 'r', encoding='utf-8') as f:
        reader = csv.reader(f)
        next(reader)
        for row_id, row in enumerate(filter(None, reader), 1):
            if len(row) >= 4:
                out.write(f"INSERT INTO ratings (id, user_id, movie_id, rating, timestamp) VALUES ({row_id}, {row[0]}, {row[1]}, {row[2]}, {row[3]});\n")

    with open('../dataset/tags.csv', 'r', encoding='utf-8') as f:
        reader = csv.reader(f)
        next(reader)
        for row_id, row in enumerate(filter(None, reader), 1):
            if len(row) >= 4:
                out.write(f"INSERT INTO tags (id, user_id, movie_id, tag, timestamp) VALUES ({row_id}, {row[0]}, {row[1]}, '{row[2].replace(chr(39), chr(39)*2)}', {row[3]});\n")

    with open('../dataset/users.txt', 'r', encoding='utf-8') as f:
        for line in f:
            parts = line.strip().split('|')
            if len(parts) >= 6:
                uid, name, email, gender, reg_date, occupation = parts[:6]
                out.write(f"INSERT INTO users (id, name, email, gender, register_date, occupation) VALUES ({uid}, '{name.replace(chr(39), chr(39)*2)}', '{email.replace(chr(39), chr(39)*2)}', '{gender}', '{reg_date}', '{occupation.replace(chr(39), chr(39)*2)}');\n")

    out.write("\nCOMMIT;\n")
print("Файл db_init.sql успешно сгенерирован!")