# Nexus - Browser homepage generator

![Screenshot](docs/screenshot-1.avif)

## Getting started

1. [Download the executable](https://github.com/ordinary-dev/nexus/releases/latest) or [build from source](docs/BUILDING.md).
2. Edit .yaml file with links (see [LINKS.yaml](LINKS.yaml)).
3. Generate your homepage.

```sh
./zig-out/bin/nexus -o index.html LINKS.yaml
```


## Features

- Local first: no internet or server required. Your data is always under your control.
