from urllib import request
import pytest
import json
import os
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
        client.post("/predict", json=request_data)

# def test_valid_json_payload(flask_response):
#     assert type(flask_response) == dict
