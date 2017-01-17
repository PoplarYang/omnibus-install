#!/bin/bash
#
# modify by hiyang @ 2016-12-19
#


# . ./include/download.sh
checkDownload() {
  mirrorLink=http://mirrors.linuxeye.com/oneinstack/src
  pushd ${oneinstack_dir}/src
    # tomcat
    case "${Tomcat_version}" in
      1)
        echo "Download tomcat 8..."
        src_url=http://mirrors.linuxeye.com/apache/tomcat/v${tomcat8_version}/apache-tomcat-${tomcat8_version}.tar.gz && Download_src
        src_url=http://mirrors.linuxeye.com/apache/tomcat/v${tomcat8_version}/catalina-jmx-remote.jar && Download_src
        ;;
      2)
        echo "Download tomcat 7..."
        src_url=http://mirrors.linuxeye.com/apache/tomcat/v${tomcat7_version}/apache-tomcat-${tomcat7_version}.tar.gz && Download_src
        src_url=http://mirrors.linuxeye.com/apache/tomcat/v${tomcat7_version}/catalina-jmx-remote.jar && Download_src
        ;;
      3)
        echo "Download tomcat 6..."
        src_url=http://mirrors.linuxeye.com/apache/tomcat/v${tomcat6_version}/apache-tomcat-${tomcat6_version}.tar.gz && Download_src
        src_url=http://mirrors.linuxeye.com/apache/tomcat/v${tomcat6_version}/catalina-jmx-remote.jar && Download_src
        ;;
    esac

    if [[ "${JDK_version}"  =~ ^[1-3]$ ]]; then
      case "${JDK_version}" in
        1)
          echo "Download JDK 1.8..."
          JDK_FILE="jdk-$(echo ${jdk18_version} | awk -F. '{print $2}')u$(echo ${jdk18_version} | awk -F_ '{print $NF}')-linux-${SYS_BIG_FLAG}.tar.gz"
          ;;
        2)
          echo "Download JDK 1.7..."
          JDK_FILE="jdk-$(echo ${jdk17_version} | awk -F. '{print $2}')u$(echo ${jdk17_version} | awk -F_ '{print $NF}')-linux-${SYS_BIG_FLAG}.tar.gz"
          ;;
        3)
          echo "Download JDK 1.6..."
          JDK_FILE="jdk-$(echo ${jdk16_version} | awk -F. '{print $2}')u$(echo ${jdk16_version} | awk -F_ '{print $NF}')-linux-${SYS_BIG_FLAG}.bin"
          ;;
      esac
      # start download...
      src_url=http://mirrors.linuxeye.com/jdk/${JDK_FILE} && Download_src
    fi
  popd
}
