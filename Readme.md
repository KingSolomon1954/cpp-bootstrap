<!---

Add some status badges eventually.
[![codecov](https://codecov.io/gh/filipdutescu/modern-cpp-template/branch/master/graph/badge.svg)](https://codecov.io/gh/filipdutescu/modern-cpp-template)
[![GitHub release (latest by date)](https://img.shields.io/github/v/release/filipdutescu/modern-cpp-template)](https://github.com/filipdutescu/modern-cpp-template/releases)

![LogoBootstrap60x90](https://github.com/user-attachments/assets/92fe4271-e308-45e4-9afc-b049fa4c3e0f)

![Bootstrap](docs/src/images/pub/LogoBootstrap60x90.png) 

-->

<h1 align="center">C++ Bootstrap Project</h1>

<p align="center">
    <img src="https://github.com/user-attachments/assets/92fe4271-e308-45e4-9afc-b049fa4c3e0f" alt="">
</p>

<p align="center">
Provides a pre-canned C++ project layout along with automation and
fill-in-the-blanks documentation.
</p>

---

## Features

- Top level Makefile framework for launching targets
- CMake used only for C++ compilation/linking
- Uses [containers](#containerized-tools) for build tools (compiler, auto-docs, etc)
- [Production and debug](#simultaneous-production-and-debug-trees) trees
  in same workspace simultaneously
- Setup with [Conan](https://conan.io/) v2.0 C++ libary management
- Configured as a consumer of Conan libraries (not a producer)
- Also setup for two locally developed internal-only libraries
- Automated [documentation generation](#documentation-generation) with
  deployment to GitHub Pages
- Documentation tools - Sphinx, Doxygen, PlantUML
- All documentation organized together under a single static website
- [doctest](https://github.com/doctest/doctest) unit testing framework
- Single ["version"](#versioning) file in top level folder drives all targets
- Clean unpolluted [top level folder](#project-layout)
- Code analysis via cppcheck (not implemented yet)
- GitHub Continuous Integration (not implemented yet)
- Spell checking on docs, batch or interactive mode

See the auto-generated documentation here on [Github
Pages](https://kingsolomon1954.github.io/cpp-bootstrap).

*RedFlame* is used as the name of the hypothetical application
that is built.

## Prerequisites

- GNU Makefile
- Podman or Docker
- Some typical Linux command line utilities

Jump ahead to [Getting Started](#getting-started) if you're so inclined.

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

Assuming you have the handy
[aliases](#handy-aliases-for-build-container) defined, and you are
sitting in the top folder, then:

```bash
bd bin/redflame    # run the app out of debug tree 
bp bin/redflame    # run the app out of production tree
```

Alternatively you could exec into the build container.

```bash
podman exec -it -w /work/cpp-bootstrap gcc14-tools bash
root#./_build/debug/bin/redflame    # run the debug app
# Or if you have the bbash alias defined
bbash
root#./_build/debug/bin/redflame    # run the debug app

```

### Run Unit Tests

```bash
make unit-test          # runs unit tests for default build 
make unit-test-debug    # runs unit tests for debug build 
make unit-test-prod     # runs unit tests for prod build 
make unit-test-both     # runs unit tests for prod and debug build 
```

Or directly run a unit test executable. Assuming you have the handy
[aliases](#handy-aliases-for-build-container) defined, and you
are sitting in the top folder, then:

```bash
bd bin/lib-codec-ut     # run unit tests for library debug tree
bp bin/lib-codec-ut     # run unit tests for library production tree
```

### Build and Examine the Documentation

```bash
make docs
firefox _build/site/index.html
```

## Unit Testing

- Uses [doctest](https://github.com/doctest/doctest)
- Unit tests are kept separate from source code, even though
  doctest allows unit test in the source file itself
- Unconditionally compiles unit tests along with each build

## Versioning

- Single version file in project root, supports repeatable builds
- All built artifacts obtain version information from this one file
- CMake auto generates build info, BuildInfo class available to app
- Auto-documentation and containers use same version file
- Semantic versioning

## Documentation Generation

- There are pre-canned auto documentation samples for:
  - manpage
  - user guide
  - design doc
  - doxygen output
  - licenses
- [Sphinx](https://www.sphinx-doc.org/) with
  [read-the-docs](https://sphinx-rtd-theme.readthedocs.io/en/stable/index.html)
  theme
- [Doxygen](https://www.doxygen.nl/) for internal API
- [PlantUML](https://plantuml.com/) to auto build diagrams 
- Makefile auto-generates PlantUML files into PNG files
- Create or modify PlantUML files in `docs/src/images/src`
- Suffix for PlantUML files must be `.puml`
- Find auto created `.png`'s in `docs/src/images/pub`
- Recommend creating diagrams with [Drawio](https://www.drawio.com/) and
  place drawio source files in `docs/src/images/src`
- Then export drawio diagram as a PNG into `docs/src/images/pub`

## Folder Layout

**Top Level View**

    ├── main
    ├── lib-gen
    ├── lib-codec
    ├── docs
    ├── admin
    ├── etc
    └── _build

**Two Level View**

    ├── CMakeLists.txt
    ├── Makefile
    ├── Readme.md
    ├── version
    ├── main
    │  ├── include
    │  ├── src
    │  ├── utest
    │  └── CMakeLists.txt
    ├── lib-gen
    │  ├── include
    │  ├── src
    │  ├── utest
    │  └── CMakeLists.txt
    ├── lib-codec
    │  ├── include
    │  ├── src
    │  ├── utest
    │  └── CMakeLists.txt
    ├── docs
    │  ├── src
    │  ├── site
    │  └── docs.mak
    ├── admin
    │  ├── cmake
    │  ├── conan
    │  ├── containers
    │  ├── scripts
    │  └── submakes
    └── etc
       ├── Contributing.md
       └── License.md

## Conan

- Setup as a consumer of Conan libraries, not a producer
- Uses Conan lockfiles for locking down library versions for stable
  repeatable builds
- Conan library repository cache is on the build container

## Containerized Tools

- Uses containers for build tools (compiler, auto-docs, etc)
- Supports Docker or Podman, prefers Podman over Docker if found
- Containers mount local host workspace, no copying into container
- GCC container is auto-started once and remains active
- Re-compiles start immediately, no re-loading of GCC container
- Same containers and tools on desktop and in CI pipelines
- Convenient Makefile targets abstract away container commands
- The Build container uses
  [docker.io/library/gcc](https://hub.docker.com/_/gcc) as its base
  image which is a Debian distro, therefore executables you create are
  for Debian Linux. If you want to build for a different distro then you
  will want to [switch](#switching-build-containers) out the Build
  container with your own.
- [Automated login](#container-registry-login) to container registries
- Supports multiple container registries simultaneously

**Why Containers**

- *Avoids complex tool* management on host, tool version pollution
- *Consistent predictable* environment on both host and pipeline/runner
  machines
- *Avoids dependency issues* and version conflicts on the host and
  pipeline/runner machines
- *Reproducible builds* as a set of containers that capture the entire
  environment as coherent tool set
- *Prevents conflicts* between host and runners that might use different
  tools and/or libraries for other activities
  
### Container Registry Login

Supports automated and manual login into container registries.
Currently supporting:

* docker.io
* ghcr.io
* artifactory.io

Credentials are read from these locations on your host in this order:

1. environment variables
2. from files
3. otherwise command line prompt

Reads credentials (personal access token(PAT) or password and 
user name) from envionment variables if found:

- checks for env variable `<REGISTRY>_PAT`      ("." turned into underscore)
- checks for env variable `<REGISTRY>_USERNAME`

For example, if container registry is `docker.io` then looks 
for these environment variables:

``` bash
  DOCKER_IO_PAT         # personal access token / password
  DOCKER_IO_USERNAME    # login user name for this registry
```

Reads credentials (personal access token(PAT) or password and 
user name) from files if found:

- reads access token file: `$HOME/.ssh/<REGISTRY>-token`
- reads username file: `$HOME/.ssh/<REGISTRY>-username`

For example, if container registry is `docker.io` then looks 
for these files:

``` bash
  $HOME/.ssh/docker.io-token     # personal access token / password
  $HOME/.ssh/docker.io-username  # login user name for this registry
```

These files have just a single line each. For example:
``` bash
> cat $HOME/.ssh/docker.io-token
dhub_675b9Jam99721
> cat $HOME/.ssh/docker.io-username
Elvis
```

- if no env var or file, then prompts for PAT/password
- if no env var or file, then prompts for username

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
source admin/scripts/devenv.bash

```

## Getting Started

### 1. Retrieve C++ Starter Project

Grab the repo as a
[template](https://help.github.com/en/github/creating-cloning-and-archiving-repositories/creating-a-repository-from-a-template).

### 2. First invocation

See if your host environment is suitable enough for `make help`.

```bash
make help
```

### 3. Container Setup

Create your own Build and Sphinx containers (for now).

TODO: future - make containers available in DockerHub.

Modify file `admin/submakes/container-names-gcc14.mak`:

Change:

    CNTR_GCC_14_TOOLS_REPO  := ghcr.io
    CNTR_GCC_14_TOOLS_IMAGE := kingsolomon1954/containers/gcc14-tools

To:

    CNTR_GCC_14_TOOLS_REPO  := localhost
    CNTR_GCC_14_TOOLS_IMAGE := gcc14-tools

Modify file `admin/submakes/container-names-sphinx.mak`:

Change:

    CNTR_SPHINX_REPO  := ghcr.io
    CNTR_SPHINX_IMAGE := kingsolomon1954/containers/sphinx

To:

    CNTR_SPHINX_REPO  := localhost
    CNTR_SPHINX_IMAGE := sphinx

Now build the containers:

```bash
make cntr-build-gcc14-tools
make cntr-build-sphinx-tools
```

### 4. Create the Conan lock files (debug and prod)

```bash
make conan-lock-both
```
### 5. Compile, Link, Test and Run

```bash
make both
make unit-test
bd bin/redflame
```

## 6. Customize

Customize the project to be your own.

## Additional Activities

### Switching Build Containers

TBS

modify `admin/submakes/start-cpp-bld-container.mak`

### Compiling a Single File

Assuming you have the [aliases](#handy-aliases-for-build-container)
defined above:

```bash
bd make -C main src/Properties.o
bd make -C lib-codec src/CodecFast.o
```

This invokes the CMake generated Makefile on the build container
specifying the file to compile. Note this works only after a
build has taken place and thus CMake is properly configured.

### Compiling a Specific Target

Often it is preferable to compile only the target under change, instead
of invoking the entire build.

Assuming you have the [aliases](#handy-aliases-for-build-container)
defined above:

```bash
bd make help        # See the CMake targets
bd make lib-gen     # Build just the lib-gen library
```

