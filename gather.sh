#! /bin/bash

# Set Environment Vars
#
force=false

# Sets up the options for Username and Password
#

while getopts ":u:p:f:" opt; do
  case "$opt" in
    u) username=$OPTARG ;;
    p) password=$OPTARG ;;
    f) force="true"    ;;
  esac
done
shift $(( OPTIND - 1 ))


# Configures the DC/OS Components for Mesos Master Logs and slave logs
#

master_dcos_service_list=(         \
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

agent_dcos_service_list=(          \
dcos-3dt.service                   \
dcos-adminrouter-agent.service     \
dcos-epmd.service                  \
dcos-mesos-slave.service           \
dcos-minuteman.service             \
dcos-navstar.service               \
dcos-pkgpanda-api.service          \
dcos-rexray.service                \
dcos-spartan-watchdog.service      \
dcos-spartan.service               \
dcos-3dt.socket                    \
dcos-pkgpanda-api.socket           \
)

function authenticate {

  # Autenticates to Mesos Master and Retrieves the token for the user
  #

  username_helper='{"uid": "'
  password_helper='", "password": "'
  url=$username_helper$username$password_helper$password\"}
  result=$(curl --write-out '%{http_code}\n' --silent  -X POST leader.mesos/acs/api/v1/auth/login -d "${url}" -H 'Content-Type: application/json')


  if [ $(echo $result | rev | cut -c -3 | rev)  -eq 200 ]; then
     echo "Successfully Autenticated with Master!"
     token=$(echo $result | grep token | cut -d " " -f3)
     echo "My token is $token"
  elif [ $(echo $result | rev | cut -c -3 | rev)  -eq 401 ]; then
      if "$force" == true ; then
        echo "Invalid Credentials. Detected --force, skipping state.json"
       else
        echo "Invalid Credentials. Please try again or use --force to ignore"
        exit 1
      fi
  else
     echo "Unknown code. Contact Mesosphere Support for assistance. "
     echo $result
     exit 1
  fi


}

function master-node-collector {
  echo "Collected logs"
  echo ${master_dcos_service_list[@]}
  exit
}
  function agent-node-collector {
  echo "Collected logs"
  echo ${agent_dcos_service_list[@]}
  echo Hello!
}

function main_function {

  authenticate

  if [[ $(systemctl | grep dcos-mesos-master > /dev/null; echo $?) -eq 0 ]]; then
       echo "Determined that this is a mesos master! Getting logs for mesos master"
       master-node-collector

   elif [[ $(systemctl | grep dcos-mesos-slave > /dev/null; echo $?) -eq 0 ]]; then
       echo "Determined that this is a mesos slave[-public]"
       agent-node-collector

   elif [[ $(systemctl | grep dcos; echo $?) -eq 0 ]]; then
       echo "There was that failed but will try to get everything anyways"
   fi

}

main_function

