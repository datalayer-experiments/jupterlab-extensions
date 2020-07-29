# Copyright (c) Jupyter Development Team.
# Distributed under the terms of the Modified BSD License.

CONTAINER_NAME=jlab3-on-jserver

help: ## display this help
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n"} /^[a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

default: help ## default target is help

build: ## build the Docker image
	docker build -t datalayer/jlab3-on-jserver .

push: ## push the image.
	@exec docker push \
	    datalayer/jlab3-on-jserver:latest

start: ## start JupyerLab on port 8888
	docker run \
      --name ${CONTAINER_NAME} \
      --rm \
      -p 8888:8888 \
      datalayer/jlab3-on-jserver:latest \
      start.sh start.sh jupyter lab --ip=0.0.0.0 --port=8888 --NotebookApp.token= --LabApp.password= --no-browser
	echo open http://localhost:8888

connect:
	docker exec -it ${CONTAINER_NAME} bash

ps:
	docker ps -f name=${CONTAINER_NAME}

logs: ## show container logs
	docker logs ${CONTAINER_NAME} -f

stop: ## stop the container.
	@exec docker stop ${CONTAINER_NAME}

rm: ## remove the container.
	@exec docker rm -f ${CONTAINER_NAME}

push: ## push the image.
	@exec docker push \
	    datalayer/jlab3-on-jserver:latest
