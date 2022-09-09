import pytest
import json
from app import app


@pytest.fixture()
def client():
    app.config.from_pyfile('flask_test.cfg', silent=True)
    client = app.test_client()
    yield client


def test_homepage_request(client):
    response = client.get("/")
    assert b"<h3>Sklearn Prediction Home</h3>" in response.data


def test_prediction_request(client):
    with open("sample_request.json") as f:
        request_data = json.load(f)
        resp = client.post("/predict", json=request_data)
        assert resp.status_code == 200
        assert isinstance(resp.json['prediction'], list)

