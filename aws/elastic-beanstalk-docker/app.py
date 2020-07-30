from flask import Flask
import os

PORT = os.environ.get('PORT') if 'PORT' in os.environ.keys() else 8080

app = Flask(__name__)


@app.route('/')
def hello_world():
    return 'Hello World!'


if __name__ == '__main__':
    app.run(host="0.0.0.0", port=PORT)
