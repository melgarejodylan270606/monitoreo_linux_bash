#!/bin/bash

# Cargar configuracion externa

if [ ! -f "config.txt" ]; then
    echo "Error: No existe config.txt"
    exit 1
fi

source ./config.txt


# Funcion para enviar mensajes a Telegram

telegram(){

curl -s -X POST \
"https://api.telegram.org/bot$TOKEN/sendMessage" \
-d chat_id="$CHAT_ID" \
-d text="$1" > /dev/null

}


# Crear carpeta de reportes

mkdir -p reportes


# Capturar señales para salida limpia

trap "echo Script cancelado; exit 1" SIGINT SIGTERM


# Validar configuracion

if [ -z "$HOSTS_REMOTOS" ]; then
    echo "Error: No hay hosts configurados"
    exit 1
fi


if [ -z "$SCRIPT_REMOTO" ]; then
    echo "Error: No existe script remoto definido"
    exit 1
fi


if [ -z "$USUARIO_REMOTO" ]; then
    echo "Error: No existe usuario remoto configurado"
    exit 1
fi


# Validar existencia del script

if [ ! -f "$SCRIPT_REMOTO" ]; then
    echo "Error: El script $SCRIPT_REMOTO no existe"
    exit 1
fi



# Recorrer hosts configurados

for host in $HOSTS_REMOTOS
do

echo "Visitando host: $host"


# Probar conexion SSH

ssh -o ConnectTimeout=5 \
$USUARIO_REMOTO@$host "echo Conexion correcta" >/dev/null 2>&1


if [ $? -ne 0 ]; then

echo "
Reporte del host: $host

Fecha: $(date)

Resultado:

No fue posible conectarse por SSH

" > reportes/$host.txt

telegram "ERROR remoto: No fue posible conectar con $host"

continue

fi



# Copiar script remoto

scp "$SCRIPT_REMOTO" \
$USUARIO_REMOTO@$host:/tmp/


if [ $? -ne 0 ]; then

echo "
Reporte del host: $host

Fecha: $(date)

Resultado:

Error copiando archivo

" > reportes/$host.txt

telegram "ERROR remoto: No se pudo copiar script a $host"

continue

fi



# Ejecutar script remoto y guardar salida

resultado=$(ssh \
$USUARIO_REMOTO@$host \
"bash /tmp/$SCRIPT_REMOTO")



# Crear reporte final

echo "

Reporte del host: $host

Fecha: $(date)


Resultado:

$resultado

" > reportes/$host.txt



echo "Reporte generado para $host"


# Enviar resumen a Telegram

telegram "OK remoto: $host ejecutado correctamente. Reporte generado."



done


exit 0
