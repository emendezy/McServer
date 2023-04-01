STACK_NAME := sam-minecraft
PARAMS_FILE := sam-minecraft-params.json
DEFAULT_CHANGESET_NAME := minecraft-server-changes


build:
	sam build

deploy:
	sam deploy \
		--capabilities CAPABILITY_NAMED_IAM
