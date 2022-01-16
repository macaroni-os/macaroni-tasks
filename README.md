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
$> RELEASE=0.1.0 make isos_release
```


