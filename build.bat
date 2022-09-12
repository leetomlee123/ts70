call flutter clean
call flutter build apk --obfuscate --split-debug-info=HLQ_Struggle --target-platform android-arm64 --split-per-abi --build-name=0.0.3 --build-number=3
call cd build/app/outputs/apk/release
call ipconfig
call python -m http.server 80


