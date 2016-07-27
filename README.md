# Android emulator

This repository contains a failed effort of running Appium tests with an android emulator in a single container.
The dockerfile and start script installs and starts android emulator and Appium server, and pulls latest version of Instapp and builds Instapp apk.

Appium was unable to control the emulator while running tests in the container.

Setup used in Dockerfile has alot of dependencies that are not listed here.

## Install Android SDK
```shell
cd /opt
wget https://dl.google.com/android/android-sdk_r24.4.1-linux.tgz
tar -xvzf android-sdk_r24.4.1-linux.tgz
rm android-sdk_r24.4.1-linux.tgz
ANDROID_HOME=/opt/android-sdk-linux
PATH=$PATH:$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools
# Install some needed SDKs
echo y | android update sdk --no-ui --all --filter platform-tools,build-tools-23.0.2,tools,android-22,android-16,android-19,android-23,sys-img-armeabi-v7a-android-22 --force
# Create a device named android
echo | android create avd --force -n android -t android-22 --abi armeabi-v7a
# Start headless emulator
adb start-server
emulator -avd android -noaudio -no-window -gpu off -verbose -engine classic
```
Running a x86 system emulator requires hardware acceleration and if used in a docker container the container must be ran with --priviliged label.

## Install Appium
```shell
git clone --branch v1.4.16 git://github.com/appium/appium.git
cd appium
./reset.sh --android --verbose
# Start Appium server
node .
```

## Robot framework Appium library
```shell
pip install robotframework
pip install robotframework-appiumlibrary
```

Using Appium library in a Robot test suite:

```
*** Settings ***
Library    AppiumLibrary 

*** Variables ***
${REMOTE_URL}     http://localhost:4723/wd/hub

*** Keywords ***
TestStart
    Open Application    ${REMOTE_URL}  platformName=Android    deviceName=<NAME_OF_DEVICE>   app=<PATH_TO_APK> 
```

[Appium library documentation](http://jollychang.github.io/robotframework-appiumlibrary/doc/AppiumLibrary.html)

