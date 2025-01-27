# sq

sq is an open source version of Square's internal `sq` command line tool for developer experience on macOS. Create a `.sq` file in your repository to:

- `install` libraries and frameworks
- `start` servers and run `tests`
- `build` and `deploy` apps, or
- `zxcvbnm` ...

## Usage

> [!NOTE]
> OS support: macOS 15+

### TLDR

```sh
sq .
```

## DEBUG

Build `sq` using sq:

```sh
# build the debug scheme
sq build

# test the debug binary
./xcode/Build/Products/Debug/sq
```

> [!IMPORTANT]
> Release candidates are built with CI (GitHub) and should be downloaded and published as `sq-macos-$(VERSION)` (ex. `sq-macos-0.1`).

#

<sub><sup>**MIT.** Copyright &copy; 2025 Bimal Bhagrath</sup></sub>
