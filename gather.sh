#! /bin/bash

# Sets up the options for Username and Password
#

while getopts ":u:p:" opt; do
  case "$opt" in
    u) username=$OPTARG ;;
    p) password=$OPTARG ;;
  esac
done
shift $(( OPTIND - 1 ))


# Configures the DC/OS Components for Mesos Master Logs
# TODO: Setup logs for Slave
#

dcos_service_list=(                \
dcos-3dt.service                   \
dcos-adminrouter.service           \
dcos-bouncer.service               \
dcos-ca.service                    \
dcos-cosmos.service                \
dcos-download.service              \
dcos-epmd.service                  \
dcos-exhibitor.service             \
dcos-gen-resolvconf.service        \
dcos-history.service               \
dcos-logrotate-master.service      \
dcos-marathon.service              \
dcos-mesos-dns.service             \
dcos-mesos-master.service          \
dcos-metronome.service             \
dcos-minuteman.service             \
dcos-navstar.service               \
dcos-networking_api.service        \
dcos-pkgpanda-api.service          \
dcos-secrets.service               \
dcos-setup.service                 \
dcos-signal.service                \
dcos-spartan-watchdog.service      \
dcos-spartan.service               \
dcos-vault.service                 \
)

# Autenticates to Mesos Master and Retrieves the token for the user
#

echo ${dcos_service_list[@]}
username_helper='{"uid": "'
password_helper='", "password": "'
url=$username_helper$username$password_helper$password\"}
result=$(curl --write-out '%{http_code}\n' --silent  -X POST localhost:8101/acs/api/v1/auth/login -d "${url}" -H 'Content-Type: application/json')

if [ $(echo $result | rev | cut -c -3 | rev)  -eq 200 ]; then
   echo "It works!"
elif [ $(echo $result | rev | cut -c -3 | rev)  -eq 401 ]; then
   echo "Invalid Credentials. Please try again."
   exit 1
else
   echo "Unknown code"
   exit 1
fi
