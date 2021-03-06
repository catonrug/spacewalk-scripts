#!/bin/bash

#open 80 and 443 into firewall
firewall-cmd --permanent --add-service=http
firewall-cmd --permanent --add-service=https
firewall-cmd --reload

#update system
yum update -y

#install GPG key for Spacewalk repository
cd /etc/pki/rpm-gpg
curl -s -O http://yum.spacewalkproject.org/RPM-GPG-KEY-spacewalk-2015
rpm --import RPM-GPG-KEY-spacewalk-2015

#install GPG key for EPEL repository
cd /etc/pki/rpm-gpg
curl -s -O https://dl.fedoraproject.org/pub/epel/RPM-GPG-KEY-EPEL-7
rpm --import RPM-GPG-KEY-EPEL-7

#install GPG key for Java packages repository
cd /etc/pki/rpm-gpg
curl -s https://copr-be.cloud.fedoraproject.org/results/@spacewalkproject/java-packages/pubkey.gpg > java-packages.gpg
rpm --import java-packages.gpg

#install Spacewalk repository
rpm -Uvh https://copr-be.cloud.fedoraproject.org/results/@spacewalkproject/spacewalk-2.8/epel-7-x86_64/00736372-spacewalk-repo/spacewalk-repo-2.8-11.el7.centos.noarch.rpm

#install EPEL repository
rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm

#install Java packages repository
cd /etc/yum.repos.d
curl -s -O https://copr.fedorainfracloud.org/coprs/g/spacewalkproject/java-packages/repo/epel-7/group_spacewalkproject-java-packages-epel-7.repo

#install postgresql database server
yum -y install spacewalk-setup-postgresql

#install spacewalk using postgresql as database server
yum -y install spacewalk-postgresql

#create spacewalk unattanded installation file into root home direcotry
cat > /root/spacewalk-answer-file << EOF
admin-email = root@localhost
ssl-set-cnames = spacewalk2
ssl-set-org = Spacewalk Org
ssl-set-org-unit = spacewalk
ssl-set-city = My City
ssl-set-state = My State
ssl-set-country = US
ssl-password = spacewalk
ssl-set-email = root@localhost
ssl-config-sslvhost = Y
db-backend=postgresql
db-name=spaceschema
db-user=spaceuser
db-password=spacepw
db-host=localhost
db-port=5432
enable-tftp=Y
EOF

#enable postgresql at startup
systemctl enable postgresql

#create first postgresql contend.. directories and stuff
postgresql-setup initdb

#start postgresql
systemctl start postgresql

#spacewalk silent install
spacewalk-setup --answer-file=/root/spacewalk-answer-file
