#!/bin/bash
echo "******************************************************************************"
echo "@Author            : Lin"
echo "@Version           : 1.0"
echo "@Creation time     : 2023-01-18 11-15-24"
echo "@Function          : Install Mysql 5.7 or 8.0 on Linux 7"
echo "******************************************************************************"

export INPUT=$1
export DB_VRSION=8.0
export SOFTWARE_DIR=/home/weilin/Downloads/mysql/p34927567_570_Linux-x86-64
export MYSQL_FILE_NAME=mysql-advanced-5.7.40-linux-glibc2.12-x86_64.tar.gz
export NEW_MYSQL_PASSWD=V##T60*g#Pni$Jr
export APP_DIR=/app/mysql
export LOGS_DIR=/app/mysql/logs
export DATA_DIR=/app/mysql/data
export BINGLOG_DIR=/app/mysql/binlog
export REDOLOG_DIR=/app/mysql/redolog
export TMP_DIR=/app/mysql/tmp
export MYSQL_BASE_DIR=${APP_DIR}/app
export MYSQL_PORT=3306

c1() {
    RED_COLOR='\E[1;31m'
    GREEN_COLOR='\E[1;32m'
    YELLOW_COLOR='\E[1;33m'
    BLUE_COLOR='\E[1;34m'
    PINK_COLOR='\E[1;35m'
    WHITE_BLUE='\E[47;34m'
    DOWN_BLUE='\E[4;36m'
    FLASH_RED='\E[5;31m'
    RES='\E[0m'

    #Here it is judged whether the incoming parameters are not equal to 2, if not equal to 2, prompt and exit
    if [ $# -ne 2 ]; then
        echo "Usage $0 content {red|yellow|blue|green|pink|wb|db|fr}"
        exit
    fi

    case "$2" in
    red | RED)
        echo -e "${RED_COLOR}$1${RES}"
        ;;
    yellow | YELLOW)
        echo -e "${YELLOW_COLOR}$1${RES}"
        ;;
    green | GREEN)
        echo -e "${GREEN_COLOR}$1${RES}"
        ;;
    blue | BLUE)
        echo -e "${BLUE_COLOR}$1${RES}"
        ;;
    pink | PINK)
        echo -e "${PINK_COLOR}$1${RES}"
        ;;
    wb | WB)
        echo -e "${WHITE_BLUE}$1${RES}"
        ;;
    db | DB)
        echo -e "${DOWN_BLUE}$1${RES}"
        ;;
    fr | FR)
        echo -e "${FLASH_RED}$1${RES}"
        ;;
    *)
        echo -e "Please enter the specified color code：{red|yellow|blue|green|pink|wb|db|fr}"
        ;;
    esac
}

help() {
    c1 "Desc: For 5.7 and 8.0 Mysql Install" green
    echo
    c1 "Usage: InstallShellMysql [OPTIONS] OBJECT { COMMAND | help }" green
    echo
    c1 "Excute: " green
    c1 "1.chmod +x InstallShellMysql.sh" green
    echo
    c1 "OPTIONS: " green
    c1 "-v,      --DB_VRSION        Mysql Database Version" green
    c1 "-sd,     --SOFTWARE_DIR     Mysql Database SOFTWARE_DIR" green
    c1 "-ad,     --APP_DIR          Mysql Database APP_DIR" green
    c1 "-ld,     --LOGS_DIR         Mysql Database LOGS_DIR" green
    c1 "-dd,     --DATA_DIR         Mysql Database DATA_DIR" green
    c1 "-bd,     --BINGLOG_DIR      Mysql Database BINGLOG_DIR" green
    c1 "-rd,     --REDOLOG_DIR      Mysql Database REDOLOG_DIR" green
    c1 "-td,     --TMP_DIR          Mysql Database TMP_DIR" green
    c1 "-mp,     --MYSQL_PORT       Mysql Database PORT" green
    exit 0
}

echo

while [ -n "$1" ]; do #Here by judging whether $1 exists
    case $1 in
    -v | --DB_VRSION)
        DB_VRSION=$2 #$2 Is the parameter we want to output
        shift 2
        ;; # Move the parameter back by 2 and enter the judgment of the next parameter
    -sd | --SOFTWARE_DIR)
        SOFTWARE_DIR=$2
        shift 2
        ;;
    -ad | --APP_DIR)
        APP_DIR=$2
        shift 2
        ;;
    -ld | --LOGS_DIR)
        LOGS_DIR=$2
        shift 2
        ;;
    -dd | --DATA_DIR)
        DATA_DIR=$2
        shift 2
        ;;
    -bd | --BINGLOG_DIR)
        BINGLOG_DIR=$2
        shift 2
        ;;
    -rd | --REDOLOG_DIR)
        REDOLOG_DIR=$2
        shift 2
        ;;
    -td | --TMP_DIR)
        TMP_DIR=$2
        shift 2
        ;;
    -mp | --MYSQL_PORT)
        MYSQL_PORT=$2
        shift 2
        ;;
    -h | --help) help ;; # function help is called
    --)
        shift
        break
        ;; # end of options
    -*)
        echo "Error: Option '$1' is unknown, try './InstallShellMysql.sh --help'."
        exit 1
        ;;
    *) break ;;
    esac
done

#判断是否为root用户或者有root权限
CheckUserAuthority() {
    if [ $(id -u) -eq 0 ]; then
        echo
        c1 "deploy and configure mysql server" green
    else
        echo
        c1 "Please use the root or sudo to execute this script." red
        exit 1
    fi
}

#检查mysql安装文件是否存在
CheckMysqlSoftware() {
    if [ -f "${SOFTWARE_DIR}/${MYSQL_FILE_NAME}" ]; then
        echo
        c1 "mysql install file exist" green
    else
        echo
        c1 "mysql install file does not exist" red
        exit 1
    fi

}

UnMysqlFile() {
    case ${MYSQL_FILE_NAME##*.} in
    gz)
        /usr/bin/tar -xf ${SOFTWARE_DIR}/${MYSQL_FILE_NAME} -C ${MYSQL_BASE_DIR}
        ;;
    xz)
        /usr/bin/tar -xf ${SOFTWARE_DIR}/${MYSQL_FILE_NAME} -C ${MYSQL_BASE_DIR}
        ;;
    txz)
        /usr/bin/tar -xf ${SOFTWARE_DIR}/${MYSQL_FILE_NAME} -C ${MYSQL_BASE_DIR}
        ;;
    zip)
        /usr/bin/unzip ${SOFTWARE_DIR}/${MYSQL_FILE_NAME} -d ${MYSQL_BASE_DIR}
        ;;
    tar)
        /usr/bin/tar -xf ${SOFTWARE_DIR}/${MYSQL_FILE_NAME} -C ${MYSQL_BASE_DIR}
        ;;
    *)
        echo
        c1 "File compression format is not recognized" wb
        ;;
    esac
}

LinkMysqlSofware() {
    ln -f -s ${MYSQL_BASE_DIR}/${MYSQL_FILE_NAME%.*.*} ${MYSQL_BASE_DIR}/mysql
}

CreateUserAndGroup() {
    echo "******************************************************************************"
    echo "configuration mysql group and user" $(date)
    echo "******************************************************************************"

    if [ "$(grep -E -c "mysql" /etc/group)" -eq 0 ]; then
        /usr/sbin/groupadd mysql
    else
        echo
        c1 "MySQL user group already exists" green
    fi

    if [ "$(grep -E -c "mysql" /etc/passwd)" -eq 0 ]; then
        /usr/sbin/useradd -g mysql -s /sbin/nologin -M mysql
    else
        echo
        c1 "MySQL user already exists" green
    fi

}

ConfigLimit() {

    echo "******************************************************************************"
    echo "configuration mysql limit config" $(date)
    echo "******************************************************************************"

    cat >/etc/security/limits.d/99-mysql-limit.conf <<EOF
#mysql limits
mysql  soft    nproc   16384
mysql  hard    nproc   16384
mysql  soft    nofile  65536
mysql  hard    nofile  65536
mysql  soft    stack   10240
mysql  hard    stack   32768
EOF

}

ConfigOsEnv() {

    echo "******************************************************************************"
    echo "configuration mysql os env" $(date)
    echo "******************************************************************************"

    cat >>/etc/profile <<EOF
#MYSQL_HOME
export MYSQL_HOME=${MYSQL_BASE_DIR}/mysql
export PATH=\$PATH:\$MYSQL_HOME/bin
EOF
}

CreateMysqlDir() {

    echo "******************************************************************************"
    echo "create mysql dir" $(date)
    echo "******************************************************************************"

    mkdir -p "${APP_DIR}"
    mkdir -p "${MYSQL_BASE_DIR}"
    mkdir -p "${DATA_DIR}"
    mkdir -p "${LOGS_DIR}"
    mkdir -p "${BINGLOG_DIR}"
    mkdir -p "${REDOLOG_DIR}"
    mkdir -p "${TMP_DIR}"

}

Config_Mycnf5() {
    echo "******************************************************************************"
    echo "configuration mysql 5 my.cnf config" $(date)
    echo "******************************************************************************"

    MEM=$(expr $(grep MemTotal /proc/meminfo | awk '{print $2}') / 1024)
    MYSQL_MEM=$(expr $MEM \* 7 / 10)

    cat >${APP_DIR}/my.cnf <<EOF
[universe]
iops = 0
mem_limit_mb = 0
cpu_quota_percentage = 0
quota_limit_mb = 0
scsi_pr_level = 0
run_user = mysql
umask_dir = 0750
umask = 0640

[client]
port = 3306
socket = ${APP_DIR}/mysql.sock

[mysql]
prompt = "\u@ \R:\m:\s [\d]> "
no_auto_rehash
loose-skip-binary-as-hex

[mysqld]
skip_ssl
user = mysql
port = 3306
#主从复制或MGR集群中,server_id记得要不同
server_id = ${RANDOM}
#数据库字符集
character_set_server = UTF8MB4
#是否使用域名连接数据库,是则注释
skip_name_resolve = 1
#若你的MySQL数据库主要运行在境外,请务必根据实际情况调整本参数
explicit_defaults_for_timestamp=true
#log_timestamps = system #utc

#限制了同一时间在mysqld上所有session中prepared 语句的上限,默认16382
max_prepared_stmt_count = 1048576
#是否可以信任存储函数创建者
log_bin_trust_function_creators = on #   0
#自增列设置
auto_increment_increment =1 #   1
auto_increment_offset =1    #   1
#表名存储在磁盘是小写的,但是比较的时候是不区分大小写
lower_case_table_names = 1  #   0

# dir setttings
#以下根据实际情况修改
basedir = ${MYSQL_BASE_DIR}/mysql
datadir = ${DATA_DIR}
tmpdir = ${TMP_DIR}
socket = ${APP_DIR}/mysql.sock
pid_file = mysqldb.pid
log_error = ${LOGS_DIR}/error.log
slow_query_log_file = ${LOGS_DIR}/slow.log
log_bin = ${BINGLOG_DIR}/mybinlog
innodb_log_group_home_dir = ${REDOLOG_DIR} # ./
#缓存被访问过的表和索引文件,建议设置为服务器内存的75%
innodb_buffer_pool_size = ${MYSQL_MEM}M

#performance setttings
#MDL锁超时时间
lock_wait_timeout = 3600    #31536000
#打开文件的数量与操作系统限制也有关系
open_files_limit = 65535
#主线程在暂时停止响应新请求之后,可以在内部堆叠多少个请求
back_log = 1024 #-1
#客户端连接的最大并发数
max_connections = 1000  #151
#一台物理服务器只要连接 异常中断累计超过1000000次,就再也无法连接上mysqld服务
max_connect_errors = 1000000
#用于设置table高速缓存的数量,与连接数有关
table_open_cache = 4096
#表定义信息缓存,mysql源码限制最多2000个
table_definition_cache = 2000
#打开的表缓存实例的数量
table_open_cache_instances = 32
#每个连接线程被创建时,MySQL给它分配的内存大小
thread_stack = 512K
#连接分配内存
sort_buffer_size = 4M
#当join是all,index,rang或者Index_merge的时候使用的buffer
join_buffer_size = 4M
#对表进行顺序扫描的那个线程所使用的缓存区的大小
read_buffer_size = 8M
#在排序后,读取结果数据的缓冲区大小
read_rnd_buffer_size = 4M
#用来缓存批量插入数据的时候临时缓存写入数据
bulk_insert_buffer_size = 64M
#可以重新利用保存在缓存中线程的数量
thread_cache_size = 450
#交互模式下的没有操作后的超时时间
interactive_timeout = 600
#非交互模式的没有操作后的超时时间
wait_timeout = 600
#使用的各种临时表(即服务器在处理SQL语句的过程中自动创建的表)的最大允许长度
tmp_table_size = 32M
#设置用户创建的MEMORY表允许增长的最大大小,该变量的值用于计算内存表的MAX_ROWS值
max_heap_table_size = 32M

#设置在CREATE TABLE时被禁用的存储引擎
disabled_storage_engines=archive,blackhole,example,federated,memory,merge,ndb
#指定载入哪些插件
plugin_load = "rpl_semi_sync_master=semisync_master.so;rpl_semi_sync_slave=semisync_slave.so;validate_password=validate_password.so"

#connection
#GROUP_CONCAT函数返回的结果大小
group_concat_max_len=102400 #1024

#for binlog
binlog_format = row  #     row
sync_binlog = 1 #MGR环境中由其他节点提供容错性,可不设置双1以提高本地节点性能
binlog_cache_size = 4M
max_binlog_cache_size = 2G
max_binlog_size = 1G
binlog_error_action = abort_server  # abort_server
binlog_rows_query_log_events = on   #   off
log_slave_updates =on   #   off
expire_logs_days =8 #   0
binlog_cache_size =65536    #   65536(64k)
binlog_checksum =CRC32  #  CRC32
sync_binlog =1  #   1
slave_preserve_commit_order = ON    #  OFF

#slow query log
slow_query_log = on #    off
log_queries_not_using_indexes = off #    off
long_query_time = 2.000000   #    10.000000

# gtid
gtid_executed_compression_period = 1000 #    1000
gtid_mode = on  #    off
enforce_gtid_consistency = on   #    off

#innodb settings
transaction_isolation = REPEATABLE-READ
default_storage_engine =innodb # innodb
default_tmp_storage_engine =innodb # innodb
#指定系统表空间文件的路径和ibdata1文件的大小
innodb_data_file_path = ibdata1:12M:autoextend
innodb_temp_data_file_path =ibtmp1:12M:autoextend # ibtmp1:12M:autoextend
innodb_buffer_pool_filename =ib_buffer_pool # ib_buffer_pool
innodb_log_files_in_group = 16 # 2
innodb_log_file_size = 1G #如果线上环境的TPS较高,建议加大至1G以上,如果压力不大可以调小
innodb_file_per_table =on # on
innodb_online_alter_log_max_size = 4G
innodb_open_files = 65535
innodb_page_size =16k # 16384(16k)
innodb_thread_concurrency =0 # 0
innodb_read_io_threads =4 # 4
innodb_write_io_threads =4 # 4
innodb_purge_threads =4 # 4(garbage collection)
#innodb支持多个刷新buffer pool实例的脏数据的清理线程,innodb_page_cleaners即线程数量
innodb_page_cleaners=8 # 4(flush lru list)
innodb_print_all_deadlocks = on # off
innodb_deadlock_detect =on # on
innodb_lock_wait_timeout = 10
innodb_spin_wait_delay =6 # 6
innodb_autoinc_lock_mode =2 # 1
# 根据您的服务器IOPS能力适当调整# 一般配普通SSD盘的话,可以调整到 10000 - 20000
# 配置高端PCIe SSD卡的话,则可以调整的更高,比如 50000 - 80000
innodb_io_capacity = 4000
innodb_io_capacity_max = 8000
#InnoDB事务日志缓冲区的大小innodb_log_buffer_size = 32M
#InnoDB在索引创建期间用于合并排序的缓冲区大小(单位为字节)
innodb_sort_buffer_size = 67108864
#表示innodb缓冲区可以划分为多个区域,可以理解为把innodb_buffer_pool划分为多个实例,提高并发性
innodb_buffer_pool_instances = 4
innodb_flush_log_at_trx_commit = 1 #MGR环境中由其他节点提供容错性,可不设置双1以提高本地节点性能
innodb_log_files_in_group = 3
innodb_max_undo_log_size = 4G
innodb_flush_method = O_DIRECT
innodb_lru_scan_depth = 4000
innodb_rollback_on_timeout = 1


#是否需要开启ddl日志打印#
#innodb_print_ddl_logs = 1
#innodb_status_file = 1
#注意: 开启 innodb_status_output & innodb_status_output_locks 后, 可能会导致log_error文件增长较快
innodb_status_output = 0
innodb_status_output_locks = 0
innodb_adaptive_hash_index = OFF
#提高索引统计信息精确度
innodb_stats_persistent_sample_pages = 500

#innodb monitor settings
innodb_monitor_enable = "module_innodb"
innodb_monitor_enable = "module_server"
innodb_monitor_enable = "module_dml"
innodb_monitor_enable = "module_ddl"
innodb_monitor_enable = "module_trx"
innodb_monitor_enable = "module_os"
innodb_monitor_enable = "module_purge"
innodb_monitor_enable = "module_log"
innodb_monitor_enable = "module_lock"
innodb_monitor_enable = "module_buffer"
innodb_monitor_enable = "module_index"
innodb_monitor_enable = "module_ibuf_system"
innodb_monitor_enable = "module_buffer_page"
#innodb_monitor_enable = "module_adaptive_hash"

####  for performance_schema
performance_schema =on # on
performance_schema_consumer_global_instrumentation =on # on
performance_schema_consumer_thread_instrumentation =on # on
performance_schema_consumer_events_stages_current =on # off
performance_schema_consumer_events_stages_history =on # off
performance_schema_consumer_events_stages_history_long =off # off
performance_schema_consumer_statements_digest =on # on
performance_schema_consumer_events_statements_current =on # on
performance_schema_consumer_events_statements_history =on # on
performance_schema_consumer_events_statements_history_long =off # off
performance_schema_consumer_events_waits_current =on # off
performance_schema_consumer_events_waits_history =on # off
performance_schema_consumer_events_waits_history_long =off # off
performance-schema-instrument ='memory/%=COUNTED'
performance-schema-instrument = 'wait/lock/metadata/sql/mdl=ON'

#edit for temporary
sql_mode='STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION'
innodb_numa_interleave = on

[mysqldump]
quick
EOF
}

Config_Mycnf8() {
    echo "******************************************************************************"
    echo "configuration mysql 8 my.cnf config" $(date)
    echo "******************************************************************************"

    MEM=$(expr $(grep MemTotal /proc/meminfo | awk '{print $2}') / 1024)
    MYSQL_MEM=$(expr $MEM \* 7 / 10)

    cat >>${APP_DIR}/my.cnf <<EOF
EOF
}

ConfigMysqlDirPermission() {
    /usr/bin/chown -R mysql:mysql ${APP_DIR} ${LOGS_DIR} ${DATA_DIR} ${BINGLOG_DIR} ${REDOLOG_DIR} ${TMP_DIR} ${MYSQL_BASE_DIR}
}

InitMysqlServer() {
    echo "******************************************************************************"
    echo "init mysql data and start mysql server" $(date)
    echo "******************************************************************************"

    ${MYSQL_BASE_DIR}/mysql/bin/mysqld --defaults-file=${APP_DIR}/my.cnf --initialize
    {
        ${MYSQL_BASE_DIR}/mysql/bin/mysqld_safe --defaults-file=${APP_DIR}/my.cnf &
    } >>/dev/null
    sleep 5s

}

CheckMysqlService() {
    if [ ! -f "${APP_DIR}/mysql.sock" ]; then
        echo
        c1 "mysql server init success" green
    else
        echo
        c1 "mysql server init fail" red
        sleep 30s
    fi
}

ConfigMysqlPasswd() {
    OLD_MYSQL_PASSWD=$(cat ${LOGS_DIR}/error.log | grep password | head -1 | rev | cut -d ' ' -f 1 | rev)
    c1 "Please execute the following command to modify the password" db
    c1 "${MYSQL_BASE_DIR}/mysql/bin/mysql -S ${APP_DIR}/mysql.sock -u root -p\"${OLD_MYSQL_PASSWD}\"" db
    c1 "alter user 'root'@'localhost' identified by '${NEW_MYSQL_PASSWD}';" db
    c1 "exit" db
}

ConfigureBootStartup() {
    echo "${MYSQL_BASE_DIR}/mysql/bin/mysqld_safe --defaults-file=/app/mysql/my.cnf &" >>/etc/rc.local
    chmod +x /etc/rc.d/rc.local
}

Install_Mysql5() {
    CheckUserAuthority
    CheckMysqlSoftware
    CreateMysqlDir
    UnMysqlFile
    LinkMysqlSofware
    CreateUserAndGroup
    ConfigLimit
    ConfigOsEnv
    Config_Mycnf5
    ConfigMysqlDirPermission
    InitMysqlServer
    CheckMysqlService
    ConfigMysqlPasswd
    ConfigureBootStartup
}

Install_Mysql8() {
    CheckUserAuthority
    CheckMysqlSoftware
    CreateMysqlDir
    UnMysqlFile
    LinkMysqlSofware
    CreateUserAndGroup
    ConfigLimit
    ConfigOsEnv
    Config_Mycnf8
    ConfigMysqlDirPermission
    InitMysqlServer
    CheckMysqlService
    ConfigMysqlPasswd
    ConfigureBootStartup
}

Install_Mysql() {
    if [ ! -n "${INPUT}" ]; then
        echo
        c1 "Please enter the version to be installed" red
        c1 "Please to view help ./InstallShellMysql.sh -h" red
        exit 1
    else
        case ${DB_VRSION} in
        5.7)
            Install_Mysql5
            ;;
        8.0)
            Install_Mysql8
            ;;
        *)
            echo
            c1 "The version does not support automatic installation" red
            ;;
        esac
    fi
}

Install_Mysql
