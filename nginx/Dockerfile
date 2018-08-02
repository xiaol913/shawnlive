FROM nginx:latest 
MAINTAINER Shawn Gao <xxlangdou@gmail.com>
ENV TZ "Asia/Shanghai"


# Add custom conf files
COPY ./*_nginx.conf /etc/nginx/conf.d/
COPY ./nginx.conf /etc/nginx/
COPY ./index.html /usr/share/nginx/html/
