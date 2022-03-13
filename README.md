# Macaroni OS Automation Tasks

## Show available commands

```shell
$ make
===========================================
Funtoo Macaroni Tasks/Pipelines Shortcuts
===========================================
Available commands:

lxd-tasks        Update Mottainai tasks and pipeline for all images
iso-tasks        Update Mottainai tasks and pipeline for all ISOs
isos2cdn         Create task for sync ISOs namespace to CDN
isos_pipeline    Create ISOs Stable pipeline.
isos_release     Create ISOs pipeline for a release.
```

### Bump Macaroni Release ISOs

1) Add the specific release in file iso/iso-images.values under the
   attribute `releases`.

2) Run ISOs pipeline

```shell
$> FIRE_TASKS=1 RELEASE=0.1.0 make isos_release
```

### Force resync of the ISOs stable namespace to CDN storage

If it's needed force the resync to CDN storage
without the complete pipeline is possible using the command:

```shell
$> FIRE_TASK=1 make isos2cdn
```

## Macaroni packages

### Run task to build luet packages defined

```shell
$> NAMESPACE=macaroni-funtoo-dev PACKAGES="seed/funtoo-kits toolchain/meta-repo" FIRE_TASK=1 make build-pkgs
```

For packages that is better to push to the docker registry execute:

```shell
$> NAMESPACE=macaroni-funtoo-dev PACKAGES="seed/funtoo-kits toolchain/meta-repo" FIRE_TASK=1 PUSH_IMAGES=true make build-pkgs
```

### Run task that check missing packages and create build pipeline

```shell
$> FIRE_TASK=1 NAMESPACE=macaroni-commons make start-build-pipeline
```

