from locust import HttpUser, task, between


class FlaskMLAppUser(HttpUser):
    # Wait between 5 to 10 seconds between task
    wait_time = between(5, 10)

    @task
    def predict_price(self):
        self.client.post("/predict", json={"CHAS": {
            "0": 0
        },
            "RM": {
            "0": 6.575
        },
            "TAX": {
            "0": 296.0
        },
            "PTRATIO": {
            "0": 15.3
        },
            "B": {
            "0": 396.9
        },
            "LSTAT": {
            "0": 4.98
        }
        })
