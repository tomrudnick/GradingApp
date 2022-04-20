from apscheduler.jobstores.base import JobLookupError
from apscheduler.schedulers.background import BackgroundScheduler
import dateparser
from datetime import timedelta, datetime, date
import logging
from threading import Lock
from apns2.client import APNsClient
from apns2.payload import Payload
from apns2.credentials import TokenCredentials
import AUTH


class Scheduler:
    topic = 'com.tomrudnick.GradingApp'

    def __init__(self, db):
        self.scheduler = BackgroundScheduler()
        self.scheduler.start()
        self.db = db
        self.mutex = Lock()
        self.payload = Payload(content_available=True)
        self.token_credentials = TokenCredentials(auth_key_path=AUTH.auth_key_path,
                                                  auth_key_id=AUTH.auth_key_id,
                                                  team_id=AUTH.team_id)
        self.client = APNsClient(credentials=self.token_credentials, use_sandbox=True)
        self.add_jobs(self.db.get_all())



    def add_jobs(self, job_list):
        for job in job_list:
            self.add_job(job[0], job[1], job[2], False)

    def add_job(self, device_key, time, frequency, add_db=True):
        self.mutex.acquire()
        logging.info("Removing old Job")
        try:
            self.scheduler.remove_job(device_key)
            logging.info("Old Job removed")
        except JobLookupError:
            logging.info("Old Job did not exist")
        if add_db:
            self.db.insert(device_key, time, frequency)

        dt = dateparser.parse(time)
        d_now = date.today()
        # This Code should update the date to the current date if the entry is behind
        if dt.date() < d_now:
            logging.info("Update Date to the current date")
            dt = dt.replace(year=d_now.year, month=d_now.month, day=d_now.day)

        if frequency == "daily":
            dt += timedelta(days=1)
        elif frequency == "weekly":
            dt += timedelta(weeks=1)
        elif frequency == "biweekly":
            dt += timedelta(weeks=2)
        elif frequency == "monthly":
            dt += timedelta(weeks=4)
        elif frequency == "test":
            dt_now = datetime.now()
            if dt < dt_now:
                logging.info("Update test entry to current hour and minute")
                dt = dt.replace(hour=dt_now.hour, minute=dt_now.minute)
            dt += timedelta(seconds=60)
        dt_string = dt.strftime("%m/%d/%Y, %H:%M:%S")
        self.scheduler.add_job(self.job_exec, 'date', run_date=dt, args=[device_key, dt_string, frequency],
                               id=device_key)
        self.mutex.release()

    def job_exec(self, device_key, time, frequency):
        print("JOB EXEC: " + device_key)
        self.client.send_notification(device_key, self.payload, self.topic)
        self.add_job(device_key, time, frequency)

    def remove_job(self, device_key):
        logging.info("Removing Job")
        self.mutex.acquire()
        try:
            self.scheduler.remove_job(device_key)
            logging.info("Scheduled Job removed")
        except JobLookupError:
            logging.info("Scheduled Job did not exist")
        self.db.remove(device_key)
        self.mutex.release()
