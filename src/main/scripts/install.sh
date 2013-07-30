#!/bin/sh

SCRIPT_DIR=`dirname $0`

: ${SELF_ROOT:=`dirname ${SCRIPT_DIR}`}
pushd ${SELF_ROOT} >/dev/null
SELF_ROOT=`pwd`
popd >/dev/null

[ -z "${INSTALLER_HOME}" ] && INSTALLER_HOME=`cd "${SELF_ROOT}" >/dev/null; pwd`

os_type=`uname -s`
case $os_type in
    Darwin*)
        if [ -d /Applications/DbVisualizer.app/Contents/Resources/app/ ]; then
            : ${DBVISUALIZER_HOME:="/Applications/DbVisualizer.app/Contents/Resources/app/"}
        fi
    ;;
    Linux*)
        export JAVA_HOME=$(readlink -f /usr/bin/java | sed "s:bin/java::")
    ;;
esac

mkdir -p ${DBVISUALIZER_HOME}/jdbc/nuodb/
if [ -e /opt/nuodb/jar/nuodbjdbc.jar ]; then
    cp /opt/nuodb/jar/nuodbjdbc.jar ${DBVISUALIZER_HOME}/jdbc/nuodb/nuodbjdbc.jar
else
    cp ${INSTALLER_HOME}/lib/nuodb-jdbc.jar ${DBVISUALIZER_HOME}/jdbc/nuodb/nuodbjdbc.jar
fi

cp -R ${INSTALLER_HOME}/resources/* ${DBVISUALIZER_HOME}/resources/
