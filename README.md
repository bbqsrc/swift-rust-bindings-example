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