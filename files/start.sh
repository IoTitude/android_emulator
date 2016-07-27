#!/bin/bash
cd /home/work
git clone https://github.com/IoTitude/Instapp.git  Instapp
cd Instapp
git fetch --tags
latestTag=$(git describe --tags `git rev-list --tags --max-count=1`)
git checkout $latestTag
source setup.sh
ionic build android
echo 'Cloning test repo...'
mkdir -p /home/test
cd /home/test
git init
git remote add -f origin https://github.com/Bowsse/joo.git
git config core.sparseCheckout true
echo "robot.txt" >> .git/info/sparse-checkout
git pull origin master
adb start-server
screen -dm emulator -avd android -noaudio -no-window -gpu off -verbose -engine classic
cd /home/work/appium
screen -dm node .
cd /home/test
echo 'Starting robot tests...'
robot /home/test/robot.txt
