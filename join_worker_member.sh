#/bin/bash
# Get the line number of the sentence syas: 'Then you can join any number of worker nodes'

# The first argument is ansible_host which passed to the script
APISERVER_ADVERTISE_ADDRESS=$1

KUBEADM_INIT_OUTPUT_FILE=./token
LINE_NUMBER=$(cat $KUBEADM_INIT_OUTPUT_FILE | grep -n "Then you can join any number of worker nodes" | cut -d: -f1)

COMMAND=`sed -n "$((LINE_NUMBER+2)),$((LINE_NUMBER+4))p" $KUBEADM_INIT_OUTPUT_FILE)`
echo "$COMMAND --apiserver-advertise-address $APISERVER_ADVERTISE_ADDRESS"
