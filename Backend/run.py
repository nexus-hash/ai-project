# run.py
from app import app
import os

if __name__ == '__main__':
    app.run(port=os.environ['PORT'], host='0.0.0.0')