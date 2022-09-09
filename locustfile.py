import logging
from locust import HttpUser, task, between, events
import locust_plugins

class FlaskMLAppUser(HttpUser):
    # Wait between 3 to 7 seconds between task
    wait_time = between(3, 7)

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

@events.quitting.add_listener
def _(environment, **kw):
    if environment.stats.total.fail_ratio > 0.05:
        logging.error("Test failed due to failure ratio > 5%")
        environment.process_exit_code = 1
    elif environment.stats.total.avg_response_time > 1000:
        logging.error("Test failed due to average response time ratio > 1 s")
        environment.process_exit_code = 1
    elif environment.stats.total.get_response_time_percentile(0.95) > 1200:
        logging.error("Test failed due to 95th percentile response time > 1.2 s")
        environment.process_exit_code = 1
    else:
        environment.process_exit_code = 0