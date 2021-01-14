#/bin/bash
# Get the line number of the sentence syas: 'You can now join any number of the control-plane'
#LINE_NUMBER=$(echo $JOIN_COMMAND_OUTPUT | grep -n "You can now join any number of the control-plane" | cut -d: -f1)
#NEXT_LINE_NUMBER=$[ $LINE_NUMBER + 1 ]

KUBEADM_INIT_OUTPUT_FILE=./token
LINE_NUMBER=$(cat $KUBEADM_INIT_OUTPUT_FILE | grep -n "Then you can join any number of worker nodes" | cut -d: -f1)

COMMAND=`sed -n "$((LINE_NUMBER+2)),$((LINE_NUMBER+4))p" $KUBEADM_INIT_OUTPUT_FILE)`
echo "$COMMAND --apiserver-advertise-address 172.16.16.102"
