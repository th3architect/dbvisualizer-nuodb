#!/bin/bash
set -e
SCRIPT_DIR=`dirname $0`

: ${SELF_ROOT:=`dirname ${SCRIPT_DIR}`}
pushd ${SELF_ROOT} >/dev/null
SELF_ROOT=`pwd`
popd >/dev/null
: ${NUODB_HOME:="/opt/nuodb"}
: ${TESTS_ROOT:="${SELF_ROOT}/tests"}
: ${BROKER_HOST:="localhost"}
: ${BROKER_PORT:="48004"}
: ${BROKER_DOMAIN:="domain"}
: ${BROKER_DOMAIN_PASSWORD:="bird"}
: ${DATABASE_NAME:="test"}
: ${DATABASE_USER:="cloud"}
: ${DATABASE_PASSWORD="user"}
: ${DATABASE_SCHEMA="test"}
: ${DATABASE_DDL:="test_ddl.sql"}
: ${NODE_PORT_RANGE:="48010,48099"}
: ${STORAGE_DIR:="/var/opt/nuodb"}
: ${ARCHIVE_DIR:="${STORAGE_DIR}/archive"}
: ${ARCHIVE_URL:="${ARCHIVE_DIR}/${DATABASE_NAME}"}
: ${JOURNAL_DIR:="${STORAGE_DIR}/journal"}
: ${JOURNAL_URL:="${JOURNAL_DIR}/${DATABASE_NAME}"}
: ${LOGS_DIR:="/opt/nuodb/logs"}
: ${LOG_FILE:="${LOGS_DIR}/server.log"}
: ${ENGINE_ARGS:="--commit remote:1 --verbose info,warn,net,error"}

NUODB_MANAGER="java -jar ${NUODB_HOME}/jar/nuodbmanager.jar --user ${BROKER_DOMAIN} --password ${BROKER_DOMAIN_PASSWORD} --broker ${BROKER_HOST}:${BROKER_PORT} --command"
NUODB_CONSOLE="java -Dproperties=${NUODB_HOME}/etc/webapp.properties -jar ${NUODB_HOME}/jar/nuodbwebconsole.jar"

NUODB_AGENT=${NUODB_HOME}/bin/nuoagent.jar
if [ ! -e ${NUODB_AGENT} ]; then
	NUODB_AGENT=${NUODB_HOME}/jar/nuoagent.jar
fi

NUODB_ENGINE=${NUODB_HOME}/bin/nuodb

if [ ! -d "${LOGS_DIR}" ]; then
	mkdir -p "${LOGS_DIR}"
fi

SYS_LOAD_LOG=${LOGS_DIR}/stat_load.log
CPU_STAT_LOG=${LOGS_DIR}/stat_cpu.log
DISK_STAT_LOG=${LOGS_DIR}/stat_disk.log
NET_STAT_LOG=${LOGS_DIR}/stat_net.log

function broker()
{
	echo "[INFO]: Starting broker" | tee -a ${LOG_FILE}
	java -jar ${NUODB_AGENT} --broker --port ${BROKER_PORT} --domain ${BROKER_DOMAIN} --password ${BROKER_DOMAIN_PASSWORD} --verbose --bin-dir ${NUODB_HOME}/bin --port-range ${NODE_PORT_RANGE} >> ${LOGS_DIR}/${DATABASE_NAME}-broker.log 2>&1 &
	echo -e "\tExecute: java -jar ${NUODB_AGENT} --broker --port ${BROKER_PORT} --domain ${BROKER_DOMAIN} --password ${BROKER_DOMAIN_PASSWORD} --verbose --bin-dir ${NUODB_HOME}/bin --port-range ${NODE_PORT_RANGE} >> ${LOGS_DIR}/${DATABASE_NAME}-broker.log 2>&1 &"
	sleep 3
}

function startui()
{
	echo "[INFO]: Starting web console on port 8080" | tee -a ${LOG_FILE}
	${NUODB_CONSOLE} >> ${LOGS_DIR}/webconsole.log 2>&1 &
	echo -e "\tExecute: ${NUODB_CONSOLE}"
	sleep 3
}

function startte()
{
    echo "[INFO] Starting transaction engine" | tee -a ${LOG_FILE}
    TE_ARGS="--dba-user ${DATABASE_USER} --dba-password ${DATABASE_PASSWORD} ${ENGINE_ARGS} --log ${LOGS_DIR}/te.log"
    echo -e "\tExecute: ${NUODB_MANAGER} start process te host ${BROKER_HOST}:${BROKER_PORT} database ${DATABASE_NAME} options '${TE_ARGS}'"
    ${NUODB_MANAGER} "start process te host ${BROKER_HOST}:${BROKER_PORT} database ${DATABASE_NAME} options '${TE_ARGS}'" | tee -a ${LOGS_DIR}/${DATABASE_NAME}-manager.log
    sleep 1
}

function startmgr()
{
    echo "[INFO] Starting nuodb manager" | tee -a ${LOG_FILE}
    echo -e "\tExecute: java -jar ${NUODB_HOME}/jar/nuodbmanager.jar --user ${BROKER_DOMAIN} --password ${BROKER_DOMAIN_PASSWORD} --broker ${BROKER_HOST}:${BROKER_PORT}"
    java -jar ${NUODB_HOME}/jar/nuodbmanager.jar --user ${BROKER_DOMAIN} --password ${BROKER_DOMAIN_PASSWORD} --broker ${BROKER_HOST}:${BROKER_PORT} | tee -a ${LOGS_DIR}/${DATABASE_NAME}-manager.log
    sleep 1
}

function startsm()
{
    echo "[INFO] Starting archive manager and recreating database" | tee -a ${LOG_FILE}
    if [ ! -f "${ARCHIVE_URL}/1.atm" ]; then
        mkdir -p "${ARCHIVE_DIR}"
        if [ ! -d "${JOURNAL_DIR}" ]; then
            mkdir -p "${JOURNAL_DIR}"
        fi
        SM_ARGS="${ENGINE_ARGS} --log ${LOGS_DIR}/sm.log --journal enable journal-dir ${JOURNAL_URL}"
        echo -e "\tExecute: ${NUODB_MANAGER} start process sm archive ${ARCHIVE_URL} host ${BROKER_HOST}:${BROKER_PORT} database ${DATABASE_NAME} initialize yes options '${SM_ARGS}'"
        ${NUODB_MANAGER} "start process sm archive ${ARCHIVE_URL} host ${BROKER_HOST}:${BROKER_PORT} database ${DATABASE_NAME} initialize yes options '${SM_ARGS}'" | tee -a ${LOGS_DIR}/${DATABASE_NAME}-manager.log
        sleep 2
    else
        echo "[INFO] Restarting storage manager with existing archive" | tee -a ${LOGS_DIR}/${DATABASE_NAME}-manager.log
        SM_ARGS="${ENGINE_ARGS} --log ${LOGS_DIR}/sm.log --journal enable journal-dir ${JOURNAL_URL}"
        echo -e "\tExecute: ${NUODB_MANAGER} start process sm archive ${ARCHIVE_URL} host ${BROKER_HOST}:${BROKER_PORT} database ${DATABASE_NAME} initialize no options '${SM_ARGS}'"
        ${NUODB_MANAGER} "start process sm archive ${ARCHIVE_URL} host ${BROKER_HOST}:${BROKER_PORT} database ${DATABASE_NAME} initialize no options '${SM_ARGS}'" | tee -a ${LOGS_DIR}/${DATABASE_NAME}-manager.log
        sleep 2
    fi
}

function createdb()
{
    echo "[INFO] Creating db" | tee -a ${LOG_FILE}
    echo "${NUODB_HOME}/bin/nuosql --verbose info,warn ${DATABASE_NAME}@${BROKER_HOST}:${BROKER_PORT} --user ${DATABASE_USER} --password ${DATABASE_PASSWORD} --file ${SCRIPT_DIR}/${DATABASE_DDL} >> ${LOG_FILE}" | tee -a ${LOGS_DIR}/${DATABASE_NAME}-nuosql.log
    ${NUODB_HOME}/bin/nuosql --verbose info,warn ${DATABASE_NAME}@${BROKER_HOST}:${BROKER_PORT} --user ${DATABASE_USER} --password ${DATABASE_PASSWORD} --schema ${DATABASE_SCHEMA} < ${SCRIPT_DIR}/${DATABASE_DDL} >> ${LOGS_DIR}/${DATABASE_NAME}-nuosql.log 2>&1
}

function loaddb()
{
    echo "[INFO] Loading db" | tee -a ${LOG_FILE}
    nuodb-migration load --target.url=jdbc:com.nuodb://localhost/${DATABASE_NAME} --target.username=${DATABASE_USER} --target.password=${DATABASE_PASSWORD} --target.schema=${DATABASE_SCHEMA} --input.path=dump.cat
}

function startsql()
{
    echo "[INFO] Loading db" | tee -a ${LOG_FILE}
    ${NUODB_HOME}/bin/nuosql ${DATABASE_NAME}@${BROKER_HOST}:${BROKER_PORT} --user ${DATABASE_USER} --password ${DATABASE_PASSWORD}
# --schema ${DATABASE_SCHEMA}
}

function logstats()
{
    echo "[INFO] Gathering system statistics..."  | tee -a ${CPU_STAT_LOG} ${DISK_STAT_LOG} ${NET_STAT_LOG} ${LOG_FILE}

    os_type=`uname -s`
    case $os_type in
        Darwin*)
            iostat -d 10 36000 >> ${DISK_STAT_LOG} 2>&1 &
            sar -u 10 36000 >> ${CPU_STAT_LOG} 2>&1 &
            sar -n DEV 10 36000 >> ${NET_STAT_LOG} 2>&1 &
        ;;
        Linux*)
            iostat -dx 10 36000 >> ${DISK_STAT_LOG} 2>&1 &
            mpstat 10 36000 >> ${CPU_STAT_LOG} 2>&1 &
            sar -n DEV 10 36000 >> ${NET_STAT_LOG} 2>&1 &
        ;;
    esac
}

function shutdown()
{
    killall mpstat iostat sar || true
    echo "[INFO] Shutting down chorus and monitors" | tee -a ${LOG_FILE}
    echo -e "\tExecute: ${NUODB_MANAGER} shutdown database ${DATABASE_NAME}"
    ${NUODB_MANAGER} "shutdown database ${DATABASE_NAME}" | tee -a ${LOG_FILE}
    sleep 2
    NUOWEB_CONSOLE_PID=$(echo `ps -wopid,args | grep nuodbwebconsole.jar | grep -v grep` | cut -d" " -f1)
    if [ -n "${NUOWEB_CONSOLE_PID}" ]; then
        kill -TERM ${NUOWEB_CONSOLE_PID} || true
    fi
    BROKER_PID=$(echo `ps -wopid,args | grep nuoagent.jar | grep -v grep` | cut -d" " -f1)
    if [ -n "${BROKER_PID}" ]; then
        kill -TERM ${BROKER_PID} || true
    fi
}

if [ $# -eq 0 ];then
    echo -e "Usage: run_test [<op> ...]\n\tWhere op is list of: broker startte startsmm startui createdb logstats shutdown"
fi

while [ $# -gt 0 ]
do
    CMD=$1
    ${CMD}
    shift
done

