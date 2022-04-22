#!/usr/bin/env python3
"""
Very simple HTTP server in python for logging requests
Usage::
    ./server.py [<port>]
"""
import http.server
import logging
from database import Database
from scheduler import Scheduler
from httpServer import S
import ssl


def run(handler_class=S, port=8080, https=False):
    logging.basicConfig(level=logging.INFO)
    logging.info("Database starting...")
    db = Database("test.db")
    scheduler = Scheduler(db)
    server_address = ('', port)
    handler = handler_class(scheduler)
    httpd = http.server.HTTPServer(server_address, handler)
    if https:
        httpd.socket = ssl.wrap_socket(httpd.socket,
                                       keyfile="key.pem",
                                       certfile='cert.pem', server_side=True)

    logging.info('Starting httpd...\n')
    try:
        httpd.serve_forever()
    except KeyboardInterrupt:
        pass
    httpd.server_close()
    logging.info('Stopping httpd...\n')


if __name__ == '__main__':
    from sys import argv
    if len(argv) == 3:
        run(port=int(argv[1]), https=argv[2].lower() == 'true')
    else:
        run()
