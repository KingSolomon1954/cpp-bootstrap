<!---

Build Status

-->
![Bootstrap](docs/src/images/pub/LogoBootstrap60x90.png) 
# C++ Bootstrap Project

The purpose of this C++ Bootstrap Project is to provide a pre-canned C++
project layout along with automation and fill-in-the-blanks
documentation.

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
- Clean unpolluted top level folder
- Code analysis via cppcheck (not implemented yet)
- GitHub Continuous Integration (not implemented yet)
- Spell checking on docs (not implemented yet)

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
bd bin/redflame       # run the app out of debug tree
bp bin/redflame       # run the app out of production tree
```

Alternatively you could exec into the build container.

```bash
podman exec -it -w /work/app-1 gcc14-tools bash
root#./_build/debug/bin/redflame    # run the debug app
# Or if you have the bashc alias defined
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

## Detailed Actions

### Compiling a single file

Assuming you have the [aliases](#handy-aliases-for-build-container)
defined above:

```bash
bd make -C main src/Properties.o
bd make -C main lib-codec/CodecFast.o
```

This invokes the CMake generated Makefile on the build container
specifying the file to compile. Note this works only after a
build has taken place and thus CMake is properly configured.

## Getting Started

### Retrieve C++ Starter Project

Grab the repo as a
[template](https://help.github.com/en/github/creating-cloning-and-archiving-repositories/creating-a-repository-from-a-template).

### First invocation

See if your host environment is suitable enough for `make help`.

```bash
make help
```

### Container Setup

Create your own Build and Sphinx containers (for now).
TODO: future - make containers available in DockerHub.

```bash
make cntr-build-gcc14-tools
make cntr-build-sphinx-tools
```

Modify file `admin/submakes/container-names-gcc14.mak`:

Change:

```
CNTR_GCC_14_TOOLS_REPO  := ghcr.io
CNTR_GCC_14_TOOLS_IMAGE := kingsolomon1954/containers/gcc14-tools
```
To:
```
CNTR_GCC_14_TOOLS_REPO  := localhost
CNTR_GCC_14_TOOLS_IMAGE := gcc14-tools
```

Modify file `admin/submakes/container-names-sphinx.mak`:

Change:

```
CNTR_SPHINX_REPO  := ghcr.io
CNTR_SPHINX_IMAGE := kingsolomon1954/containers/sphinx
```
To:
```
CNTR_SPHINX_REPO  := localhost
CNTR_SPHINX_IMAGE := sphinx
```

### Create the Conan lock files (debug and prod)

```bash
make conan-lock-both
```
### Compile and Link

```bash
make both
```

## And You're Off

Customize the repo to be your own project.
