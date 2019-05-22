#!/bin/bash
#安装JDK1.8+Tomcat8.5
#qinks:2019.4.8

 
base_dir=$(cd "$(dirname "$0")";pwd)
JDK_FILE=$(ls | grep jdk-*-linux-*.tar.gz)
TOMCAT_FILE=$(ls | grep apache-tomcat-*.tar.gz)

#下载JDK
download(){
    os_version=`uname -a`
    echo $os_version
    architecture="64"
    echo "$os_version" | grep -q "$architecture"

    if [ $? -eq 0 ]
    then
        # 不存在即去外网下载jdk文件
        if [ ! -f "$JDK_FILE" ]; then
            echo "您正在使用64位操作系统，为您选择64位JDK"
            curl -O ftp://nas.qinks.top:50388/linux/jdk/jdk-8u201-linux-x64.tar.gz
        fi
    else
        # 不存在即去外网下载jdk文件
        if [ ! -f "$JDK_FILE" ]; then
            echo "您正在使用32位操作系统，为您选择32位JDK"
            curl -O ftp://nas.qinks.top:50388/linux/jdk/jdk-8u201-linux-i586.tar.gz
        fi
    fi

    #下载tomcat
    if [ ! -f "$TOMCAT_FILE" ]; then
        curl -O ftp://nas.qinks.top:50388/linux/tomcat/apache-tomcat-8.5.39.tar.gz
    fi
    JDK_FILE=$(ls | grep jdk-*-linux-*.tar.gz)
    TOMCAT_FILE=$(ls | grep apache-tomcat-*.tar.gz)
}

#安装JDK
install_jdk(){
    JAVA_DIR=/usr/local/java
    JDK_DIR="jdk1.8.0_201"
    JDK_PATH="$JAVA_DIR"/"$JDK_DIR"

    tar xzf $JDK_FILE
    mkdir -p $JAVA_DIR
    mv $JDK_DIR  $JAVA_DIR

    #配置环境变量
    cp ~/.bashrc ~/.bashrc.backup.java
    if [ ! -n "$JAVA_HOME" ]; then
        echo "export JAVA_HOME=\"$JDK_PATH\"" >> ~/.bashrc
    fi
    if [ ! -n "$JRE_HOME" ]; then
        echo "export JRE_HOME=\"\$JAVA_HOME/jre\"" >> ~/.bashrc
    fi   
    if [ ! -n "$CLASSPATH" ]; then
        echo "export CLASSPATH=.:\$JDK_PATH/lib/dt.jar:\$JDK_PATH/lib/tools.jar" >> ~/.bashrc
    fi
    echo "export PATH=\$JAVA_HOME/bin:\$JRE_HOME/bin:\$PATH" >> ~/.bashrc
    source ~/.bashrc
    echo "JDK install success!"
}

#安装tomcat
install_tomcat(){
    TOMCAT_DIR=/usr/local/tomcat8

    mkdir -p $TOMCAT_DIR
    tar xzf $TOMCAT_FILE
    mv apache-tomcat-8.5.39 tomcat8
    mv tomcat8 /usr/local/

    cp ~/.bashrc ~/.bashrc.backup.tomcat8
    if [ ! -n "$TOMCAT_HOME" ]; then
        echo "export TOMCAT_HOME=$TOMCAT_DIR" >> ~/.bashrc
    fi
    if [ ! -n "$CATALINA_HOME" ]; then
        echo "export CATALINA_HOME=$TOMCAT_DIR" >> ~/.bashrc
    fi
    source ~/.bashrc
    echo "Tomact install success!"
}

main(){
    download
    if [ $? != 0 ]; then
        echo "tomcat & JDK download  failed"
        exit 1
    fi
    install_jdk
    if [ $? != 0 ]; then
        echo "JDK install failed"
        exit 1
    fi
    install_tomcat
    if [ $? != 0 ]; then
        echo "Tomcat install failed"
        exit 1
    fi
}
main
