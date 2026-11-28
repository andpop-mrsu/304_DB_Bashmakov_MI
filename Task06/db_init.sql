-- ЛР 6. БД учета успеваемости студентов ФМиИТ

PRAGMA foreign_keys = ON;
BEGIN TRANSACTION;

DROP VIEW IF EXISTS v_students_current;
DROP TABLE IF EXISTS results;
DROP TABLE IF EXISTS curriculum;
DROP TABLE IF EXISTS students;
DROP TABLE IF EXISTS study_groups;
DROP TABLE IF EXISTS disciplines;
DROP TABLE IF EXISTS directions;

-- Направления подготовки
CREATE TABLE directions (
    id INTEGER PRIMARY KEY,
    name TEXT NOT NULL UNIQUE,
    code TEXT NOT NULL UNIQUE,
    level TEXT NOT NULL DEFAULT 'бакалавриат'
        CHECK (level IN ('бакалавриат', 'магистратура'))
);

-- Группы: храним год поступления и суффикс, номер вычисляется
CREATE TABLE study_groups (
    id INTEGER PRIMARY KEY,
    direction_id INTEGER NOT NULL REFERENCES directions(id) ON DELETE RESTRICT,
    admission_year INTEGER NOT NULL CHECK (admission_year BETWEEN 2000 AND 2100),
    group_suffix INTEGER NOT NULL CHECK (group_suffix BETWEEN 1 AND 99),
    UNIQUE (direction_id, admission_year, group_suffix)
);

-- Анкетные данные студентов
CREATE TABLE students (
    id INTEGER PRIMARY KEY,
    group_id INTEGER NOT NULL REFERENCES study_groups(id) ON DELETE RESTRICT,
    last_name TEXT NOT NULL,
    first_name TEXT NOT NULL,
    middle_name TEXT,
    birth_date DATE NOT NULL,
    gender TEXT NOT NULL CHECK (gender IN ('м', 'ж'))
);

-- Дисциплины
CREATE TABLE disciplines (
    id INTEGER PRIMARY KEY,
    name TEXT NOT NULL UNIQUE
);

-- Учебный план: часы и вид аттестации по семестрам
CREATE TABLE curriculum (
    id INTEGER PRIMARY KEY,
    direction_id INTEGER NOT NULL REFERENCES directions(id) ON DELETE RESTRICT,
    discipline_id INTEGER NOT NULL REFERENCES disciplines(id) ON DELETE RESTRICT,
    semester INTEGER NOT NULL CHECK (semester BETWEEN 1 AND 12),
    lecture_hours INTEGER NOT NULL DEFAULT 0 CHECK (lecture_hours >= 0),
    practice_hours INTEGER NOT NULL DEFAULT 0 CHECK (practice_hours >= 0),
    assessment TEXT NOT NULL CHECK (assessment IN ('зачет', 'экзамен')),
    UNIQUE (direction_id, discipline_id, semester)
);

-- Результаты аттестации: баллы (для рейтингов) + оценка (для экзаменов)
CREATE TABLE results (
    student_id INTEGER NOT NULL REFERENCES students(id) ON DELETE CASCADE,
    curriculum_id INTEGER NOT NULL REFERENCES curriculum(id) ON DELETE RESTRICT,
    result_date DATE NOT NULL DEFAULT CURRENT_DATE,
    points INTEGER NOT NULL DEFAULT 0 CHECK (points BETWEEN 0 AND 100),
    grade INTEGER CHECK (grade IN (2, 3, 4, 5)),
    PRIMARY KEY (student_id, curriculum_id)
);

-- Индексы для ускорения отчетов
CREATE INDEX idx_students_last_name ON students(last_name);
CREATE INDEX idx_results_curriculum ON results(curriculum_id);
CREATE INDEX idx_curriculum_direction ON curriculum(direction_id);
CREATE INDEX idx_groups_direction ON study_groups(direction_id);

-- Представление: текущий номер группы считается по системной дате
CREATE VIEW v_students_current AS
SELECT s.id AS student_id,
       s.last_name || ' ' || s.first_name || COALESCE(' ' || s.middle_name, '') AS fio,
       d.name AS direction,
       ((CAST(strftime('%Y','now') AS INTEGER)
         - (CASE WHEN CAST(strftime('%m','now') AS INTEGER) < 9 THEN 1 ELSE 0 END))
        - g.admission_year + 1) * 100 + g.group_suffix AS group_number
FROM students s
JOIN study_groups g ON g.id = s.group_id
JOIN directions d ON d.id = g.direction_id;

-- ===================== ТЕСТОВЫЕ ДАННЫЕ =====================

INSERT INTO directions (id, name, code, level) VALUES
(1, 'Прикладная математика и информатика', '01.03.02', 'бакалавриат'),
(2, 'Фундаментальная информатика и информационные технологии', '02.03.02', 'бакалавриат'),
(3, 'Прикладная информатика', '09.03.03', 'бакалавриат');

INSERT INTO study_groups (id, direction_id, admission_year, group_suffix) VALUES
(1, 1, 2023, 3),   -- сейчас 403
(2, 1, 2024, 3),   -- сейчас 303
(3, 1, 2025, 1),   -- сейчас 201
(4, 2, 2024, 2),   -- сейчас 302
(5, 2, 2025, 2),   -- сейчас 202
(6, 3, 2025, 1);   -- сейчас 201

INSERT INTO students (id, group_id, last_name, first_name, middle_name, birth_date, gender) VALUES
(1, 1, 'Иванов', 'Иван', 'Иванович', '2005-03-12', 'м'),
(2, 1, 'Петрова', 'Анна', 'Сергеевна', '2005-07-25', 'ж'),
(3, 1, 'Сидоров', 'Пётр', 'Алексеевич', '2004-11-02', 'м'),
(4, 1, 'Башмаков', 'Максим', NULL, '2005-01-15', 'м'),
(5, 2, 'Козлова', 'Мария', 'Дмитриевна', '2006-05-30', 'ж'),
(6, 2, 'Смирнов', 'Алексей', 'Андреевич', '2006-09-14', 'м'),
(7, 2, 'Кузнецова', 'Ольга', 'Павловна', '2007-02-08', 'ж'),
(8, 3, 'Попов', 'Дмитрий', 'Николаевич', '2007-12-01', 'м'),
(9, 3, 'Васильева', 'Екатерина', 'Игоревна', '2008-04-19', 'ж'),
(10, 4, 'Морозов', 'Никита', 'Владимирович', '2006-06-21', 'м'),
(11, 4, 'Новикова', 'Дарья', 'Романовна', '2006-10-05', 'ж'),
(12, 5, 'Фёдоров', 'Артём', 'Сергеевич', '2007-08-17', 'м'),
(13, 6, 'Алексеева', 'София', 'Максимовна', '2007-03-23', 'ж');

INSERT INTO disciplines (id, name) VALUES
(1, 'Математический анализ'),
(2, 'Линейная алгебра'),
(3, 'Дискретная математика'),
(4, 'Программирование'),
(5, 'Базы данных'),
(6, 'Физика'),
(7, 'Философия'),
(8, 'Английский язык');

INSERT INTO curriculum (id, direction_id, discipline_id, semester, lecture_hours, practice_hours, assessment) VALUES
(1, 1, 1, 1, 36, 36, 'экзамен'),
(2, 1, 2, 1, 36, 36, 'экзамен'),
(3, 1, 4, 1, 18, 36, 'зачет'),
(4, 1, 8, 1, 0, 36, 'зачет'),
(5, 1, 1, 2, 36, 36, 'экзамен'),
(6, 1, 6, 2, 36, 18, 'зачет'),
(7, 1, 4, 2, 18, 36, 'экзамен'),
(8, 1, 3, 3, 36, 36, 'экзамен'),
(9, 1, 7, 3, 18, 18, 'зачет'),
(10, 1, 5, 4, 36, 36, 'экзамен'),
(11, 2, 1, 1, 36, 36, 'экзамен'),
(12, 2, 4, 1, 18, 36, 'экзамен'),
(13, 2, 8, 1, 0, 36, 'зачет'),
(14, 2, 3, 2, 36, 36, 'экзамен'),
(15, 2, 5, 3, 36, 36, 'экзамен'),
(16, 3, 4, 1, 18, 36, 'зачет'),
(17, 3, 5, 2, 36, 36, 'экзамен'),
(18, 3, 8, 1, 0, 36, 'зачет');

-- Результаты: группа 403 (студенты 1-4), все 4 семестра
INSERT INTO results (student_id, curriculum_id, result_date, points, grade) VALUES
(1, 1, '2024-01-25', 88, 5), (1, 2, '2024-01-28', 76, 4),
(1, 3, '2024-01-20', 82, NULL), (1, 4, '2024-01-22', 70, NULL),
(1, 5, '2024-06-20', 85, 5), (1, 6, '2024-06-15', 68, NULL),
(1, 7, '2024-06-25', 90, 5), (1, 8, '2025-01-25', 79, 4),
(1, 9, '2025-01-20', 75, NULL), (1, 10, '2025-06-20', 91, 5),
(2, 1, '2024-01-25', 95, 5), (2, 2, '2024-01-28', 88, 5),
(2, 3, '2024-01-20', 90, NULL), (2, 4, '2024-01-22', 85, NULL),
(2, 5, '2024-06-20', 92, 5), (2, 6, '2024-06-15', 80, NULL),
(2, 7, '2024-06-25', 96, 5), (2, 8, '2025-01-25', 89, 5),
(2, 9, '2025-01-20', 84, NULL), (2, 10, '2025-06-20', 98, 5),
(3, 1, '2024-01-25', 45, 2), (3, 2, '2024-01-28', 60, 3),
(3, 3, '2024-01-20', 55, NULL), (3, 4, '2024-01-22', 50, NULL),
(3, 5, '2024-06-20', 58, 3), (3, 6, '2024-06-15', 40, NULL),
(3, 7, '2024-06-25', 62, 3), (3, 8, '2025-01-25', 48, 2),
(3, 9, '2025-01-20', 52, NULL), (3, 10, '2025-06-20', 66, 3),
(4, 1, '2024-01-25', 84, 4), (4, 2, '2024-01-28', 90, 5),
(4, 3, '2024-01-20', 88, NULL), (4, 4, '2024-01-22', 78, NULL),
(4, 5, '2024-06-20', 87, 4), (4, 6, '2024-06-15', 74, NULL),
(4, 7, '2024-06-25', 93, 5), (4, 8, '2025-01-25', 86, 4),
(4, 9, '2025-01-20', 80, NULL), (4, 10, '2025-06-20', 100, 5);

-- Группа 303 (студенты 5-7), 1 семестр
INSERT INTO results (student_id, curriculum_id, result_date, points, grade) VALUES
(5, 1, '2025-01-25', 90, 5), (5, 2, '2025-01-28', 85, 4),
(5, 3, '2025-01-20', 88, NULL), (5, 4, '2025-01-22', 92, NULL),
(6, 1, '2025-01-25', 70, 3), (6, 2, '2025-01-28', 75, 4),
(6, 3, '2025-01-20', 65, NULL), (6, 4, '2025-01-22', 60, NULL),
(7, 1, '2025-01-25', 88, 5), (7, 2, '2025-01-28', 91, 5),
(7, 3, '2025-01-20', 86, NULL), (7, 4, '2025-01-22', 89, NULL);

-- Группа 302 (студенты 10-11), направление ФИИТ
INSERT INTO results (student_id, curriculum_id, result_date, points, grade) VALUES
(10, 11, '2025-01-25', 80, 4), (10, 12, '2025-01-28', 85, 5),
(10, 13, '2025-01-20', 75, NULL), (10, 14, '2025-06-20', 78, 4),
(10, 15, '2026-01-25', 88, 5),
(11, 11, '2025-01-25', 92, 5), (11, 12, '2025-01-28', 95, 5),
(11, 13, '2025-01-20', 90, NULL), (11, 14, '2025-06-20', 91, 5),
(11, 15, '2026-01-25', 94, 5);

-- Группы 202 и 201 (студенты 12-13), 1 семестр
INSERT INTO results (student_id, curriculum_id, result_date, points, grade) VALUES
(12, 11, '2026-01-25', 76, 4), (12, 12, '2026-01-28', 81, 4),
(12, 13, '2026-01-20', 70, NULL),
(13, 16, '2026-01-20', 85, NULL), (13, 18, '2026-01-22', 88, NULL);

COMMIT;