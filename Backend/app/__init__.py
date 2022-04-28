#  app/__init__.py

from flask import Flask

app = Flask(__name__, instance_relative_config=True)

# Load the views
from app import views

# Set debug to true
app.config['DEBUG'] = True
