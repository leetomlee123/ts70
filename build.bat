call flutter clean
call flutter build apk --build-name=0.2.6 --build-number=3
call cd build/app/outputs/apk/release
call ipconfig
call python -m http.server 80


