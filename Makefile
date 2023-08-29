#
# Template makefile
#

ACCT := $(shell aws sts get-caller-identity --query Account --output text)
CURRENT_VERSION = `tail -1 dbfaker/_version.py | cut -d= -f2 | tr -d ' "'`

IMAGE := dbfaker-image
APP := dbfaker
ECR := $(ACCT).dkr.ecr.us-east-1.amazonaws.com
TARGET := $(ECR)/$(IMAGE)
TARGET_VERSIONED = $(TARGET):$(CURRENT_VERSION)

# Build the container for AMD64
build:
	@docker buildx build --platform linux/amd64 --load -t $(IMAGE) -t "$(IMAGE):$(CURRENT_VERSION)" .

# Build the container for ARM64
buildM1:
	@docker buildx build --platform linux/arm64 --load -t $(IMAGE)m -t "$(IMAGE)m:$(CURRENT_VERSION)" .

settings:
	@echo
	@echo "Settings: \n"
	@echo "Current Version: $(CURRENT_VERSION)"
	@echo "Docker Image: $(IMAGE)"
	@echo "AWS account number: $(ACCT)"
	@echo "Target: $(TARGET)"
	@echo

# version bump using poetry.
# make version v=patch will change 0.1.5 to 0.1.6
# make version v=minor will change 0.1.6 to 0.2.0
# make version v=major|minor|patch
version:
	@poetry version $(v)
	@git add pyproject.toml
	@git add email_ripper/_version.py
	@git commit -m "v$$(poetry version -s)"
	@git tag v$$(poetry version -s)
	@git push
	@git push --tags
	@poetry version

# Run all of the linters and formatters
lint:
	@isort email_ripper
	@black email_ripper
	@pylint email_ripper
	@pflake8 email_ripper

# Run the tests and generate a coverage report
test:
	@pytest --cov --cov-report=html

# Run a bash shell in the container
inspectimage:
	@docker run --rm -it --entrypoint=/bin/bash  $(IMAGE)

# Run a bash shell in the container with a volume mounted
inspectimagedata:
	@docker run --rm -it --volume=$$(pwd)/data:/app/data --entrypoint=/bin/bash  $(IMAGE)

# Run the container with a volume mounted
run:
	@docker run --rm -it --volume=$$(pwd)/data:/data $(IMAGE)

login:
	@aws ecr get-login-password | docker login --username AWS --password-stdin $(ECR)

# Build ARM64 and AMD64 images and push to ECR
# Note this does not install the image in the local repository
# Specify AWS_PROFILE directly or via environmental variable to push to staging or prod ECR
# AWS_PROFILE=staging make push
push: login get_poetry_version
	@docker buildx build --platform linux/amd64,linux/arm64 --push -t $(TARGET) -t "$(TARGET):$(CURRENT_VERSION)" .

# Pull the latest image from ECR
# make pull
pull: login get_poetry_version
	@docker pull $(TARGET):latest
	@docker tag $(TARGET):latest $(IMAGE):latest

# Remove the images from your local repository
clean:
	@docker image rm $(IMAGE):$(CURRENT_VERSION)
	@docker image rm $(IMAGE):latest
