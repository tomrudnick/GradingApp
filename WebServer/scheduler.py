from apscheduler.jobstores.base import JobLookupError
from apscheduler.schedulers.background import BackgroundScheduler
import dateparser
from datetime import timedelta, datetime, date
import logging
from threading import Lock
from apns2.client import APNsClient
from apns2.payload import Payload
from apns2.credentials import TokenCredentials
from apns2.errors import BadDeviceToken
from database import User, Database
import AUTH



class Scheduler:
    topic = 'com.tomrudnick.GradingApp'

    def __init__(self, db):
        self.scheduler = BackgroundScheduler()
        self.scheduler.start()
        self.db: Database = db
        self.mutex = Lock()
        self.payload = Payload(content_available=True)
        self.token_credentials = TokenCredentials(auth_key_path=AUTH.auth_key_path,
                                                  auth_key_id=AUTH.auth_key_id,
                                                  team_id=AUTH.team_id)
        self.client = APNsClient(credentials=self.token_credentials, use_sandbox=False)
        self.users = self.db.get_all()
        self.add_jobs()

    def add_device_key(self, user_id, device_key):
        user_ids = [user.user_id for user in self.users]
        if user_id in user_ids:
            self.db.insert_device_key(user_id, device_key)
        else:
            logging.info("For this device key does not exist a user_id")

    def add_device_key(self, user_id, device_key, time, frequency):
        try:
            index = [user.user_id for user in self.users].index(user_id)
            self.users[index].time = time
            self.users[index].frequency = frequency
            self.add_job(self.users[index])
        except ValueError:
            user = User(user_id, frequency, time)
            self.users.append(user)
            self.add_job(user)
        finally:
            self.db.insert_device_key(user_id, device_key)

    def add_jobs(self):
        for user in self.users:
            self.add_job(user, False)

    def add_job(self, user, add_db=True):
        self.mutex.acquire()
        logging.info("Removing old Job")
        try:
            self.scheduler.remove_job(user.user_id)
            logging.info("Old Job removed")
        except JobLookupError:
            logging.info("Old Job did not exist")
        if add_db:
            self.db.insert_user(user.user_id, user.time, user.frequency)

        dt = dateparser.parse(user.time)
        d_now = date.today()
        # This Code should update the date to the current date if the entry is behind
        if dt.date() < d_now:
            logging.info("Update Date to the current date")
            dt = dt.replace(year=d_now.year, month=d_now.month, day=d_now.day)

        if user.frequency == "daily":
            dt += timedelta(days=1)
        elif user.frequency == "weekly":
            dt += timedelta(weeks=1)
        elif user.frequency == "biweekly":
            dt += timedelta(weeks=2)
        elif user.frequency == "monthly":
            dt += timedelta(weeks=4)
        elif user.frequency == "test":
            dt_now = datetime.now()
            if dt < dt_now:
                logging.info("Update test entry to current hour and minute")
                dt = dt.replace(hour=dt_now.hour, minute=dt_now.minute)
            dt += timedelta(seconds=60)
        dt_string = dt.strftime("%m/%d/%Y, %H:%M:%S")
        user.time = dt_string
        self.scheduler.add_job(self.job_exec, 'date', run_date=dt, args=[user],
                               id=user.user_id)
        self.mutex.release()

    def job_exec(self, user):
        print("JOB EXEC: " + user.user_id)
        for device_key in self.db.get_device_keys(user.user_id):
            try:
                self.client.send_notification(device_key, self.payload, self.topic)
            except BadDeviceToken:
                logging.info("Device Token is invalid")
                self.mutex.acquire()
                self.db.remove_device_key(device_key)
                self.mutex.release()
        self.add_job(user)

    def remove_job(self, user_id):
        logging.info("Removing Job")
        self.mutex.acquire()
        try:
            self.scheduler.remove_job(user_id)
            logging.info("Scheduled Job removed")
        except JobLookupError:
            logging.info("Scheduled Job did not exist")
        self.db.remove(user_id)
        self.mutex.release()
