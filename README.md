# sq

sq is an open source version of Square's internal `sq` command line tool for running local developer tasks on macOS. Create a `.sq` file in your project to:

- `install` libraries and frameworks
- `start` servers and run `tests`
- `build` and `deploy` apps, or
- `zxcvbnm` ...

## Usage

> [!NOTE]
> OS support: macOS 14+

### Install

You can download all precompiled binaries from the [GitHub Releases](https://github.com/bimo2/sq/releases) section or using the install script:

```sh
curl -sf https://raw.githubusercontent.com/bimo2/sq/main/install | sh
```

### TLDR

```sh
sq
```

## DEBUG

Build `sq` using sq:

```sh
# build the debug scheme
sq build

# test the debug binary
./xcode/Build/Products/Debug/sq

# test the install script
curl -sf file://$(pwd)/install | sh
```

> [!IMPORTANT]
> Release binaries are built with CI (Buildkite) and should be downloaded and renamed to `sq-macos-$(VERSION)` (ex. `sq-macos-0.1`).

#

<sub><sup>**MIT.** Copyright &copy; 2024 Bimal Bhagrath</sup></sub>
