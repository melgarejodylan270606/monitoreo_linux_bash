#!/bin/bash


# Cargar configuracion externa

if [ ! -f "config.txt" ]; then


echo "Error: No existe config.txt"


exit 1


fi



source config.txt





# Crear nombre del archivo de inventario con fecha

FECHA=$(date +"%Y-%m-%d_%H-%M")


ARCHIVO="/var/log/inventario_$FECHA.txt"





# Capturar interrupciones para salida limpia

trap "echo Script cancelado; exit 1" SIGINT SIGTERM





# Funcion para enviar resumen a Telegram

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






# Validar permisos para escribir en /var/log

if [ ! -w "/var/log" ]; then


echo "Error: No hay permisos para escribir en /var/log"


exit 1


fi






# Inicio del reporte

echo "================================" > "$ARCHIVO"

echo " Inventario del sistema " >> "$ARCHIVO"

echo " Fecha: $(date) " >> "$ARCHIVO"

echo "================================" >> "$ARCHIVO"





# Informacion general del equipo

echo "" >> "$ARCHIVO"

echo "Hostname:" >> "$ARCHIVO"

hostname >> "$ARCHIVO"





# Sistema operativo

echo "" >> "$ARCHIVO"

echo "Sistema operativo:" >> "$ARCHIVO"


cat /etc/os-release >> "$ARCHIVO"






# Version del kernel

echo "" >> "$ARCHIVO"

echo "Kernel:" >> "$ARCHIVO"


uname -r >> "$ARCHIVO"






# Informacion del procesador

echo "" >> "$ARCHIVO"

echo "CPU:" >> "$ARCHIVO"


lscpu | grep "Model name" >> "$ARCHIVO"






# Cantidad de nucleos

echo "" >> "$ARCHIVO"

echo "Nucleos disponibles:" >> "$ARCHIVO"


nproc >> "$ARCHIVO"







# Memoria RAM total y disponible

echo "" >> "$ARCHIVO"

echo "Memoria RAM:" >> "$ARCHIVO"


free -h >> "$ARCHIVO"






# Uso de almacenamiento por particion

echo "" >> "$ARCHIVO"

echo "Uso de disco:" >> "$ARCHIVO"


df -h >> "$ARCHIVO"






# Obtener resumen para Telegram

HOST=$(hostname)

RAM=$(free -h | awk '/Mem/ {print $2}')

DISCO=$(df -h / | awk 'NR==2 {print $5}')





# Enviar notificacion

telegram "Inventario generado:

Equipo: $HOST

RAM: $RAM

Uso disco: $DISCO

Archivo: $ARCHIVO"






# Mostrar ubicacion del reporte

echo "Reporte creado en: $ARCHIVO"



exit 0
