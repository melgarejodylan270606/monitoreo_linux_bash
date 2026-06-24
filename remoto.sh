#!/bin/bash


# Cargar configuracion externa

if [ ! -f "config.txt" ]; then

echo "Error: No existe config.txt"

exit 1

fi



source config.txt




# Crear carpeta de reportes si no existe

mkdir -p reportes





# Capturar señales para salida limpia

trap "echo Script cancelado; exit 1" SIGINT SIGTERM





# Validar datos necesarios

if [ -z "$REMOTOS" ]; then


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






# Validar que exista el script que se copiara

if [ ! -f "$SCRIPT_REMOTO" ]; then


echo "Error: El script $SCRIPT_REMOTO no existe"

exit 1


fi





# Revision de equipos remotos

for host in $REMOTOS

do



echo "Visitando host: $host"





# Probar conexion SSH antes de copiar archivos

ssh -o ConnectTimeout=5 \
$USUARIO_REMOTO@$host "echo Conexion correcta" >/dev/null 2>&1





if [ $? -ne 0 ]; then



echo "
Reporte del host: $host

Fecha: $(date)


Resultado:

No fue posible conectarse por SSH

" > reportes/$host.txt




continue



fi







# Copiar script al equipo remoto usando SCP

scp "$SCRIPT_REMOTO" \
$USUARIO_REMOTO@$host:/tmp/






if [ $? -ne 0 ]; then



echo "
Reporte del host: $host

Fecha: $(date)


Resultado:

Error copiando archivo

" > reportes/$host.txt




continue




fi






# Ejecutar script remoto y guardar salida

resultado=$(ssh \
$USUARIO_REMOTO@$host \
"bash /tmp/$SCRIPT_REMOTO")






if [ $? -ne 0 ]; then



echo "
Reporte del host: $host

Fecha: $(date)


Resultado:

Error ejecutando script remoto

" > reportes/$host.txt



continue



fi






# Crear reporte individual del equipo

echo "

Reporte del host: $host

Fecha: $(date)


Resultado de ejecucion:


$resultado



" > reportes/$host.txt






echo "Reporte generado para $host"





done




exit 0
