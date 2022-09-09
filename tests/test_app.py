from urllib import request
import pytest
import json
import os
import requests

@pytest.fixture()
def flask_response():
    with open(os.path.join("..","sample_request.json")) as f:
        request_data = json.load(f)
        r = requests.post(url="http://localhost:5000", data=request_data)        
        return r

def test_valid_json_payload(flask_response):
    assert type(flask_response) == dict