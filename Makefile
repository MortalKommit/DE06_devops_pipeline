setup:
	python3.7 -m venv ~/.udacity-devops 

install:
	pip install --upgrade pip && \
		pip install -r requirements.txt && \
		pip install locust && \
		pip install requests

linter-test-install:
	pip install pylint pytest
	nohup timeout 20 python app.py & 
	echo $!
test:
	#python3 -m pytest -vv --cov=myrepolib tests/*.py
	#python3 -m pytest --nbval notebook.ipynb
	python3 -m pytest -vv tests/*.py
load-test:
	locust -f locustfile.py --headless -u 10 -r 1 -H http://localhost:5000 -t 60s
lint:
	#hadolint Dockerfile #uncomment to explore linting Dockerfiles
	pylint --disable=R,C,W1203,W0703 app.py

all: install linter-test-install lint test
