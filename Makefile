setup:
	python3.7 -m venv ~/.udacity-devops 
	python3.7 -m pip install pylint pytest
	python3.7 -m pip list
install:
	pip install --upgrade pip && \
		pip install -r requirements.txt && \
		pip install locust && \
		pip install locust-plugins
test:
	#python3 -m pytest -vv --cov=myrepolib tests/*.py
	#python3 -m pytest --nbval notebook.ipynb
	python3.7  -m pytest -vv tests/*.py -p no:warnings

load-test:
	nohup timeout 60 python app.py &
	pid=${$!}
	sleep 1
	locust -f locustfile.py --headless -u 10 -r 1 -H http://localhost:5000 -t 50s --check-fail-ratio 0.08

lint:
	#hadolint Dockerfile #uncomment to explore linting Dockerfiles
	pylint --disable=R,C,W1203,W0703 app.py

all: setup install lint test load-test
