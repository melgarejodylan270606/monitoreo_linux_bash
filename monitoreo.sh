#!/bin/bash


source config.txt


LOG="logs/monitoreo.log"


mkdir -p logs



CPU=$CPU_LIMITE
DISCO=$DISCO_LIMITE



if [ ! -z "$1" ]; then

CPU=$1

fi


if [ ! -z "$2" ]; then

DISCO=$2

fi




telegram(){

curl -s -X POST \
"https://api.telegram.org/bot$TOKEN/sendMessage" \
-d chat_id="$CHAT_ID" \
-d text="$1" >/dev/null

}




uso_cpu=$(top -bn1 | grep "Cpu(s)" | awk '{print $2 + $4}')


uso_disco=$(df / | awk 'NR==2 {print $5}' | tr -d '%')



echo "$(date) CPU:$uso_cpu Disco:$uso_disco" >> $LOG




if (( ${uso_cpu%.*} > CPU )); then


telegram "Alerta CPU alta:
Uso actual: $uso_cpu%"


fi




if [ "$uso_disco" -gt "$DISCO" ]; then


telegram "Alerta disco lleno:
Uso actual: $uso_disco%"


fi



exit 0
