from urllib import request
import pytest
import json
import os
import requests
from app import app

@pytest.fixture()
def client():
    with open("sample_request.json") as f:
        app.config.from_pyfile('flask_test.cfg', silent=True)
        client = app.test_client()
        yield client
        # request_data = json.load(f)
        # r = requests.post(url="http://localhost:5000", data=request_data)        
        # return r

def test_request_example(client):
    response = client.get("/")
    assert b"<h3>Sklearn Prediction Home</h3>" in response.data

# def test_valid_json_payload(flask_response):
#     assert type(flask_response) == dict