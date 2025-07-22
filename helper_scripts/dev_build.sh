#!/bin/zsh

PS3="Select Platform for DEV environment build: "

select action in "iOS" "Android APK" "Android App Bundle" "Both iOS & Android"; do
    case $action in
      "iOS")
        echo "Building iOS DEV..."
        flutter build ipa --dart-define-from-file=environments/dev.json
        break
        ;;
      "Android APK")
        echo "Building Android APK DEV..."
        flutter build apk --dart-define-from-file=environments/dev.json
        break
        ;;
      "Android App Bundle")
        echo "Building Android App Bundle DEV..."
        flutter build appbundle --dart-define-from-file=environments/dev.json
        break
        ;;
      "Both iOS & Android")
        echo "Building iOS and Android DEV..."
        flutter build ipa --dart-define-from-file=environments/dev.json
        flutter build apk --dart-define-from-file=environments/dev.json
        flutter build appbundle --dart-define-from-file=environments/dev.json
        break
        ;;
    esac
done
