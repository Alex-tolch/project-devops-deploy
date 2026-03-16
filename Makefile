IMAGE_NAME ?= project-devops-deploy
IMAGE_TAG ?= latest
IMAGE = $(IMAGE_NAME):$(IMAGE_TAG)

test:
	./gradlew test

start: run

run:
	./gradlew bootRun

docker-build:
	docker build -t $(IMAGE) .

docker-run:
	docker run --rm -p 8080:8080 -p 9090:9090 \
		-e JAVA_OPTS="-Xms256m -Xmx512m -Dspring.profiles.active=dev" \
		$(IMAGE)

update-gradle:
	./gradlew wrapper --gradle-version 9.2.1

update-deps:
	./gradlew refreshVersions

install:
	./gradlew dependencies

build:
	./gradlew build

lint:
	./gradlew spotlessCheck

lint-fix:
	./gradlew spotlessApply

.PHONY: build test run docker-build docker-run
