# Makefile for stack deployment

build:
	sam build --template-file mc-server-stack.yaml

deploy:
	sam deploy \
		--stack-name mc-server-stack \
		--region us-east-1 \
		--template-file mc-server-stack.yaml \
		--capabilities CAPABILITY_NAMED_IAM
