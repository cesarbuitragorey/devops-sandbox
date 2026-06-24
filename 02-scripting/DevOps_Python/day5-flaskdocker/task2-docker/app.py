from flask import Flask
from handlers.pull_requests import pull_requests_bp

app = Flask(__name__)
app.register_blueprint(pull_requests_bp)