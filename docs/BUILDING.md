# Building from source

1. Clone the repository.

```sh
git clone https://github.com/ordinary-dev/nexus
```

2. Install [Zig](https://ziglang.org/download/) (tested with v0.15.2).

3. Build the program.

```sh
zig build -Doptimize=ReleaseFast
```


## Cross-compilation

If you want to compile a binary for every supported target, run the following command:

```sh
zig build -Doptimize=ReleaseFast -Denable-cross-compilation=true
```

You should get the following result:

```
zig-out/
└── bin
    ├── nexus-v0.0.1-aarch64-linux
    ├── nexus-v0.0.1-aarch64-macos
    ├── nexus-v0.0.1-aarch64-windows.exe
    ├── nexus-v0.0.1-x86_64-linux
    └── nexus-v0.0.1-x86_64-windows.exe
```
