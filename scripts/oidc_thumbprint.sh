#!/bin/bash
set -e 

XR="${1:-eu-west-1}"
XT=`mktemp`
XXT=`mktemp`

function cleanup {
  rm -f ${XT} ${XXT}
}

trap cleanup SIGHUP SIGINT SIGTERM EXIT

THUMBPRINT=$(echo QUIT | openssl s_client -showcerts -connect oidc.eks.${XR}.amazonaws.com:443 2>/dev/null > ${XT}; cat ${XT} | sed -n '/BEGIN\ CERTIFICATE/,/END\ CERTIFICATE/ p' | tac | awk '/-----BEGIN CERTIFICATE-----/ {exit} 1' > ${XXT} && echo '-----BEGIN CERTIFICATE-----' >> ${XXT} && tac ${XXT} > ${XT}; openssl x509 -in ${XT} -fingerprint -noout | sed -r 's|.*+?=(.*)|\1|g' | sed 's|:||g' | awk '{print tolower($1)}')
THUMBPRINT_JSON="{\"thumbprint\": \"${THUMBPRINT}\"}"
echo $THUMBPRINT_JSON