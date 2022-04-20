import sqlite3
from sqlite3 import Error
import logging


class Database:
    table = """CREATE TABLE IF NOT EXISTS users(
                device_key string PRIMARY KEY,
                time string NOT NULL,
                frequency string NOT NULL
            );"""

    def __init__(self, filepath):
        self.conn = None
        try:
            conn = sqlite3.connect(filepath, check_same_thread=False)
            self.conn = conn
            self.__create_tables()
        except Error as e:
            print(e)

    def __del__(self):
        self.conn.close()

    def __create_tables(self):
        try:
            c = self.conn.cursor()
            c.execute(self.table)
        except Error as e:
            print(e)

    def insert(self, device_key, time, frequency):
        try:
            c = self.conn.cursor()
            cmd = """INSERT INTO users (device_key, time, frequency)
                     VALUES (?, ?, ?);"""
            c.execute(cmd, (device_key, time, frequency, ))
            self.conn.commit()
        except Error:
            logging.info("This item allready exists...")
            logging.info("Updating item for: " + device_key)
            self.update(device_key, time, frequency)

    def update(self, device_key, time, frequency):
        try:
            c = self.conn.cursor()
            cmd = """UPDATE users
                     SET time = ?, frequency = ?
                     WHERE device_key = ?;"""
            c.execute(cmd, (time, frequency, device_key, ))
            self.conn.commit()
        except Error as e:
            print(e)

    def remove(self, device_key):
        try:
            c = self.conn.cursor()
            cmd = """DELETE FROM users
                    WHERE device_key = ?;"""
            c.execute(cmd, (device_key, ))
            self.conn.commit()
        except Error as e:
            print(e)

    def get_all(self):
        try:
            c = self.conn.cursor()
            c.execute("SELECT * FROM users")
            rows = c.fetchall()
            return rows
        except Error as e:
            print(e)
            return []
