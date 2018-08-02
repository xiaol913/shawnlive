#!/bin/bash

echo '========== Start to building =========='
sleep 2

echo '===== creating network ====='
sleep 2
echo 1 > /proc/sys/net/ipv4/ip_forward
docker network create shawnlive
cd sentry
mkdir -p data/{sentry,postgres}

echo '===== building sentry images(1) ====='
sleep 2
docker-compose build
docker-compose run --rm web config generate-secret-key | tail -1

echo '===== changing the .yml key ====='
sleep 2
echo "Please input the last column of last step"
read key
sed -i "/SENTRY_SECRET_KEY:/{s/''/'$key'/}" ./docker-compose.yml

echo '===== building sentry images(2) ====='
sleep 2
/bin/expect << -EOF
    set timeout 30
    spawn docker-compose run --rm web upgrade 
    expect {
        "Would you like to create a user account now*" { send y\r; exp_continue }
        "Email*" { send "1@1.com\r"; exp_continue } 
        "Password*" { send 123456\r; exp_continue }
        "Repeat for confirmation*" { send 123456\r; exp_continue }
        "Should this user be a superuser*" { send y\r }
    }
    expect eof
-EOF

echo '===== check sentry ====='
echo 'Did you create a user?("yes/no")'
read res
while [ $res != 'yes' ]; do
    if [ $res == 'no' ]; then
        echo 'Did upgrade finish?'
        read fin
        while [ $fin != 'yes' ]; do
            /bin/expect << -EOF
    set timeout 30
    spawn docker-compose run --rm web upgrade 
    expect {
        "Would you like to create a user account now*" { send y\r; exp_continue }
        "Email*" { send "1@1.com\r"; exp_continue } 
        "Password*" { send 123456\r; exp_continue }
        "Repeat for confirmation*" { send 123456\r; exp_continue }
        "Should this user be a superuser*" { send y\r }
    }
    expect eof
-EOF
            echo 'Did upgrade finish?'
            read fin
        done
        echo 'please input "from sentry.models import Project'
        echo 'from sentry.receivers.core import create_default_projects'
        echo 'create_default_projects([Project])"'
        sleep 5
        docker-compose run --rm web shell
        /bin/expect << -EOF
    spawn docker-compose run --rm web createuser
    expect {
        "Would you like to create a user account now*" { send y\r; exp_continue }
        "Email*" { send "1@1.com\r"; exp_continue } 
        "Password*" { send 123456\r; exp_continue }
        "Repeat for confirmation*" { send 123456\r; exp_continue }
        "Should this user be a superuser*" { send y\r }
    }
    expect eof
-EOF
        res='yes'
    else
        echo 'please input "yes" or "no"!'
        read res
    fi
done

echo '===== start sentry ====='
sleep 2
docker-compose up -d

echo '===== building web server images ====='
sleep 2
cd ../
docker-compose build
docker-compose up -d

echo '========== End of building =========='
