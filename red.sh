#!/bin/bash


# Cargar configuracion externa

if [ ! -f "config.txt" ]; then


echo "Error: No existe config.txt"


exit 1


fi



source config.txt




# Crear carpeta de logs

mkdir -p logs



LOG="logs/red.log"





# Funcion para enviar mensajes a Telegram

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





# Capturar interrupciones

trap "echo Script cancelado; exit 1" SIGINT SIGTERM





# Validar configuracion de hosts

if [ -z "$HOSTS" ]; then


echo "Error: No hay hosts configurados"


exit 1


fi




if [ -z "$PUERTOS" ]; then


echo "Error: No hay puertos configurados"


exit 1


fi






# Revision de conectividad de cada host

for host in $HOSTS

do




echo "Revisando host: $host"




estado=""





# Verificar conectividad usando ping

ping -c 2 "$host" >/dev/null 2>&1





if [ $? -ne 0 ]; then




estado="Sin respuesta"




echo "$(date) $host -> $estado" >> "$LOG"




telegram "Alerta: El host $host no responde"




continue



fi






# Si responde se revisan puertos

estado="Accesible"



for puerto in $PUERTOS

do




nc -z -w 3 "$host" "$puerto" >/dev/null 2>&1






if [ $? -ne 0 ]; then



estado="Parcialmente accesible"



telegram "Alerta: Host $host puerto $puerto no responde"



fi





done






# Guardar resultado final

echo "$(date) $host -> $estado" >> "$LOG"





echo "$host estado: $estado"





done




exit 0
