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

.PHONY: server
## server : Start the Hugo server.
server:
	hugo server