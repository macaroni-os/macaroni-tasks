# Author: Daniele Rondina, geaaru@funtoo.org
# Description: Macaroni Funtoo Tasks

.PHONY: all
all:
	@echo "============================================"
	@echo "Funtoo Macaroni Tasks/Pipelines Shortcuts"
	@echo "============================================"
	@echo "Available commands:"
	@echo ""
	@echo "lxd-tasks               Update Mottainai tasks and pipeline for all images"
	@echo "iso-tasks               Update Mottainai tasks and pipeline for all ISOs"
	@echo "isos2cdn                Create task for sync ISOs namespacse to CDN"
	@echo "ns2cdn                  Create task for sync Repositories namespaces to CDN"
	@echo "isos_pipeline           Create ISOs Stable pipeline."
	@echo "isos_release            Create ISOs pipeline for a release."
	@echo "luet-tasks              Create/Update Luet repos tasks/pipeline."
	@echo "build-pkgs              Create task for build specific packages."
	@echo "build-pipeline          Create the pipeline for build missing packages of a repository."
	@echo "                        Require a local copy of the target repo."
	@echo "                        Use start-build-pipeline instead."
	@echo "start-build-pipeline    Create task for create build pipeline of the "
	@echo "                        missing packages."
	@echo "luet-pc                 Run luet-portage-converter locally."
	@echo "start-luet-pc           Create task to execute luet-portage-converter for a"
	@echo "                        specified repository."
	@echo "tag4testing             Tag for testing the selected repo (uses target repo)."
	@echo "                        This target is for testing atomic operation."
	@echo "                        Uses tag4test-pipeline instead for workflow."
	@echo "tag4test-pipeline       Tag for testing the selected repo and bump revision."
	@echo "start-upgrade-pipeline  Start a complete upgrade workflow to a specific"
	@echo "                        repository and for the configured kits."
	@echo "docker-tasks            Create/Update docker images build tasks."
	@echo "start-upd-seed-pipeline Start an upgrade workflow for a selected race."
	@echo "start-upd-kits-pipeline Start an upgrade workflow to upgrade kits and"
	@echo "                        bump first seed."

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

.PHONY: start-build-pipeline
start-build-pipeline:
	@make/start-build-pipeline

.PHONY: luet-pc
luet-pc:
	@make/luet-portage-converter

.PHONY: start-luet-pc
start-luet-pc:
	@make/start-luet-pc

.PHONY: tag4testing
tag4testing:
	@make/tag4testing

.PHONY: tag4test-pipeline
tag4test-pipeline:
	@make/tag4test-pipeline

.PHONY: start-upgrade-pipeline
start-upgrade-pipeline:
	@make/start-upgrade-pipeline

.PHONY: docker-tasks
docker-tasks:
	@make/docker-tasks

.PHONY: start-upd-seed-pipeline
start-upd-seed-pipeline:
	@make/start-upgrade-seed-pipeline

.PHONY: start-upd-kits-pipeline
start-upd-kits-pipeline:
	@make/upd-kits-pipeline
