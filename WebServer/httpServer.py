from http.server import BaseHTTPRequestHandler
import logging
import json
from scheduler import Scheduler


class S(BaseHTTPRequestHandler):

    def __init__(self, scheduler):
        self.scheduler: Scheduler = scheduler
        # self.db = self.scheduler.db

    def __call__(self, *args, **kwargs):
        """Handle a request."""
        super().__init__(*args, **kwargs)

    def _set_response(self):
        self.send_response(200)
        self.send_header('Content-type', 'text/html')
        self.end_headers()

    def do_GET(self):
        logging.info("GET request,\nPath: %s\nHeaders:\n%s\n", str(self.path), str(self.headers))
        self._set_response()
        self.wfile.write("GET request for {}".format(self.path).encode('utf-8'))

    def do_POST(self):
        content_length = int(self.headers['Content-Length'])  # <--- Gets the size of data
        post_data = self.rfile.read(content_length)  # <--- Gets the data itself
        logging.info("POST request,\nPath: %s\nHeaders:\n%s\n\nBody:\n%s\n",
                     str(self.path), str(self.headers), post_data.decode('utf-8'))

        self._set_response()
        self.wfile.write("POST request for {}".format(self.path).encode('utf-8'))
        self.wfile.write(b'Received: ')
        self.wfile.write(post_data)
        data = json.loads(post_data)
        if len(data) == 4 and 'user_id' in data and 'device_key' in data and 'time' in data and 'frequency' in data:
            logging.info("Inserting data into DB")
            user_id = data['user_id']
            device_key = data['device_key']
            time = data['time']
            frequency = data['frequency']
            self.scheduler.add_device_key(user_id, device_key, time, frequency)
        elif len(data) == 2 and 'user_id' in data and 'remove' in data:
            logging.info("Removing data")
            user_id = data['user_id']
            self.scheduler.remove_job(user_id)
