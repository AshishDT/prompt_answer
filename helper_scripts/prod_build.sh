#!/bin/zsh

PS3="Select Platform for PROD environment build: "

select action in "iOS" "Android APK" "Android App Bundle" "Both iOS & Android"; do
    case $action in
      "iOS")
        echo "Building iOS PROD..."
        flutter build ipa --dart-define-from-file=environments/prod.json
        break
        ;;
      "Android APK")
        echo "Building Android APK PROD..."
        flutter build apk --dart-define-from-file=environments/prod.json
        break
        ;;
      "Android App Bundle")
        echo "Building Android App Bundle PROD..."
        flutter build appbundle --dart-define-from-file=environments/prod.json
        break
        ;;
      "Both iOS & Android")
        echo "Building iOS and Android PROD..."
        flutter build ipa --dart-define-from-file=environments/prod.json
        flutter build apk --dart-define-from-file=environments/prod.json
        flutter build appbundle --dart-define-from-file=environments/prod.json
        break
        ;;
    esac
done
