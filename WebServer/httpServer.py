from http.server import BaseHTTPRequestHandler
import logging
import json


class S(BaseHTTPRequestHandler):

    def __init__(self, scheduler):
        self.scheduler = scheduler
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
        if len(data) == 3 and 'device_key' in data and 'time' in data and 'frequency' in data:
            logging.info("Inserting data into DB")
            device_key = data['device_key']
            time = data['time']
            frequency = data['frequency']
            self.scheduler.add_job(device_key, time, frequency)
        elif len(data) == 2 and 'device_key' in data and 'remove' in data:
            logging.info("Removing data")
            device_key = data['device_key']
            self.scheduler.remove_job(device_key)
