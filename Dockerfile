FROM openjdk:11
LABEL MAINTAINER ANAM AHMED
LABEL VERSION 0.4
LABEL AUTHOR_EMAIL me@anam.co
RUN curl -sL https://sentry.io/get-cli/ | bash
RUN curl -sL https://deb.nodesource.com/setup_19.x | bash -
RUN apt-get update && apt-get -y install nodejs unzip ruby-full make gcc g++
RUN apt-get update && apt-get install -y openjdk-11-jdk
# ENV VARIABLES
ENV SDK_URL="https://dl.google.com/android/repository/commandlinetools-linux-9477386_latest.zip" \
    ANDROID_HOME="/usr/local/android-sdk" \
    ANDROID_VERSION=33\
    ANDROID_BUILD_TOOLS_VERSION=30.0.2\
    GRADLE_VERSION=7.2\
    MAVEN_VERSION=3.8.8
WORKDIR ${ANDROID_HOME}
# GET SDK MANAGER
RUN curl -sL -o android.zip ${SDK_URL} && unzip android.zip && rm android.zip
RUN yes | $ANDROID_HOME/cmdline-tools/bin/sdkmanager --sdk_root=$ANDROID_HOME --licenses
# ANDROID SDK AND PLATFORM
RUN $ANDROID_HOME/cmdline-tools/bin/sdkmanager --sdk_root=$ANDROID_HOME --update
RUN $ANDROID_HOME/cmdline-tools/bin/sdkmanager --sdk_root=$ANDROID_HOME "build-tools;${ANDROID_BUILD_TOOLS_VERSION}" \
    "platforms;android-${ANDROID_VERSION}" \
    "platform-tools"
# GRADLE
RUN curl -sL -o gradle.zip https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip &&\
    mkdir /opt/gradle && unzip -d /opt/gradle gradle.zip && rm gradle.zip
# MAVEN
RUN curl -sL -o maven.zip https://dlcdn.apache.org/maven/maven-3/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.zip && \
    mkdir /opt/maven && unzip -d /opt/maven maven.zip && rm maven.zip
# ADD PATH TO BASHRC
RUN export PATH=$PATH:$ANDROID_HOME/emulator\
    && export PATH=$PATH:$ANDROID_HOME/tools\
    && export PATH=$PATH:$ANDROID_HOME/tools/bin\
    && export PATH=$PATH:/opt/gradle/gradle-${GRADLE_VERSION}/bin\
    && export PATH=$PATH:/opt/maven/apache-maven-${MAVEN_VERSION}/bin\
    && echo PATH=$PATH:$ANDROID_HOME/platform-tools>>/etc/bash.bashrc
# INSTALL BUNDLER GEM
RUN gem install bundler
# INSTALL YARN, REACT NATIVE CLI, CREATE-REACT-NATIVE-APP
RUN npm install -g yarn && yarn global add react-native-cli create-react-native-app
# VOLUMES
VOLUME ["/app","/root/.gradle"]
# CHANGE WORKDIR
WORKDIR /app
# REACT NATIVE PORT AND ADB PORT
EXPOSE 8081 5555
# DEFAULT REACT NATIVE COMMAND
CMD react-native
