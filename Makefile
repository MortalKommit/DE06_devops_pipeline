setup:
	python3.7 -m venv ~/.udacity-devops 
	pip install pylint pytest

install:
	pip install --upgrade pip && \
		pip install -r requirements.txt && \
		pip install locust

test:
	#python3 -m pytest -vv --cov=myrepolib tests/*.py
	#python3 -m pytest --nbval notebook.ipynb
	python3 -m pytest -vv tests/*.py -p no:warnings

load-test:
	nohup timeout 60 python app.py &
	pid=${$!}
	locust -f locustfile.py --headless -u 10 -r 1 -H http://localhost:5000 -t 45s

lint:
	#hadolint Dockerfile #uncomment to explore linting Dockerfiles
	pylint --disable=R,C,W1203,W0703 app.py

all: setup install lint test load-test
