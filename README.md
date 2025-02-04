# Jellywallet extension

You can find the latest version of Jellywallet on [our official website](https://jellywallet.io/).

Jellywallet supports Google Chrome, and Chromium-based browsers. We recommend using the latest available browser version.

## Getting Started

1. Install flutter from [official site](https://docs.flutter.dev/get-started/install):

2. Clone this repository:

3. Go to directory with app and install dependencies:

        flutter pub get

## Build
Make build for upload to chrome extensions

    flutter build web --csp --web-renderer html  --no-sound-null-safety

## Deploy
1. In Chrome, open chrome://extensions/
2. Click + Developer mode
3. Click Load unpacked extension…
4. Navigate to the extension’s folder `/build/web` and click OK

Where `/build/web` is directory with ready extension

## Debug
    flutter run -d chrome --no-sound-null-safety

## Build JS
    cd web
    npm install
    npm run build

## Test Ledger Speculos
### IMPORTANT
Check out this stackoverflow post make sure your chrome starts without security checks!
https://stackoverflow.com/questions/65630743/how-to-solve-flutter-web-api-cors-error-only-with-dart-code

1- Go to flutter\bin\cache and remove a file named: flutter_tools.stamp

2- Go to flutter\packages\flutter_tools\lib\src\web and open the file chrome.dart.

3- Find '--disable-extensions'

4- Add '--disable-web-security'

Start the Virtual Machine (TODO: Make a public virtual machine!)
Run Speculos using this command
   
   cd ~/speculos
   SPECULOS_APPNAME=DeFiChain:2.3.1 ./speculos.py ~/ledger-app-builder/app-bitcoin-new/bin/app.elf --apdu-port 9999  -s "SEED_PHRASE" 

Change the adapter in the ledger-base.ts to use the SpeculosTransport by uncommenting the code and change the ip address.
Rebuild, and reload the app. 

## License & Disclaimer

By using `Jellywallet extension` (this repo), you (the user) agree to be bound by [the terms of this license](LICENSE).
