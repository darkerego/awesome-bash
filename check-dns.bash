#!/bin/bash
##################################################################################
# Customized script to make sure dnscrypt is always working.
# For debian-esc systems
# Assumes dnscrypt-proxy is running on localhost:40 and unbound should run
# on 127.0.1.1:53, which should also be in your /etc/resolv.conf
##################################################################################
export PATH='/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin'
DNSC='/etc/systemd/system/dnscrypt-autoinstall'

verbose(){
return 0
}


check_DNSC(){
# Fix configuration
echo 'DNSCRYPT_LOCALIP=127.0.0.1
DNSCRYPT_LOCALIP2=127.0.0.2
DNSCRYPT_LOCALPORT=40
DNSCRYPT_LOCALPORT2=40
DNSCRYPT_USER=dnscrypt
DNSCRYPT_RESOLVER=d0wn-nl-ns2
DNSCRYPT_RESOLVER2=d0wn-nl-ns1' > "${DNSC}.conf"
service dnscrypt-autoinstall stop ; service dnscrypt-autoinstall start;return $?
}


check_unbound(){
echo 'include: "/etc/unbound/unbound.conf.d/*.conf"
server:
    auto-trust-anchor-file: "/var/lib/unbound/root.key"
server:
    logfile: "/var/log/unbound.log"
    log-time-ascii: yes
    module-config: "iterator"
    do-not-query-localhost: no
    interface: 127.0.1.1
    #interface: 10.8.0.1 #for a vpn or other dns server for clients
    access-control: 127.0.0.0/8 allow
    #access-control: 10.8.0.0/24 allow
forward-zone:
   name: "."
   forward-addr: 127.0.0.1@40
   forward-first: no
forward-zone:
   name: "."
   forward-addr: 127.0.0.2@40
   forward-first: no
remote-control:
       control-enable: no' >/etc/unbound/unbound.conf
       
if [[ "$?" -eq "0" ]] ; then
    service unbound stop ;service unbound start ;service unbound reload; return $?
fi
}


# make sure dnscrypt is running on port 40
if dig @127.0.0.1 -p 40 google.com >/dev/null 2>&1 ;then
  verbose && echo 'Dnscrypt okay. Checking unbound...'
else
  check_DNSC
fi


# We're still running so obviously that failed, so now make sure unbound is listening on port 53 and forwarding to port 40
if dig @127.0.1.1 -p 53 encrypted.google.com >/dev/null 2>&1 ;then
  verbose && echo 'Unbound seems okay... exiting'
  exit 0
else
  if check_unbound ; then
    verbose && { echo "Sucess!" ; exit 0 ;} || { verbose && echo 'Fail!' ; exit 1 ;}
  fi
fi
