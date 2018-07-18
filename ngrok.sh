#!/bin/bash
# -*- coding: UTF-8 -*-
#############################################
#作者网名：Sunny								#
#作者博客：www.sunnyos.com                    #
#作者QQ：327388905                           #
#作者QQ群:57914191                           #
#作者微博：http://weibo.com/2442303192        #
#############################################
# 获取当前脚本执行路径
SELFPATH=$(cd "$(dirname "$0")"; pwd)
GOOS=`go env | grep GOOS | awk -F\" '{print $2}'`
GOARCH=`go env | grep GOARCH | awk -F\" '{print $2}'`
echo '请输入一个域名'
read DOMAIN
install_yilai(){
	yum -y install zlib-devel openssl-devel perl hg cpio expat-devel gettext-devel curl curl-devel perl-ExtUtils-MakeMaker hg wget gcc gcc-c++ unzip
}
# 安装ngrok
install_ngrok(){
	uninstall_ngrok
	cd /usr/local
	if [ ! -f /usr/local/ngrok.zip ];then
		cd /usr/local/
		wget http://linux.linzhihao.com/zip/ngrok.zip
	fi
	unzip ngrok.zip
	export GOPATH=/usr/local/ngrok/
	export NGROK_DOMAIN=$DOMAIN
	cd ngrok
	openssl genrsa -out rootCA.key 2048
	openssl req -x509 -new -nodes -key rootCA.key -subj "/CN=$NGROK_DOMAIN" -days 5000 -out rootCA.pem
	openssl genrsa -out server.key 2048
	openssl req -new -key server.key -subj "/CN=$NGROK_DOMAIN" -out server.csr
	openssl x509 -req -in server.csr -CA rootCA.pem -CAkey rootCA.key -CAcreateserial -out server.crt -days 5000
	cp rootCA.pem assets/client/tls/ngrokroot.crt
	cp server.crt assets/server/tls/snakeoil.crt
	cp server.key assets/server/tls/snakeoil.key
	# 替换下载源地址
	sed -i 's#code.google.com/p/log4go#github.com/keepeye/log4go#' /usr/local/ngrok/src/ngrok/log/logger.go
	cd /usr/local/ngrok
	GOOS=$GOOS GOARCH=$GOARCH make release-server
	/usr/local/ngrok/bin/ngrokd -domain=$NGROK_DOMAIN -httpAddr=":80"
}

# 卸载ngrok
uninstall_ngrok(){
	rm -rf /usr/local/ngrok
}

# 编译客户端
compile_client(){
	cd /usr/local/ngrok/
	GOOS=$1 GOARCH=$2 make release-client
}

# 生成客户端
client(){
	echo "1、Linux 32位"
	echo "2、Linux 64位"
	echo "3、Windows 32位"
	echo "4、Windows 64位"
	echo "5、Mac OS 32位"
	echo "6、Mac OS 64位"
	echo "7、Linux ARM"

	read num
	case "$num" in
		[1] )
			compile_client linux 386
		;;
		[2] )
			compile_client linux amd64
		;;
		[3] )
			compile_client windows 386
		;;
		[4] ) 
			compile_client windows amd64
		;;
		[5] ) 
			compile_client darwin 386
		;;
		[6] ) 
			compile_client darwin amd64
		;;
		[7] ) 
			compile_client linux arm
		;;
		*) echo "选择错误，退出";;
	esac

}


echo "请输入下面数字进行选择"
echo "#############################################"
echo "------------------------"
echo "1、安装ngrok"
echo "2、安装依赖"
echo "3、生成客户端"
echo "4、卸载"
echo "5、启动服务"
echo "6、查看配置文件"
echo "------------------------"
read num
case "$num" in
	[1] )
		install_ngrok
	;;
	[2] )
		install_yilai
	;;
	[3] )
		client
	;;
	[4] )
		uninstall_ngrok
	;;
	[5] )
		echo "输入启动域名"
		read domain
		echo "启动端口"
		read port
		/usr/local/ngrok/bin/ngrokd -domain=$domain -httpAddr=":$port"
	;;
	[6] )
		echo "输入启动域名"
		read domain
		echo server_addr: '"'$domain:4443'"'
		echo "trust_host_root_certs: false"

	;;
	*) echo "";;
esac
