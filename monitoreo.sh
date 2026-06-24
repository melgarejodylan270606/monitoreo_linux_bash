#!/bin/bash


source config.txt


mkdir -p logs

telegram() {
curl -s -X POST "https://api.telegram.org/bot$TOKEN/sendMessage" \
-d chat_id="$CHAT_ID" \
-d text="$1" > /dev/null
}

trap "echo 'Saliendo monitoreo'; exit 1" SIGINT

CPU_LIMITE=${1:-$CPU_LIMITE}
DISCO_LIMITE=${2:-$DISCO_LIMITE}

cpu=$(top -bn1 | grep "Cpu(s)" | awk '{print 100 - $8}')
disco=$(df / | awk 'NR==2 {print $5}' | tr -d '%')

# LOG GENERAL
log_msg="$(date) CPU:${cpu}% DISCO:${disco}%"
echo "$log_msg" >> logs/monitoreo.log

# ENVIAR SIEMPRE RESUMEN A TELEGRAM
telegram "MONITOREO: CPU ${cpu}% | DISCO ${disco}%"

# ALERTAS
if (( $(echo "$cpu > $CPU_LIMITE" | bc -l) )); then
alerta="$(date) ALERTA CPU ALTA: ${cpu}%"
echo "$alerta" >> logs/monitoreo.log
telegram "$alerta"
fi

if [ "$disco" -gt "$DISCO_LIMITE" ]; then
alerta="$(date) ALERTA DISCO ALTO: ${disco}%"
echo "$alerta" >> logs/monitoreo.log
telegram "$alerta"
fi

exit 0
