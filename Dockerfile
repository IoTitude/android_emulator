FROM debian:latest
RUN rm /bin/sh && ln -s /bin/bash /bin/sh

RUN apt-get update && \
    apt-get install -y wget git mesa-utils build-essential m4 python-setuptools ruby texinfo libbz2-dev libcurl4-openssl-dev libexpat-dev libncurses-dev zlib1g-dev sudo nodejs screen curl redir python python-pip make g++ lib32z1 zip unzip openjdk-7-jdk libc6-i386 lib32stdc++6 && \
    apt-get clean && \
    apt-get autoclean && \
rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ENV JAVA_HOME /usr/lib/jvm/java-7-openjdk-amd64
ENV PATH $PATH:$JAVA_HOME
ENV ANT_HOME /home/work/apache-ant-1.9.7
ENV PATH $PATH:$ANT_HOME/bin
ENV MAVEN_HOME /home/work/apache-maven-3.3.9
ENV PATH $PATH:$MAVEN_HOME/bin
ENV ANDROID_HOME /opt/android-sdk-linux
ENV PATH $PATH:$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools

RUN mkdir -m 0750 /.android
ADD files/insecure_shared_adbkey /.android/adbkey
ADD files/insecure_shared_adbkey.pub /.android/adbkey.pub
ADD files/start.sh /start.sh

EXPOSE 5555
EXPOSE 4723

RUN wget -qO- "http://dl.google.com/android/android-sdk_r24.3.4-linux.tgz" | tar -zx -C /opt && \
echo y | android update sdk --no-ui --all --filter platform-tools,build-tools-23.0.2,tools,android-22,android-16,android-19,android-23,sys-img-armeabi-v7a-android-22 --force
RUN echo | android create avd --force -n android -t android-22 --abi armeabi-v7a

RUN mkdir -p /home/work
WORKDIR /home/work
RUN wget http://www.eu.apache.org/dist/ant/binaries/apache-ant-1.9.7-bin.tar.gz

RUN tar -xvzf apache-ant-1.9.7-bin.tar.gz
RUN rm apache-ant-1.9.7-bin.tar.gz

RUN chmod 755 -R /home/work/apache-ant-1.9.7
WORKDIR /home/work/apache-ant-1.9.7
RUN ant -f fetch.xml -Ddest=system

WORKDIR /home/work

RUN wget http://www.us.apache.org/dist/maven/maven-3/3.3.9/binaries/apache-maven-3.3.9-bin.tar.gz
RUN tar -xvzf apache-maven-3.3.9-bin.tar.gz
RUN rm apache-maven-3.3.9-bin.tar.gz

RUN gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3
RUN \curl -sSL https://get.rvm.io | bash -s stable --ruby

RUN sed -i "/env bash/c\  #!/usr/bin/bash/" /usr/local/rvm/scripts/rvm

RUN source /usr/local/rvm/scripts/rvm

RUN gem update --system
RUN gem install --no-rdoc --no-ri bundler
RUN gem update
RUN gem cleanup

RUN useradd --system -m -s /bin/bash linuxbrew
USER linuxbrew
ENV PATH $PATH:~/.linuxbrew/bin:/usr/sbin:/usr/bin:/sbin:/bin  
RUN source /usr/local/rvm/scripts/rvm
RUN echo | ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Linuxbrew/linuxbrew/go/install)"

USER root
WORKDIR /home/work
RUN chown root -R /home/linuxbrew/.linuxbrew
ENV PATH $PATH:/home/linuxbrew/.linuxbrew/bin
RUN brew doctor
RUN brew update
RUN brew install node

RUN node --version
RUN npm --version
RUN npm install -g grunt grunt-cli

RUN npm install -g cordova ionic

RUN git clone --branch v1.4.16 git://github.com/appium/appium.git

WORKDIR /home/work/appium

RUN ./reset.sh --android --verbose

RUN pip install robotframework
RUN pip install robotframework-appiumlibrary

RUN chmod +x /start.sh
CMD ["/start.sh"]
