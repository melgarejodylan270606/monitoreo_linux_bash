#!/bin/bash

source config.txt

mkdir -p logs

LOG="$LOG_USUARIOS"

telegram() {
curl -s -X POST "https://api.telegram.org/bot$TOKEN/sendMessage" \
-d chat_id="$CHAT_ID" \
-d text="$1" > /dev/null
}

trap "echo 'Saliendo...'; exit 1" SIGINT

while true; do
echo "=== MENU USUARIOS ==="
echo "1) Crear usuario"
echo "2) Eliminar usuario"
echo "3) Modificar usuario"
echo "4) Salir"
read -p "Opcion: " op

case $op in

1)
read -p "Usuario a crear: " u
id "$u" &>/dev/null
if [ $? -eq 0 ]; then
echo "Usuario ya existe"
else
sudo useradd "$u"
echo "$(date) Usuario creado: $u" >> "$LOG"
telegram "Usuario creado: $u"
fi
;;

2)
read -p "Usuario a eliminar: " u
id "$u" &>/dev/null
if [ $? -ne 0 ]; then
echo "Usuario no existe"
else
sudo userdel "$u"
echo "$(date) Usuario eliminado: $u" >> "$LOG"
telegram "Usuario eliminado: $u"
fi
;;

3)
read -p "Usuario a modificar: " u
id "$u" &>/dev/null
if [ $? -ne 0 ]; then
echo "Usuario no existe"
else
sudo usermod -c "modificado" "$u"
echo "$(date) Usuario modificado: $u" >> "$LOG"
telegram "Usuario modificado: $u"
fi
;;

4)
echo "Saliendo..."
exit 0
;;

*)
echo "Opcion invalida"
;;
esac

done
