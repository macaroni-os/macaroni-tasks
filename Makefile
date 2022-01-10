# Author: Daniele Rondina, geaaru@funtoo.org
# Description: Macaroni Funtoo Tasks

.PHONY: all
all:
	@echo "==========================================="
	@echo "Funtoo Macaroni Tasks/Pipelines Shortcuts"
	@echo "==========================================="
	@echo "Available commands:"
	@echo ""
	@echo "lxd-tasks        Update Mottainai tasks and pipeline for all images"

.PHONY: lxd-tasks
lxd-tasks:
	@make/lxd-tasks
