from urllib import request
import pytest
import json
import os
import requests
import app

@pytest.fixture()
def flask_response():
    with open("sample_request.json") as f:
        app.config['TESTING'] = True
        client = app.test_client()
        yield client
        # request_data = json.load(f)
        # r = requests.post(url="http://localhost:5000", data=request_data)        
        # return r

# def test_valid_json_payload(flask_response):
#     assert type(flask_response) == dict