import sqlite3
from sqlite3 import Error
import logging
from dataclasses import dataclass
from typing import List
@dataclass
class User:
    user_id: str
    frequency: str
    time: str


    def __hash__(self):
        return hash(self.user_id)

    def __eq__(self, other):
        return self.user_id == other.user_id



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
        self.insert_user(user_id, time, frequency)
        self.insert_device_key(user_id, device_key)

    def insert_device_key(self, user_id, device_key):
        c = self.conn.cursor()
        try:
            cmd = """INSERT INTO deviceUsers (device_key, user_id)
                           VALUES (?, ?);"""
            c.execute(cmd, (device_key, user_id,))
            self.conn.commit()
        except Error:
            logging.info("This device_key already exists")

    def insert_user(self, user_id, time, frequency):
        c = self.conn.cursor()
        try:
            cmd = """INSERT INTO users (user_id, time, frequency)
                             VALUES (?, ?, ?);"""
            c.execute(cmd, (user_id, time, frequency,))
            self.conn.commit()
        except Error:
            logging.info("This item already exists...")
            logging.info("Updating item for: " + user_id)
            self.update_user(user_id, time, frequency)

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

    def remove_device_key(self, device_key):
        logging.info("Removing Device key: " + device_key)
        try:
            c = self.conn.cursor()
            cmd = """DELETE FROM deviceUsers
                     WHERE device_key = ?;"""
            c.execute(cmd, (device_key, ))
            self.conn.commit()
        except Error as e:
            print(e)

    def get_all(self):
        try:
            c = self.conn.cursor()
            c.execute("Select * from users;")
            rows = c.fetchall()
            users = []
            for row in rows:
                user_id = row[0]
                time = row[1]
                frequency = row[2]
                users.append(User(user_id, frequency, time))
            return users

        except Error as e:
            print(e)
            return []

    def get_device_keys(self, user_id):
        try:
            c = self.conn.cursor()
            c.execute("""Select d.device_key from users as u
                      join deviceUsers as d on u.user_id = d.user_id
                      where u.user_id = ?;""", (user_id, ))
            rows = c.fetchall()
            device_keys = [device_key[0] for device_key in rows]
            return device_keys
        except Error as e:
            print(e)
            return []

    def get_all_users(self):
        try:
            c = self.conn.cursor()
            c.execute("Select * from users;")
            rows = c.fetchall()
            return rows
        except Error as e:
            print(e)
            return []