#!/usr/bin/env bash
set -eoux pipefail

current_sdk=""
current_triple=""
current_arch=""

min_macos_version="10.10"
min_ios_version="8.0"

rawname="example_sys"
modname="Example"

update_sdk () {
    case $1 in
        aarch64-apple-darwin)
            current_sdk=$(xcrun --show-sdk-path --sdk macosx)
            current_triple="arm64-apple-macosx${min_macos_version}" # $(xcrun --show-sdk-version --sdk macosx)"
            current_arch="arm64"
            ;;
        aarch64-apple-ios)
            current_sdk=$(xcrun --show-sdk-path --sdk iphoneos)
            current_triple="arm64-apple-ios${min_ios_version}"
            current_arch="arm64"
            ;;
        aarch64-apple-ios-sim)
            current_sdk=$(xcrun --show-sdk-path --sdk iphonesimulator)
            current_triple="arm64-apple-ios${min_ios_version}-simulator"
            current_arch="arm64"
            ;;
        x86_64-apple-darwin)
            current_sdk=$(xcrun --show-sdk-path --sdk macosx)
            current_triple="x86_64-apple-macosx${min_macos_version}"
            current_arch="x86_64"
            ;;
        x86_64-apple-ios)
            current_sdk=$(xcrun --show-sdk-path --sdk iphonesimulator)
            current_triple="x86_64-apple-ios${min_ios_version}-simulator"
            current_arch="x86_64"
            ;;
    esac
}

rm -rf aarch64-apple-* x86_64-apple-* ios-simulator macos-universal ${modname}.xcframework

cargo pod build

for target in {aarch64-apple-darwin,aarch64-apple-ios,aarch64-apple-ios-sim,x86_64-apple-darwin,x86_64-apple-ios}; do
    mkdir -p ${target}/${modname}.framework/{PrivateHeaders,Modules}
    cp bindings.h ${target}/${modname}.framework/PrivateHeaders/${rawname}.h
    cp dist/${target}/lib${rawname}.a ${target}/${modname}.framework/${modname}
    echo "framework module ${modname} {
    export *
}" > ${target}/${modname}.framework/Modules/module.modulemap
    echo "framework module ${modname}_Private {
  header \"${rawname}.h\"
  link \"${modname}\"
}
" > ${target}/${modname}.framework/Modules/module.private.modulemap
done

for target in {aarch64-apple-darwin,aarch64-apple-ios,aarch64-apple-ios-sim,x86_64-apple-darwin,x86_64-apple-ios}; do
    update_sdk $target

    swiftc -emit-library -emit-object -static \
        -sdk $current_sdk \
        -target $current_triple \
        -module-name ${modname} \
        -F ${target} \
        -o ${modname}.o lib.swift

    swiftc -emit-module -static -sdk $current_sdk \
        -enable-library-evolution \
        -emit-parseable-module-interface \
        -target $current_triple \
        -module-name ${modname} \
        -F ${target} \
        lib.swift
    
    cp dist/${target}/*.a lib${modname}.a
    ar q lib${modname}.a ${modname}.o

    # Make Swift framework
    mkdir -p ${target}/${modname}.framework/Modules/${modname}.swiftmodule
    mv lib${modname}.a ${target}/${modname}.framework/${modname}
    rm ${modname}.o ${modname}.private.swiftinterface
    for ext in {swiftdoc,swiftmodule,swiftsourceinfo,abi.json,swiftinterface}; do
        mv ${modname}.${ext} ${target}/${modname}.framework/Modules/${modname}.swiftmodule/${current_arch}.${ext}
    done
done

mkdir -p ios-simulator/${modname}.framework/Modules
lipo -create \
    aarch64-apple-ios-sim/${modname}.framework/${modname} \
    x86_64-apple-ios/${modname}.framework/${modname} \
    -output ios-simulator/${modname}.framework/${modname}
cp -r aarch64-apple-ios-sim/${modname}.framework/Modules/{${modname}.swiftmodule,*.modulemap} \
    x86_64-apple-ios/${modname}.framework/Modules/${modname}.swiftmodule \
    ios-simulator/${modname}.framework/Modules/
cp -r  aarch64-apple-ios-sim/${modname}.framework/PrivateHeaders ios-simulator/${modname}.framework/

mkdir -p macos-universal/${modname}.framework/Modules
lipo -create \
    aarch64-apple-darwin/${modname}.framework/${modname} \
    x86_64-apple-darwin/${modname}.framework/${modname} \
    -output macos-universal/${modname}.framework/${modname}
cp -r aarch64-apple-darwin/${modname}.framework/Modules/{${modname}.swiftmodule,*.modulemap} \
    x86_64-apple-darwin/${modname}.framework/Modules/${modname}.swiftmodule \
    macos-universal/${modname}.framework/Modules/
cp -r aarch64-apple-darwin/${modname}.framework/PrivateHeaders macos-universal/${modname}.framework/

xcodebuild -create-xcframework \
    -framework ios-simulator/${modname}.framework \
    -framework macos-universal/${modname}.framework \
    -framework aarch64-apple-ios/${modname}.framework \
    -output ${modname}.xcframework

swiftc -F Example.xcframework/macos-arm64_x86_64 example.swift -o example

./example