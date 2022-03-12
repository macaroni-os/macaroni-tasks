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
	@echo "isos2cdn         Create task for sync ISOs namespacse to CDN"
	@echo "ns2cdn           Create task for sync Repositories namespaces to CDN"
	@echo "isos_pipeline    Create ISOs Stable pipeline."
	@echo "isos_release     Create ISOs pipeline for a release."
	@echo "luet-tasks       Create/Update Luet repos tasks/pipeline."
	@echo "build-pkgs       Create task for build specific packages."
	@echo "build-pipeline   Create the pipeline for build missing packages of a repository."

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

.PHONY: isos_release
isos_release:
	@make/isos_release

.PHONY: ns2cdn
ns2cdn:
	@make/ns2cdn

.PHONY: luet-tasks
luet-tasks:
	@make/luet-tasks

.PHONY: build-pkgs
build-pkgs:
	@make/build-pkgs

.PHONY: build-pipeline
build-pipeline:
	@make/build-pipeline
