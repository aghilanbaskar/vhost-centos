#!/bin/bash
if [ "$(whoami)" != 'root' ]; then
  echo "Run this script as a root user"
  exit 1;
fi

DISTRO=$(cat /etc/*-release | grep -w NAME | cut -d= -f2 | tr -d '"')
#CentOS Linux
#Ubuntu

if [ "$(DISTRO)" != 'CentOS Linux' ]; then
  echo "Not a CentOS Distro"
  exit 1;
fi

read -p "Enter the domain name : " domain_name
if ! [[ "$domain_name" =~ (^([a-zA-Z0-9](([a-zA-Z0-9-]){0,61}[a-zA-Z0-9])?\.)+[a-zA-Z]{2,}$) ]]
then
        echo "$domain_name is a not a correct domain name"
	exit 1
fi
echo $domain_name
sudo yum -y update httpd
sudo yum -y install httpd

#add port 80 and 443 in firewall
sudo firewall-cmd --permanent --add-service=http
sudo firewall-cmd --permanent --add-service=https
sudo firewall-cmd --reload

#start apache service
sudo systemctl restart httpd

#check is apache running in server
if ! pidof httpd > /dev/null
then
        echo 'Apache not running in the server'
        exit 1
fi

#create domain required folder and files
sudo mkdir -p /var/www/$domain_name/html
sudo mkdir -p /var/www/$domain_name/log
sudo chown -R $USER:$USER /var/www/$domain_name/html
sudo chmod -R 755 /var/www/$domain_name
echo "<html>
  <head>
    <title>Welcome to $domain_name!</title>
  </head>
  <body>
    <h1>Success! The $domain_name virtual host is working!</h1>
  </body>
</html>" > /var/www/$domain_name/html/index.html


sudo mkdir -p /etc/httpd/sites-available /etc/httpd/sites-enabled

#check if site enabled not added in conf file. then add it in conf file
if ! grep -Fxq "IncludeOptional sites-enabled/*.conf" /etc/httpd/conf/httpd.conf
then
    echo "IncludeOptional sites-enabled/*.conf" >> /etc/httpd/conf/httpd.conf
fi

#virtual host file
echo "<VirtualHost *:80>
    ServerName $domain_name
    ServerAlias $domain_name
    DocumentRoot /var/www/$domain_name/html
    ErrorLog /var/www/$domain_name/log/error.log
    CustomLog /var/www/$domain_name/log/requests.log combined
</VirtualHost>" > /etc/httpd/sites-available/$domain_name.conf

sudo ln -s /etc/httpd/sites-available/$domain_name.conf /etc/httpd/sites-enabled/$domain_name.conf

#recommended apache policy for SE linux
sudo setsebool -P httpd_unified 1

#apache to log and append the file
sudo semanage fcontext -a -t httpd_log_t "/var/www/$domain_name/log(/.*)?"
sudo restorecon -R -v /var/www/$domain_name/log

#restart apache
sudo systemctl restart httpd

if pidof httpd > /dev/null
then
        echo 'Vitual host created successfully'
        echo 'Test the domain by visiting http://'$domain_name
else
        echo 'Apache restart failed'
        exit 1
fi


##########################################################################
#        Enabling HTTPS using certbot and lets encrypt                   #
##########################################################################

#check is site working
status_code=$(curl --write-out '%{http_code}' --silent -IL --output /dev/null http://$domain_name)

if [[ $status_code -ne 200 ]] ; then
  echo "Site not working, check the DNS configuration and try again"
  exit 1
fi

#install required packages
sudo yum -y install epel-release
sudo yum -y install certbot python2-certbot-apache mod_ssl

sudo certbot --apache --non-interactive --agree-tos --redirect -d $domain_name

http_scheme=$(curl --write-out '%{scheme}' --silent -IL --output /dev/null http://$domain_name)

if [[ $http_scheme == "HTTPS" ]];
then
  echo "HTTPS enabled on site $domain_name successfully"
else
  echo "HTTPS redirect not working. Something went wrong in setup"
  exit 1
fi
