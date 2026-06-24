#!/bin/bash


source config.txt



mkdir -p logs


FECHA=$(date +"%Y-%m-%d_%H-%M")

ARCHIVO="$RUTA_RESPALDO/respaldo_$FECHA.tar.gz"



telegram(){

curl -s -X POST \
"https://api.telegram.org/bot$TOKEN/sendMessage" \
-d chat_id="$CHAT_ID" \
-d text="$1" >/dev/null

}




if [ ! -d "$RUTA_RESPALDO" ]; then

mkdir -p "$RUTA_RESPALDO"

fi



tar -czf "$ARCHIVO" $DIRECTORIOS_RESPALDO



if [ $? -ne 0 ]; then

echo "$(date) Error creando respaldo" >> logs/sistema.log

exit 1

fi




if [ ! -s "$ARCHIVO" ]; then

echo "$(date) Archivo vacio" >> logs/sistema.log

exit 1

fi




TAMANIO=$(du -h "$ARCHIVO" | cut -f1)



echo "$(date) Respaldo generado $ARCHIVO tamaño $TAMANIO" >> logs/sistema.log



telegram "Respaldo generado:
Ruta: $ARCHIVO
Tamaño: $TAMANIO
Fecha: $(date)"



exit 0
