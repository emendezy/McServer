STACK_NAME := sam-minecraft
PARAMS_FILE := sam-minecraft-params.json
DEFAULT_CHANGESET_NAME := minecraft-server-changes


build:
	sam build --template-file mc-server-stack.yaml

deploy:
	sam deploy \
		--template-file mc-server-stack.yaml \
		--capabilities CAPABILITY_NAMED_IAM
