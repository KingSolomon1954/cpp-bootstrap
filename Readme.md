<!---
Comments here if needed.
-->

<h1 align="center">C++ Bootstrap Project</h1>

<p align="center">
    <img src="https://github.com/user-attachments/assets/92fe4271-e308-45e4-9afc-b049fa4c3e0f" alt="">
</p>

<p align="center">
Provides a pre-canned C++ project layout along with automation,
containerized tools and fill-in-the-blanks documentation.
</p>

---

[![Build](https://img.shields.io/github/actions/workflow/status/kingsolomon1954/cpp-bootstrap/build.yml)](https://github.com/kingsolomon1954/cpp-bootstrap/actions/workflows/build.yml)
[![Version](https://img.shields.io/github/v/release/kingsolomon1954/cpp-bootstrap)](https://github.com/kingsolomon1954/cpp-bootstrap/releases)
[![Coverage](https://img.shields.io/badge/dynamic/yaml?url=https%3A%2F%2Fkingsolomon1954.github.io%2Fcpp-bootstrap%2Fcode-coverage%2Fhtml%2Fcode-coverage-badge.yml&query=badge.coverage-percent&suffix=%25&label=coverage)](https://kingsolomon1954.github.io/cpp-bootstrap/code-coverage/html/index.html)
[![Analysis](https://img.shields.io/badge/dynamic/yaml?url=https%3A%2F%2Fkingsolomon1954.github.io%2Fcpp-bootstrap%2Fstatic-analysis%2Freport%2Fstatic-analysis-badge.yml&query=badge.error-count&suffix=%20issues&label=analysis)](https://kingsolomon1954.github.io/cpp-bootstrap/static-analysis/report/index.html)

## Features

- Top level Makefile framework for launching targets
- Uses [containers](#containerized-tools) for build tools (compiler, CMake, auto-docs, etc)
- CMake used only for C++ compilation/linking
- [Production and debug](#simultaneous-production-and-debug-trees) trees
  in same workspace simultaneously
- [Setup](#conan-setup) with [Conan](https://conan.io/) v2.0 C++ libary management
- Configured as a consumer of Conan libraries (not a producer)
- Also setup for two locally developed internal-only libraries
- Automated [documentation generation](#documentation-generation) with
  deployment to GitHub Pages
- Documentation tools - Sphinx, Doxygen, PlantUML
- All documentation organized together under a single static website
- Spell checking on docs, in batch or interactive mode
- [Doctest](https://github.com/doctest/doctest) unit testing framework
- [Code coverage](#code-coverage) using [lcov](https://github.com/linux-test-project/lcov)
- [Static code analysis](#static-code-analysis) via [cppcheck](https://cppcheck.sourceforge.io/manual.html)
- Single ["version"](#versioning) file in top level folder drives all targets
- Clean unpolluted [top level folder](#project-layout)
- [GitHub Workflows](#github-workflows) for builds, releases, and
  document publishing

See the sample auto-generated project documentation here on [Github
Pages](https://kingsolomon1954.github.io/cpp-bootstrap).

*RedFlame* is used as the name of the hypothetical application
that is built.

## Prerequisites

- GNU Makefile
- Podman or Docker
- Some typical Linux command line utilities

Jump ahead to [Getting Started](#getting-started) if you're so inclined.

## Folder Layout

**Top Level View**

    ├── src/
    ├── docs/
    ├── tools/
    ├── etc/
    ├── _build/
    ├── Makefile
    ├── version
    └── Readme.md

**Two Level View**

    ├── Makefile
    ├── Readme.md
    ├── version
    ├── src/
    │  ├── CMakeLists.txt
    │  ├── main
    │  │  ├── include
    │  │  ├── src
    │  │  ├── utest
    │  │  └── CMakeLists.txt
    │  ├── lib-gen
    │  │  ├── include
    │  │  ├── src
    │  │  ├── utest
    │  │  └── CMakeLists.txt
    │  └── lib-codec
    │     ├── include
    │     ├── src
    │     ├── utest
    │     └── CMakeLists.txt
    ├── docs
    │  ├── src
    │  ├── site
    │  └── docs.mak
    ├── tools
    │  ├── cmake
    │  ├── conan
    │  ├── containers
    │  ├── scripts
    │  ├── static-analysis
    │  └── submakes
    └── etc
       ├── Contributing.md
       └── License

Generally conforms to
[PitchFork](https://github.com/vector-of-bool/pitchfork) project layout.

## Example Usages

### Simultaneous Production and Debug Trees

Manage production and debug builds.

```bash
make             # build default tree (default is initially debug)
make prod        # build production tree, default is still debug
make debug       # build debug tree, default is still debug
make set-prod    # set production tree to be default - sticky setting
make             # build default tree (production tree is default)
make debug       # build debug tree, default is still prod
make prod        # build prod tree, default is still prod
make both        # build both prod and debug trees
make both -j     # build both prod and debug trees in parallel
make set-debug   # set debug tree to be default - sticky setting
make clean       # deletes entire _build folder (removes debug and prod)
make clean-debug # removes the debug tree
make clean-prod  # removes the prod tree
make show-default-build # show the default build type
```

### Run the Executables

Assuming you have the handy container
[aliases](#handy-aliases-for-build-container) defined, and you are
sitting in the top folder, then:

```bash
bd bin/RedFlame    # run the app out of debug tree
bp bin/RedFlame    # run the app out of production tree
```

Alternatively you could exec into the build container.

```bash
podman exec -it -w /work/cpp-bootstrap gcc14-tools bash
root#./_build/debug/bin/RedFlame    # run the debug built app
# Or if you have the bbash alias defined
bbash
root#./_build/debug/bin/RedFlame    # run the debug built app

```

Executables are built for the build container's OS, not the host OS,
and are therefore only runnable on the build container. See discussion
below on [Containers](#containerized-tools). 

### Run Unit Tests

```bash
make unit-test          # runs unit tests for default build
make unit-test-debug    # runs unit tests for debug build
make unit-test-prod     # runs unit tests for prod build
make unit-test-both     # runs unit tests for prod and debug build
```

Or directly run a unit test executable. Assuming you have the handy
container [aliases](#handy-aliases-for-build-container) defined, and
you are sitting in the top folder, then:

```bash
bd bin/lib-codec-ut     # run unit tests for library debug tree
bp bin/lib-codec-ut     # run unit tests for library production tree
```

Executables, in this case unit tests, are built for the build
container's OS, not the host OS, and are therefore only runnable on the
build container. See discussion below on [Containers](#containerized-tools).

### Build and Examine the Documentation

```bash
make docs
firefox _build/site/index.html
```
See the same auto-generated documentation here on [Github
Pages](https://kingsolomon1954.github.io/cpp-bootstrap).

## Unit Testing

- Uses [doctest](https://github.com/doctest/doctest)
- Unit tests are kept separate from source code, even though
  doctest allows unit test in the source file itself
- Unconditionally compiles unit tests along with each build

## Versioning

- Single version file in project root, supports repeatable builds
- Semantic versioning

``` bash
cat version
1.0.0
```

- All built artifacts obtain version information from this one file
- Auto-documentation and containers use this version file
- CMake is configured to use this version file
- In addition, C++ Bootstrap supplies its own `buildinfodefs.cmake` to
  auto generate additional build info. Versioning is then made available
  to the application via the [BuildInfo
  class](https://kingsolomon1954.github.io/cpp-bootstrap/doxygen/html/classLibGen_1_1BuildInfo.html)
  in lib-gen

``` bash
> ./bin/RedFlame
RedFlame v1.0.0-1728572288
    Built by: root
    Build date: 2024-10-10T07:58:08-07:00
    Build epoch: 1728572288
    Build branch: ProjectRestructure
    Last commit hash: 932a53f3827f1e1d
```

## Documentation Generation

- There are pre-canned auto documentation samples for:
  - manpage
  - user guide
  - design doc
  - doxygen output
  - licenses
- Uses [Sphinx](https://www.sphinx-doc.org/) with
  [read-the-docs](https://sphinx-rtd-theme.readthedocs.io/en/stable/index.html)
  theme
- [Doxygen](https://www.doxygen.nl/) for internal API
- [PlantUML](https://plantuml.com/) to auto build diagrams
- Makefile auto-generates PlantUML files into PNG files
- Create or modify PlantUML files in `docs/src/images/src`
- Suffix for PlantUML files must be `.puml`
- Place or find auto created `.png`'s in `docs/src/images/pub`
- Recommend creating diagrams with [Drawio](https://www.drawio.com/) and
  maintain drawio source files in `docs/src/images/src`
- Export drawio diagram as a PNG into `docs/src/images/pub`

### Building the Docs

From top level folder, invoke:

```bash
make docs
firefox _build/site/index.html
```

### Pubishing the Docs

When a release build is triggered, docs are built in the normal
_build/site location and then copied to the `docs/site` folder so it can
be checked in to Git.  After a successful build, the `deploy-gh-pages`
workflow runs and publishes the documentation to GH pages.

You may need to configure GitHub pages in your repository. Not sure if
the GitHub pages settings come across from the template repo. To
configure it, visit your <GitHub repo>/Settings->Pages->GitHub
Pages. Ensure the `Build and deployment` section, under
`Source` is selected for `GitHub Actions`.

### Doxygen Setup

Doxygen config file is setup to treat warnings as errors. This is easy
to maintain on new projects, but this setting might be too strict for
some projects with already existing code. Change the
`docs/src/doxygen/Doxyfile` setting from `WARN_AS_ERROR =
FAIL_ON_WARNINGS` to `WARN_AS_ERROR = NO`.

Not every single function or class is documented in doxygen style, nor
should they be.  Only those functions and classes that are meant to be
public need doxygen comments, because you want these to appear in the
published API. Private functions should still be documented, in general
at your discretion, but do not need doxygen style comments.

### Spell Checking Docs

* Spell checking can be performed against a given file or a tree of files
* Spell checking is invoked via Makefile target
* Spell checking can be run in interactive or batch mode
* Interactive mode lets you fix spelling in-place, file by file
* Underlying (containerized) tool is [hunspell](https://linux.die.net/man/1/hunspell)

Makefile targets for spelling:

    spelling-clean    - Deletes spelling artifacts
    spelling-help     - Displays help for spelling usage
    spelling-it       - Spell checks all docs in interactive mode
    spelling          - Spell checks all docs in batch mode
    <filepath>.bspell - Spell checks given file in batch mode
    <filepath>.ispell - Spell checks given file interactively

For full details invoke:

``` bash
make spelling-help
```

### GitHub Workflows

Four workflows manage this repo.

1. build.yml - builds on any push
2. release.yml - manually triggered when a release is desired
3. shared-build.yml - performs both build and release activities
4. deploy-gh-pages.yml - updates GitHub pages after a release

Workflows support developer controls to skip various parts
of the build as desired.

* Just add `[skip-<keyword>]` somewhere in your commit message
* See file `.github/workflows/shared-build.yml` for keywords

## GitHub Workflows

* Workflow for "CI build" - triggers upon merge to main
* Workflow for "Branch build" - triggers upon checkin to branch
* Branch build supports developer controls for skipping various parts

## Containerized Tools

- Uses containers for build tools (compiler, auto-docs, etc)
- Supports Docker or Podman, prefers Podman over Docker if found
- Containers mount local host workspace, no copying into container
- GCC container is auto-started once and remains active
- Re-compiles start immediately, no re-loading of GCC container
- Same containers and tools on desktop and in CI pipelines
- Pipelines invoke same make targets as developer does on desktop
- Convenient Makefile targets abstract away container commands
- The Build container uses
  [docker.io/library/gcc](https://hub.docker.com/_/gcc) as its base
  image which is a Debian distro, therefore executables you create are
  for Debian Linux. If you want to build for a different distro then you
  will want to [switch](#switching-build-container) out the Build
  container with your own.
- [Automated login](#container-registry-login) to container registries
- Supports multiple container registries simultaneously

**Why Containers**

- *Avoids complex tool* management on host, avoids tool version pollution
- *Consistent predictable* identical environment and workflow on both
  host and pipeline/runner machines
- *Avoids dependency issues* and version conflicts on the host and
  pipeline/runner machines
- *Reproducible builds* the set of containers used in a build captures
  the entire environment as coherent tool set
- *Prevents conflicts* between host and runners that might use different
  tools and/or libraries for other activities

### The Build Container 

The build container houses executables for the compiler, CMake, and
Conan along with additional utilities.

C++ Bootstrap provides a build container already setup for gcc14, C++20,
CMake and Conan 2.0 -
`ghcr.io/kingsolomon1954/containers/gcc14-tools:14.2.0`.  The makefile
has targets to build, push and pull the build container.

``` bash
make help
# filtered output
cntr-build-gcc14-tools - Creates gcc14-tools image
cntr-pull-gcc14-tools  - Pulls   gcc14-tools from ghcr.io
cntr-push-gcc14-tools  - Pushes  gcc14-tools to ghcr.io
```

See the docker file here:
`tools/containers/spec-files/dockerfile-gcc14-tools`.

The build container, if it is not already running, is automatically
started upon issuing any `make` target that involves compiling or
linking.  The build container runs in detached mode and hangs around for
further future commands which execute immediately since the container is
already running. The makefile framework arranges commands to be issued
to the build container using docker/podman `exec` command. The build
container is special in that it hangs around. Other containers, such as
those used for building documentation, start and exit after running
their commands.

The strategy used with the build container is to mount your local
workspace. The compiler operates against your local workspace files
without any copying.  You are thus free to use any editors/IDE,
Git tools, etc., on your host computer as normal.

Be aware that the Conan registry and Conan library cache live on the
build container, not on your workspace. If the container is removed and
restarted then the Conan setup will be applied again and libraries will
be retrieved again.  This is purposely setup in this fashion (using the
container to hold the Conan cache) so that the same build container
instance, and thus all the Conan libraries, can be shared across
different repositories, resulting in significant efficiencies in
multi-repo projects, even though not much benefit for this single repo
C++ Bootstrap project.

### Handy Aliases for Build Container

Here's several handy bash aliases that make working with the Build
Container easier. These are meant to be invoked while you're
sitting in the top project folder on your host.

```bash
alias bd="podman exec -w /work/\$(basename \$(pwd))/_build/debug gcc14-tools"
alias bp="podman exec -w /work/\$(basename \$(pwd))/_build/prod gcc14-tools"
alias bt="podman exec -w /work/\$(basename \$(pwd)) gcc14-tools"
alias bbash='echo '\''Use ctrl-p ctrl-q to quit'\''; podman exec -it -w /work/$(basename $(pwd)) gcc14-tools bash'
```

Mnemonically they can be interpreted as:

- `bd` - run a command in the container from the_**b**uild/**d**ebug folder
- `bp` - run a command in the container from the_**b**uild/**p**rod folder
- `bt` - run a command in the **b**uild container from the **t**op folder
- `bbash` - **bash** into to the **b**uild container at the shell prompt

These aliases are also available in a script. You will want to change
the value of _CPP_BOOTSTRAP_HOME in there first to agree with your
environment.

```bash
source tools/scripts/devenv.bash

```

### Container Registry Login

Supports automated and manual login into container registries.

Each container image can come from a different registry.  The registry
that C++ Bootstrap uses for a given container image is specified in the
`tools/submakes/container-names-<tool>.mak`. Each containerized tool has
its own container-names file.

Currently supports:

* localhost
* docker.io
* ghcr.io
* artifactory.io

Login credentials are read from the following locations on your host
in the order shown:

1. environment variables
2. from files
3. otherwise command line prompt

Reads credentials (personal access token(PAT) or password and
user name) from these environment variables if found:

- reads env variable `<REGISTRY>_PAT`      ("." turned into underscore)
- reads env variable `<REGISTRY>_USERNAME`

For example, if the container registry is `docker.io` then looks
for these environment variables:

``` bash
  DOCKER_IO_PAT         # personal access token / password
  DOCKER_IO_USERNAME    # login user name for this registry
```

Reads credentials (personal access token(PAT) or password and
user name) from these files if found:

- reads access token file: `$HOME/.ssh/<REGISTRY>-token`
- reads username file: `$HOME/.ssh/<REGISTRY>-username`

For example, if container registry is `docker.io` then looks
for these files:

``` bash
  $HOME/.ssh/docker.io-token     # personal access token / password
  $HOME/.ssh/docker.io-username  # login user name for this registry
```

These files should have just a single line each. For example:
``` bash
> cat $HOME/.ssh/docker.io-token
dhub_675b9Jam99721
> cat $HOME/.ssh/docker.io-username
Elvis
```

- if no env var or file, then prompts for PAT/password
- if no env var or file, then prompts for username

## Conan Setup

- Setup as a consumer of Conan libraries, not a producer
- Conan library cache is held on the build container, not the host machine
- Automated Conan registry login scheme, supports multiple registries
- Uses Conan lockfiles for locking down library versions for stable
  repeatable builds
- Makefile provides convenient commands to manipulate Conan on the container

### Conan Auto-Registry Setup

Conan 2.0 supports multiple Conan registries. C++ Bootstrap comes
prepared with two Conan Registry files already filled out.

* `tools/conan/registry-conancenter.properties`
* `tools/conan/registry-aws-arty.properties`

The first one is a real registry. conancenter exists. The second
one is a made up registry for the purpose of demonstration.

C++ Bootstrap populates Conan registries into Conan just once, at build
initialization time, before any library retrieval is attempted.  And it
re-populates these later if/when a new container is started, or if a
registry file changes.

To add or remove registries, just add or delete a file having the
following naming pattern:

    tools/conan/registry-*.properties

Properties found in these files are then used to setup each registry in
Conan. The parsing is not sophisticated or flexible, uses simple greps,
so please adhere closely to the layout in the files.

A Conan registry file looks like this:

``` bash
> cat tools/conan/registry-aws-arty.properties
name: aws-arty
url: https://aws.artifactory.io
login: no
enable: yes
publish: yes

```

**name:** \<registry\> the name you give to this Conan registry. Name is
one word. No quotes around it. Must be separated from the ":" with a
space. Best to avoid dashes and periods in the name, although these will
be turned into an underscore for env-var names.

**url:** \<url\> the registry server. url is one word. No quotes around
it. Must be separated from the ":" with a space.

**login:** [yes|no] whether to perform automated login. See next section
for more details. One word. No quotes around it. Must be separated from
the ":" with a space.

**enable:** [yes|no] whether to use or hide this registry. One word. No
quotes around it. Must be separated from the ":" with a space. This is
builtin Conan feature, not a C++ Bootstrap addition.

**publish:** [yes|no] identify this registry as the one registry to use
for publishing your own Conan library packages. One word. No quotes
around it. Must be separated from the ":" with a space. Only one
registry can be be selected for publishing. If multiple property files
indicate "yes", C++ Bootstrap will silently accept the first one it
finds. It is not an error if no registry is identified for publishing as
would be case if your project is a Conan consumer-only project.

### Conan Auto-Login

A registry can be configured in Conan with or without having Conan
establish a login to it. If your project is a Conan library consumer,
then generally you don't need a login. conancenter works this way. But
some registries require a login even for consumer-only operations.

The two registry property files that come with C++ Bootstrap currently
specify `login: no`. If a registry requires a login, change the login
attribute to `login: yes`.

C++ Bootstrap supports automated as well as manual login.

For automation, login credentials are read from the following locations
in the given order, keying off of the name of the registry in
the property file (i.e., `name: <registry>`).

  1. from environment variables
  2. from files
  3. from command line prompt

#### From Environment Variables

Reads credentials (personal access token(PAT) or password and
user name) from these environment variables if found:

    <REGISTRY>_USERNAME
    <REGISTRY>_PAT      ("-" turned into underscore)

For example, if the Conan registry is `aws-arty` then looks
for these environment variables:

    AWS_ARTY_USERNAME    # login user name for this registry
    AWS_ARTY_PAT         # personal access token / password

#### From Files

Reads credentials (personal access token(PAT) or password and
user name) from files if found:

    ~/.ssh/<REGISTRY>-username
    ~/.ssh/<REGISTRY>-token

For example, if container registry is `aws-arty` then looks
for these files:

    $HOME/.ssh/aws-arty-username  # login user name for this registry
    $HOME/.ssh/aws-arty-token     # personal access token / password

These files have just a single line each. For example:

``` bash
> cat $HOME/.ssh/aws-arty-username
ElvisTheDeveloper
> cat $HOME/.ssh/aws-arty-token
aws_regy_675b9Jam99721
```

#### From Command Line Prompt

if no env-var or file, then prompts for PAT/password<br>
if no env-var or file, then prompts for username

### Conan Library Publishing

TBS

## Static Code Analysis

Static code analysis can be performed against all source code in the
repository or against a single file. Built-in support for error
suppression-list. Underlying tool is a containerized `cppcheck`.

The following makefile targets are available:

    static-analysis       - Runs C++ static analysis against repo
    static-analysis-clean - Deletes C++ static analysis artifacts
    static-analysis-help  - Displays help for C++ static analysis
    <filepath>.sta        - Runs C++ static analysis on given file

Find results in `_build/static-analysis/report/index.html`.

``` bash
make static-analysis
firefox _build/static-analysis/report/index.html
```

The static analysis report is included and published as part of the site
documentation. A newer static analysis report replaces a previous one
provided the newer static analysis report is available at the time `make
docs` is invoked. If no static analysis report is available at that
time, then the last published static analysis report remains.

## Code Coverage

To get a code coverage report, invoke the following makefile
target.

``` bash
make code-coverage
firefox _build/debug/coverage/index.html
```

This target rebuilds the debug tree with flags enabling coverage
and profiling, then invokes the CMake `coverage` target which
invokes unit tests along with `gcov`. Find the report in the
`_build/debug/coverage` folder.

Note that normal debug builds do not enable coverage / profiling
flags. These flags slow down compiles dramatically. Therefore this
separate makefile target is available for when you want focus on this
area.

The code coverage report is included and published as part of the site
documentation. A newer code coverage report replaces a previous one
provided the newer coverage report is available at the time `make docs`
is invoked. If no coverage report is available at that time, then the
last published code coverage report remains.

## Getting Started

### 1. Prerequisites

* Host machine: Install docker/podman
* Host machine: Install standard linux utilities, bash, etc

### 2. Retrieve C++ Starter Project

Grab the repo as a
[template](https://help.github.com/en/github/creating-cloning-and-archiving-repositories/creating-a-repository-from-a-template).

### 3. First invocation

See if your host environment is suitable enough for `make help`.

```bash
make help
```

### 4. Compile, Link, Test and Run

```bash
make
make unit-test
bd bin/RedFlame
```

## 5. Automate Registry Logins

Setup Container and Conan login credentials in `~/.ssh`. See
[Container Registry Login](#container-registry-login) and
[Conan Auto-Login](#conan-auto-login).

## 6. Customize

Customize the project to be your own.

## Additional Activities

### Switching Build Container

Assuming you want to use your own locally built build container,
modify file `tools/submakes/container-names-gcc14.mak` as follows:

Change:

    CNTR_GCC_14_TOOLS_REPO  := ghcr.io
    CNTR_GCC_14_TOOLS_IMAGE := kingsolomon1954/containers/gcc14-tools

To:

    CNTR_GCC_14_TOOLS_REPO  := localhost
    CNTR_GCC_14_TOOLS_IMAGE := gcc14-tools

If you haven't already built your own build container image, you can
invoke the following makefile target. This target uses the docker
spec file at `tools/containers/container-files/dockerfile-gcc14-tools`.

```bash
make cntr-build-gcc14-tools
```

You should now have a container image in your local registry. Looks
something like this:

    REPOSITORY             TAG      IMAGE ID      CREATED        SIZE
    localhost/gcc14-tools  latest   ec7fcbd0727b  2 months ago   1.78 GB

### Switching Sphinx Container

Assuming you want to use your own locally built Sphinx container,
modify file `tools/submakes/container-names-sphinx.mak` as follows:

Change:

    CNTR_SPHINX_REPO  := ghcr.io
    CNTR_SPHINX_IMAGE := kingsolomon1954/containers/sphinx

To:

    CNTR_SPHINX_REPO  := localhost
    CNTR_SPHINX_IMAGE := sphinx

If you haven't already built your own Sphinx container image, you can
invoke the following makefile target. This target uses the docker
spec file at `tools/containers/container-files/dockerfile-sphinx`.

```bash
make cntr-build-sphinx-tools
```

You should now have a container image in your local registry. Looks
something like this:

    REPOSITORY             TAG      IMAGE ID      CREATED        SIZE
    localhost/sphinx       7.3.7    cd0fbf8fe687  3 months ago   367 MB

### Compiling a Single File

Assuming you have the container [aliases](#handy-aliases-for-build-container)
defined above:

```bash
bd make -C main src/Properties.o
bd make -C lib-codec src/CodecFast.o
```

This invokes the CMake generated Makefile on the build container
specifying the file to compile. Note this works only after a
build has taken place and thus CMake has already been configured.

### Compiling a Specific Target

Often it is preferable and more efficient to compile only the target
under change as opposed to invoking the entire build.

Assuming you have the container [aliases](#handy-aliases-for-build-container)
defined above:

```bash
bd make help        # See the CMake targets
bd make lib-gen     # Build just the lib-gen library target
```
