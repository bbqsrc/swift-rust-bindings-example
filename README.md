## Prereqs:

- You're on macOS with Xcode
- You have Rust (https://rustup.rs)
- You have `cargo-cocoapods` (`cargo install --git https://github.com/bbqsrc/cargo-cocoapods`)

## Anatomy:

- `src/lib.rs` contains the Rust code
- `bindings.h` contains the C interface to the Rust code
- `lib.swift` describes the safe Swift interface to the Rust code. It is imported as `Example_Private`

## Process:

`run.sh` does a bunch of crazy things:

- Use `cargo-cocoapods` to build the Rust `example_sys` static library for all relevant targets
- Creates the stubs of an `Example.framework` for each of the targets, creating an empty modulemap and a private modulemap specifying to link against `Example` and pointing to the header that is now copied to the `PrivateHeader` directory
- Iterates over each triple, building the safe wrapper directly with `swiftc`
- The absolute crime: taking the Rust `.a` file and embedding the compiled Swift static module's `.o` file into it, and placing it into the framework directory
- Copying all the related Swift module metadata into the `Modules` directory of the framework
- Using `lipo` to merge the various architectures on the various platforms so we can do the next thing
- Creating an `.xcframework` with `xcodebuild`

At the end of this, you have a self-contained, static, redistributable binary library for all relevant Apple platforms.

## Example:

```
$ swiftc -F Example.xcframework/macos-arm64_x86_64 example.swift -o example
$ otool -L ./example 
./example:
        /usr/lib/libSystem.B.dylib (compatibility version 1.0.0, current version 1319.100.3)
        /usr/lib/libc++.1.dylib (compatibility version 1.0.0, current version 1500.65.0)
        /usr/lib/swift/libswiftCore.dylib (compatibility version 1.0.0, current version 5.8.0)
$  ./example
Hello Rust!

```

If you run `run.sh`, you should see this .xcframework created, amongst other things:

```
Example.xcframework
├── Info.plist
├── ios-arm64
│   └── Example.framework
│       ├── Example
│       ├── Modules
│       │   ├── Example.swiftmodule
│       │   │   ├── arm64.abi.json
│       │   │   ├── arm64.swiftdoc
│       │   │   ├── arm64.swiftinterface
│       │   │   └── arm64.swiftsourceinfo
│       │   ├── module.modulemap
│       │   └── module.private.modulemap
│       └── PrivateHeaders
│           └── example_sys.h
├── ios-arm64_x86_64-simulator
│   └── Example.framework
│       ├── Example
│       ├── Modules
│       │   ├── Example.swiftmodule
│       │   │   ├── arm64.abi.json
│       │   │   ├── arm64.swiftdoc
│       │   │   ├── arm64.swiftinterface
│       │   │   ├── arm64.swiftsourceinfo
│       │   │   ├── x86_64.abi.json
│       │   │   ├── x86_64.swiftdoc
│       │   │   ├── x86_64.swiftinterface
│       │   │   └── x86_64.swiftsourceinfo
│       │   ├── module.modulemap
│       │   └── module.private.modulemap
│       └── PrivateHeaders
│           └── example_sys.h
└── macos-arm64_x86_64
    └── Example.framework
        ├── Example
        ├── Modules
        │   ├── Example.swiftmodule
        │   │   ├── arm64.abi.json
        │   │   ├── arm64.swiftdoc
        │   │   ├── arm64.swiftinterface
        │   │   ├── arm64.swiftsourceinfo
        │   │   ├── x86_64.abi.json
        │   │   ├── x86_64.swiftdoc
        │   │   ├── x86_64.swiftinterface
        │   │   └── x86_64.swiftsourceinfo
        │   ├── module.modulemap
        │   └── module.private.modulemap
        └── PrivateHeaders
            └── example_sys.h
```