#!/bin/bash

# Cargar configuracion externa

if [ ! -f "config.txt" ]; then

echo "Error: No existe config.txt"
exit 1

fi


source config.txt

# Crear carpeta de logs si no existe

mkdir -p logs



LOG="logs/servicios.log"


# Funcion para enviar alertas a Telegram

telegram(){

if [ -z "$TOKEN" ] || [ -z "$CHAT_ID" ]; then

echo "Telegram no configurado"

return 1


fi




curl -s -X POST \
"https://api.telegram.org/bot$TOKEN/sendMessage" \
-d chat_id="$CHAT_ID" \
-d text="$1" >/dev/null



}





# Capturar señales para salida limpia

trap "echo Script cancelado; exit 1" SIGINT SIGTERM





# Validar que existan servicios configurados

if [ -z "$SERVICIOS" ]; then


echo "Error: No hay servicios configurados"

exit 1


fi






# Revision de servicios definidos en config.txt

for servicio in $SERVICIOS

do



echo "Revisando servicio: $servicio"





# Obtener estado actual del servicio

estado=$(systemctl is-active "$servicio" 2>/dev/null)






# Si el servicio esta activo registra el resultado

if [ "$estado" = "active" ]; then



echo "$(date) Servicio activo: $servicio" >> "$LOG"





else




# Registrar servicio caido

echo "$(date) Servicio caido: $servicio" >> "$LOG"





# Intentar reiniciar el servicio

systemctl restart "$servicio"






# Revisar si el reinicio funciono

nuevo_estado=$(systemctl is-active "$servicio" 2>/dev/null)






if [ "$nuevo_estado" = "active" ]; then




resultado="Reinicio correcto"




else



resultado="No se pudo reiniciar"




fi






# Enviar alerta a Telegram

telegram "Servicio $servicio estaba detenido. Resultado: $resultado"






# Guardar resultado final en log

echo "$(date) $servicio $resultado" >> "$LOG"





fi




done




exit 0
