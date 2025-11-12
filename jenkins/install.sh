#!/bin/bash

DEV_DATA=/dev-data

if [ ! -d DEV_DATA ]; then
	mkdir $DEV_DATA
fi

cd $DEV_DATA

yum install gcc automake gmp gmp-devel mpfr mpfr-devel libmpc libmpc-devel

# wget http://ftp.gnu.org/gnu/make/make-4.2.tar.gz
# tar -zxvf make-4.2.tar.gz
# cd make-4.2
# ./configure
# make && make install

# wget https://mirrors.nju.edu.cn/gnu/gcc/gcc-12.2.0/gcc-12.2.0.tar.gz
# tar -zxvf gcc-12.2.0.tar.gz
# cd gcc-12.2.0
# mkdir build
# ../configure --prefix=/usr/local/gcc-12.2.0 --enable-checking=release --enable-languages=c,c++  --disable-multilib
# make && make install

# echo "Downloading glibc-2.34"
# wget http://ftp.gnu.org/gnu/glibc/glibc-2.34.tar.xz
# echo "Doload Finished"
# tar -xvf glibc-2.34.tar.xz
# cd glibc-2.34
# mkdir -v build
# cd build 
# ../configure --prefix=/usr --disable-profile --enable-add-ons --with-headers=/usr/include --with-binutils=/usr/bin
# make && make install

sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
yum install -y jenkins-2.222.4 --nogpgcheck