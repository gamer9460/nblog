## ----------------------------------------------------------------------------
## Make targets to test deployments locally.
## ----------------------------------------------------------------------------

.PHONY: help
# A target to format and present all supported targets with their descriptions.
help : Makefile
		@sed -n 's/^##//p' $<

.PHONY: %
## % 	: Generate a new blog file.
%:
	hugo new content/blog/$@.md

.PHONY: build
## build : build docker image for hugo application
build:
	docker build . -t hugo

.PHONY: deploy
## deploy : deploy hugo application in docker container
deploy:
	docker run --rm -p 8080:8080 hugo