# Macaroni OS Automation Tasks

## Show available commands

```shell
$ make
Available commands:

lxd-tasks               Update Mottainai tasks and pipeline for all images
iso-tasks               Update Mottainai tasks and pipeline for all ISOs
isos2cdn                Create task for sync ISOs namespacse to CDN
ns2cdn                  Create task for sync Repositories namespaces to CDN
isos_pipeline           Create ISOs Stable pipeline.
isos_release            Create ISOs pipeline for a release.
luet-tasks              Create/Update Luet repos tasks/pipeline.
build-pkgs              Create task for build specific packages.
build-pipeline          Create the pipeline for build missing packages of a repository.
                        Require a local copy of the target repo.
                        Use start-build-pipeline instead.
start-build-pipeline    Create task for create build pipeline of the 
                        missing packages.
luet-pc                 Run luet-portage-converter locally.
start-luet-pc           Create task to execute luet-portage-converter for a
                        specified repository.
tag4testing             Tag for testing the selected repo (uses target repo).
                        This target is for testing atomic operation.
                        Uses tag4test-pipeline instead for workflow.
tag4test-pipeline       Tag for testing the selected repo and bump revision.
start-upgrade-pipeline  Start a complete upgrade workflow to a specific
                        repository and for the configured kits.
docker-tasks            Create/Update docker images build tasks.
start-upd-seed-pipeline Start an upgrade workflow for a selected race.
start-upd-kits-pipeline Start an upgrade workflow to upgrade kits and
                        bump first seed.
bump-release            Tag and release a specified repository/namespace.
tag-mark-release        Tag a MARK release.
```

### Bump Macaroni Release ISOs

1) Add the specific release in file iso/iso-images.values under the
   attribute `releases`.

2) Run ISOs pipeline

```shell
$> FIRE_TASKS=1 RELEASE=0.1.0 make isos_release
```

### Tag a new MARK release

```shell
$> FIRE_TASK=1 MARK_RELEASE=mark-v MARK_TAG=v25.04-mark-v make tag-mark-release
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

### Start a completed pipeline to upgrade kits and packages (V1)

This is a completed pipeline that union:
- upgrade of the kits
- creation of the metadata packages (seed/funtoo-kits, toolchain/meta-repo)
- bump a new revision
- creation of the seed packages (seed/macaroni-funtoo-stage, seed/macaroni-funtoo-base)
- start pipeline for build all new packages

```shell
$> FIRE_TASK=1  NAMESPACE=macaroni-funtoo-dev GROUP_PIPELINE=1 make start-upgrade-pipeline
```

Avoid GROUP_PIPELINE env to create the build pipeline sequentially.

### Start a completed pipeline to upgrade kits and packages for race

The build process for extra packages is divide in races.
These races must be executed in sequentialy to avoid the the build process choice
packages that uses a race that hasn't yet all packages new updated.

So to ensure this it's needed split build pipeline for every race.


#### macaroni-funtoo-eagle-dev repository

Hereinafter, the workflow for `macaroni-funtoo-eagle-dev` repository:

1. Starting the update of the kits and bump the seed/funtoo-kits and toolchain/meta-repo packages.

```shell
$> FIRE_TASK=1 NAMESPACE=macaroni-funtoo-systemd-dev PUSH_IMAGES=1 make start-upd-kits-pipeline
```

2. Starting the bump and build of the seed/macaroni-funtoo-base and all packages updates of the specs related to that seed.

```shell
$> FIRE_TASK=1 REPO_DIR=${HOME}/dev/macaroni/macaroni-funtoo-eagle/ BUMP_SEED=true SEED=macaroni-funtoo-base GROUP_PIPELINE=1 \
          NAMESPACE=macaroni-funtoo-systemd-dev make start-upd-seed-pipeline

$> FIRE_TASK=1 REPO_DIR=~/dev/macaroni/macaroni-funtoo-eagle/ BUMP_SEED=true SEED=macaroni-funtoo-race1 \
             NAMESPACE=macaroni-funtoo-systemd-dev make start-upd-seed-pipeline

$> FIRE_TASK=1 REPO_DIR=~/dev/macaroni/macaroni-funtoo-eagle/ BUMP_SEED=true SEED=macaroni-funtoo-race2 \
             NAMESPACE=macaroni-funtoo-systemd-dev make start-upd-seed-pipeline

$> FIRE_TASK=1 REPO_DIR=~/dev/macaroni/macaroni-funtoo-eagle/ BUMP_SEED=true SEED=macaroni-funtoo-race3 \
             NAMESPACE=macaroni-funtoo-systemd-dev make start-upd-seed-pipeline

$> FIRE_TASK=1 REPO_DIR=~/dev/macaroni/macaroni-funtoo-eagle/ BUMP_SEED=true SEED=macaroni-funtoo-race4 \
             NAMESPACE=macaroni-funtoo-systemd-dev make start-upd-seed-pipeline

$> FIRE_TASK=1 REPO_DIR=~/dev/macaroni/macaroni-funtoo-eagle/ BUMP_SEED=true SEED=macaroni-funtoo-race5 \
             NAMESPACE=macaroni-funtoo-systemd-dev make start-upd-seed-pipeline

$> FIRE_TASK=1 REPO_DIR=~/dev/macaroni/macaroni-funtoo-eagle/ BUMP_SEED=true SEED=macaroni-funtoo-race6 \
             NAMESPACE=macaroni-funtoo-systemd-dev make start-upd-seed-pipeline

$> FIRE_TASK=1 REPO_DIR=~/dev/macaroni/macaroni-funtoo-eagle/ BUMP_SEED=true SEED=macaroni-funtoo-race7 \
             NAMESPACE=macaroni-funtoo-systemd-dev make start-upd-seed-pipeline

$> FIRE_TASK=1 REPO_DIR=~/dev/macaroni/macaroni-funtoo-eagle/ BUMP_SEED=true SEED=macaroni-funtoo-race8 \
             NAMESPACE=macaroni-funtoo-systemd-dev make start-upd-seed-pipeline

$> FIRE_TASK=1 REPO_DIR=~/dev/macaroni/macaroni-funtoo-eagle/ BUMP_SEED=true SEED=macaroni-funtoo-race9 \
             NAMESPACE=macaroni-funtoo-systemd-dev make start-upd-seed-pipeline

$> FIRE_TASK=1 REPO_DIR=~/dev/macaroni/macaroni-funtoo-eagle/ BUMP_SEED=true SEED=macaroni-funtoo-race10 \
             NAMESPACE=macaroni-funtoo-systemd-dev make start-upd-seed-pipeline

$> FIRE_TASK=1 REPO_DIR=~/dev/macaroni/macaroni-funtoo-eagle/ BUMP_SEED=true SEED=macaroni-funtoo-race11 \
             NAMESPACE=macaroni-funtoo-systemd-dev make start-upd-seed-pipeline

$> FIRE_TASK=1 REPO_DIR=~/dev/macaroni/macaroni-funtoo-eagle/ BUMP_SEED=true SEED=macaroni-funtoo-race12 \
             NAMESPACE=macaroni-funtoo-systemd-dev make start-upd-seed-pipeline

```

#### macaroni-funtoo-dev repository

Hereinafter, the workflow for `macaroni-funtoo-dev` repository:

1. Starting the update of the kits and bump the seed/funtoo-kits and toolchain/meta-repo packages.

```shell
$> FIRE_TASK=1 NAMESPACE=macaroni-funtoo-dev PUSH_IMAGES=1 make start-upd-kits-pipeline
```

2. Starting the bump and build of the seed/macaroni-funtoo-base and all packages updates of the specs related to that seed.

```shell
$> FIRE_TASK=1 REPO_DIR=${HOME}/dev/macaroni/macaroni-funtoo/ BUMP_SEED=true SEED=macaroni-funtoo-base \
          NAMESPACE=macaroni-funtoo-dev make start-upd-seed-pipeline

$> FIRE_TASK=1 REPO_DIR=~/dev/macaroni/macaroni-funtoo/ BUMP_SEED=true SEED=macaroni-funtoo-race1 \
             NAMESPACE=macaroni-funtoo-dev make start-upd-seed-pipeline

$> FIRE_TASK=1 REPO_DIR=~/dev/macaroni/macaroni-funtoo/ BUMP_SEED=true SEED=macaroni-funtoo-race2 \
             NAMESPACE=macaroni-funtoo-dev make start-upd-seed-pipeline

$> FIRE_TASK=1 REPO_DIR=~/dev/macaroni/macaroni-funtoo/ BUMP_SEED=true SEED=macaroni-funtoo-race3 \
             NAMESPACE=macaroni-funtoo-dev make start-upd-seed-pipeline

$> FIRE_TASK=1 REPO_DIR=~/dev/macaroni/macaroni-funtoo/ BUMP_SEED=true SEED=macaroni-funtoo-race4 \
             NAMESPACE=macaroni-funtoo-dev make start-upd-seed-pipeline

$> FIRE_TASK=1 REPO_DIR=~/dev/macaroni/macaroni-funtoo/ BUMP_SEED=true SEED=macaroni-funtoo-race5 \
             NAMESPACE=macaroni-funtoo-dev make start-upd-seed-pipeline

$> FIRE_TASK=1 REPO_DIR=~/dev/macaroni/macaroni-funtoo/ BUMP_SEED=true SEED=macaroni-funtoo-race6 \
             NAMESPACE=macaroni-funtoo-dev make start-upd-seed-pipeline

$> FIRE_TASK=1 REPO_DIR=~/dev/macaroni/macaroni-funtoo/ BUMP_SEED=true SEED=macaroni-funtoo-race7 \
             NAMESPACE=macaroni-funtoo-dev make start-upd-seed-pipeline

$> FIRE_TASK=1 REPO_DIR=~/dev/macaroni/macaroni-funtoo/ BUMP_SEED=true SEED=macaroni-funtoo-race8 \
             NAMESPACE=macaroni-funtoo-dev make start-upd-seed-pipeline

$> FIRE_TASK=1 REPO_DIR=~/dev/macaroni/macaroni-funtoo/ BUMP_SEED=true SEED=macaroni-funtoo-race9 \
             NAMESPACE=macaroni-funtoo-dev make start-upd-seed-pipeline

$> FIRE_TASK=1 REPO_DIR=~/dev/macaroni/macaroni-funtoo/ BUMP_SEED=true SEED=macaroni-funtoo-race10 \
             NAMESPACE=macaroni-funtoo-dev make start-upd-seed-pipeline

$> FIRE_TASK=1 REPO_DIR=~/dev/macaroni/macaroni-funtoo/ BUMP_SEED=true SEED=macaroni-funtoo-race11 \
             NAMESPACE=macaroni-funtoo-dev make start-upd-seed-pipeline

$> FIRE_TASK=1 REPO_DIR=~/dev/macaroni/macaroni-funtoo/ BUMP_SEED=true SEED=macaroni-funtoo-race12 \
             NAMESPACE=macaroni-funtoo-dev make start-upd-seed-pipeline

$> FIRE_TASK=1 REPO_DIR=~/dev/macaroni/macaroni-funtoo/ BUMP_SEED=true SEED=macaroni-funtoo-race13 \
             NAMESPACE=macaroni-funtoo-dev make start-upd-seed-pipeline

$> FIRE_TASK=1 REPO_DIR=~/dev/macaroni/macaroni-funtoo/ BUMP_SEED=true SEED=macaroni-funtoo-race14 \
             NAMESPACE=macaroni-funtoo-dev make start-upd-seed-pipeline

$> FIRE_TASK=1 REPO_DIR=~/dev/macaroni/macaroni-funtoo/ BUMP_SEED=true SEED=macaroni-funtoo-race15 \
             NAMESPACE=macaroni-funtoo-dev make start-upd-seed-pipeline

$> FIRE_TASK=1 REPO_DIR=~/dev/macaroni/macaroni-funtoo/ BUMP_SEED=true SEED=macaroni-funtoo-race16 \
             NAMESPACE=macaroni-funtoo-dev make start-upd-seed-pipeline

$> FIRE_TASK=1 REPO_DIR=~/dev/macaroni/macaroni-funtoo/ BUMP_SEED=true SEED=macaroni-funtoo-race17 \
             NAMESPACE=macaroni-funtoo-dev make start-upd-seed-pipeline

$> FIRE_TASK=1 REPO_DIR=~/dev/macaroni/macaroni-funtoo/ BUMP_SEED=true SEED=macaroni-funtoo-race18 \
             NAMESPACE=macaroni-funtoo-dev make start-upd-seed-pipeline

$> FIRE_TASK=1 REPO_DIR=~/dev/macaroni/macaroni-funtoo/ BUMP_SEED=true SEED=macaroni-funtoo-race19 \
             NAMESPACE=macaroni-funtoo-dev make start-upd-seed-pipeline

$> FIRE_TASK=1 REPO_DIR=~/dev/macaroni/macaroni-funtoo/ BUMP_SEED=true SEED=macaroni-funtoo-race20 \
             NAMESPACE=macaroni-funtoo-dev make start-upd-seed-pipeline
```

#### macaroni-terragon-dev repository

Hereinafter, the workflow for `macaroni-terragon-dev` repository:

1. Starting the update of the kits and bump the seed/funtoo-kits and toolchain/meta-repo packages.

```shell
$> FIRE_TASK=1 NAMESPACE=macaroni-terragon-dev PUSH_IMAGES=1 make start-upd-kits-pipeline
```

2. Start all these races

```shell
$> FIRE_TASK=1 REPO_DIR=~/dev/macaroni/macaroni-funtoo-terragon/ BUMP_SEED=true SEED=macaroni-funtoo-base \
             NAMESPACE=macaroni-terragon-dev make start-upd-seed-pipeline

$> FIRE_TASK=1 REPO_DIR=~/dev/macaroni/macaroni-funtoo-terragon/ BUMP_SEED=true SEED=macaroni-funtoo-race1 \
             NAMESPACE=macaroni-terragon-dev make start-upd-seed-pipeline

$> FIRE_TASK=1 REPO_DIR=~/dev/macaroni/macaroni-funtoo-terragon/ BUMP_SEED=true SEED=macaroni-funtoo-race2 \
             NAMESPACE=macaroni-terragon-dev make start-upd-seed-pipeline

$> FIRE_TASK=1 REPO_DIR=~/dev/macaroni/macaroni-funtoo-terragon/ BUMP_SEED=true SEED=macaroni-funtoo-race3 \
             NAMESPACE=macaroni-terragon-dev make start-upd-seed-pipeline

$> FIRE_TASK=1 REPO_DIR=~/dev/macaroni/macaroni-funtoo-terragon/ BUMP_SEED=true SEED=macaroni-funtoo-race4 \
             NAMESPACE=macaroni-terragon-dev make start-upd-seed-pipeline

$> FIRE_TASK=1 REPO_DIR=~/dev/macaroni/macaroni-funtoo-terragon/ BUMP_SEED=true SEED=macaroni-funtoo-race5 \
             NAMESPACE=macaroni-terragon-dev make start-upd-seed-pipeline

$> FIRE_TASK=1 REPO_DIR=~/dev/macaroni/macaroni-funtoo-terragon/ BUMP_SEED=true SEED=macaroni-funtoo-race6 \
             NAMESPACE=macaroni-terragon-dev make start-upd-seed-pipeline

$> FIRE_TASK=1 REPO_DIR=~/dev/macaroni/macaroni-funtoo-terragon/ BUMP_SEED=true SEED=macaroni-funtoo-race7 \
             NAMESPACE=macaroni-terragon-dev make start-upd-seed-pipeline

$> FIRE_TASK=1 REPO_DIR=~/dev/macaroni/macaroni-funtoo-terragon/ BUMP_SEED=true SEED=macaroni-funtoo-race8 \
             NAMESPACE=macaroni-terragon-dev make start-upd-seed-pipeline

$> FIRE_TASK=1 REPO_DIR=~/dev/macaroni/macaroni-funtoo-terragon/ BUMP_SEED=true SEED=macaroni-funtoo-race9 \
             NAMESPACE=macaroni-terragon-dev make start-upd-seed-pipeline

$> FIRE_TASK=1 REPO_DIR=~/dev/macaroni/macaroni-funtoo-terragon/ BUMP_SEED=true SEED=macaroni-funtoo-race10 \
             NAMESPACE=macaroni-terragon-dev make start-upd-seed-pipeline

```



#### macaroni-security-dev repository

Hereinafter, the workflow for `macaroni-security-dev` repository:

1. Starting the update of the kits and bump the seed/funtoo-kits and toolchain/meta-repo packages.

```shell
$> FIRE_TASK=1 NAMESPACE=macaroni-security-dev PUSH_IMAGES=1 make start-upd-kits-pipeline
```

#### mark-dev repository

Hereinafter, the workflow for `macaroni-security-dev` repository:

1. Starting the update of the kits and bump the seed/funtoo-kits and toolchain/meta-repo packages.

```shell
$> FIRE_TASK=1 NAMESPACE=mark-dev PUSH_IMAGES=1 make start-upd-kits-pipeline
```


### Tag a new release of a specific repository

When a new revision is marked as stable is synced to the CDN storage,
the repoman JSON files are tagged and is created a tag in the selected
repository
