import requests
from flask import Blueprint, request, render_template

pull_requests_bp = Blueprint("pull_requests", __name__)

BASE_URL = "https://api.github.com/repos/boto/boto3/pulls"


def get_pull_requests(state=None):
    """
    Fetch pull requests from GitHub API and return them
    in the format expected by the tests.
    Allowed params: state, per_page.
    """
    params = {"per_page": 100}

    if state:
        params["state"] = state

    response = requests.get(BASE_URL, params=params)
    data = response.json()

    # Transformación EXACTA que esperan los tests
    return [
        {
            "title": pr["title"],
            "num": pr["number"],
            "link": pr["html_url"]
        }
        for pr in data
    ]


@pull_requests_bp.route("/pull_requests")
def pull_requests():
    state = request.args.get("state")
    prs = get_pull_requests(state)

    return render_template("pull_requests.html", prs=prs, state=state or "all")
