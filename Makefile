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
	@echo "iso-tasks        Update Mottainai tasks and pipeline for all ISOs"

.PHONY: lxd-tasks
lxd-tasks:
	@make/lxd-tasks

.PHONY: iso-tasks
iso-tasks:
	@make/iso-tasks
