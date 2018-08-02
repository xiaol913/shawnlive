A=`ps -ef | grep nginx | grep -v grep | wc -l`
if [ $A -eq 0 ];then
    docker-compose -f /projects/docker-compose.yml up -d
    sleep 10
    if [ `ps -ef | grep nginx | grep -v grep | wc -l` -eq 0 ];then
        #killall keepalived
	service keepalived stop
    fi
fi
