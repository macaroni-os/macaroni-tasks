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
	@echo "isos2cdn         Create task for sync ISOs namespace to CDN"
	@echo "isos_pipeline    Create ISOs Stable pipeline."

.PHONY: lxd-tasks
lxd-tasks:
	@make/lxd-tasks

.PHONY: iso-tasks
iso-tasks:
	@make/iso-tasks

.PHONY: isos2cdn
isos2cdn:
	@make/isos2cdn

.PHONY: isos_pipeline
isos_pipeline:
	@make/isos_pipeline
