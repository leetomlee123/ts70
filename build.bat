call flutter clean
call flutter build apk --target-platform android-arm64 --split-per-abi --build-name=0.4.8 --build-number=3
call cd build/app/outputs/apk/release
call ipconfig
call python -m http.server 80

