from flask import Flask
from handlers.pull_requests import pull_requests_blueprint  # si usas blueprint

app = Flask(__name__)
app.register_blueprint(pull_requests_blueprint)

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)