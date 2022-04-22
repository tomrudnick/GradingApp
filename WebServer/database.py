import sqlite3
from sqlite3 import Error
import logging


class Database:
    table_user = """CREATE TABLE IF NOT EXISTS users(
                user_id string PRIMARY KEY,
                time string NOT NULL,
                frequency string NOT NULL
            );"""

    table_device = """CREATE TABLE deviceUsers(
                device_key string PRIMARY KEY,
                user_id string,
                FOREIGN KEY(user_id) REFERENCES users(user_id) ON DELETE CASCADE);"""

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
            c.execute(self.table_user)
            c.execute(self.table_device)
        except Error as e:
            print(e)

    def insert(self, user_id, device_key, time, frequency):
        c = self.conn.cursor()
        try:
            cmd = """INSERT INTO users (user_id, time, frequency)
                     VALUES (?, ?, ?);"""
            c.execute(cmd, (user_id, time, frequency, ))
            self.conn.commit()
        except Error:
            logging.info("This item already exists...")
            logging.info("Updating item for: " + user_id)
            self.update_user(user_id, time, frequency)

        try:
            cmd = """INSERT INTO deviceUsers (device_key, user_id)
                     VALUES (?, ?);"""
            c.execute(cmd, (device_key, user_id, ))
            self.conn.commit()
        except Error:
            logging.info("This device_key already exists")

    def update_user(self, user_id, time, frequency):
        try:
            c = self.conn.cursor()
            cmd = """UPDATE users
                     SET time = ?, frequency = ?
                     WHERE user_id = ?;"""
            c.execute(cmd, (time, frequency, user_id, ))
            self.conn.commit()
        except Error as e:
            print(e)

    def remove(self, user_id):
        try:
            c = self.conn.cursor()
            cmd = """DELETE FROM users
                    WHERE user_id = ?;"""
            c.execute(cmd, (user_id, ))
            self.conn.commit()
        except Error as e:
            print(e)

    def get_all(self):
        try:
            c = self.conn.cursor()
            c.execute("Select d.device_key, u.time, u.frequency from deviceUsers as d "
                      "join users as u on d.user_id = u.user_id;")
            rows = c.fetchall()
            return rows
        except Error as e:
            print(e)
            return []
