setup:
	python3.7 -m venv ~/.udacity-devops 

install:
	pip install --upgrade pip && \
		pip install -r requirements.txt && \
		pip install locust
linter-test-install:
	pip install pylint pytest
test:
	#python3 -m pytest -vv --cov=myrepolib tests/*.py
	#python3 -m pytest --nbval notebook.ipynb
	#nohup timeout 60 python app.py & 
	#echo $!
	python3 -m pytest -vv tests/*.py -p no:warnings
load-test:
	nohup timeout 60 python app.py &
	pid=$!
	PORT=5000
	locust -f locustfile.py --headless -u 10 -r 1 -H http://localhost:${PORT} -t 60s
lint:
	#hadolint Dockerfile #uncomment to explore linting Dockerfiles
	pylint --disable=R,C,W1203,W0703 app.py

all: install linter-test-install lint test
