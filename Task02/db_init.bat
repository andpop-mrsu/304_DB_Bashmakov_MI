#!/bin/bash
python make_db_init.py
"D:\SQLite\sqlite3.exe" db_init.db < db_init.sql