#! /bin/bash

# 4to parametro: nombre del archivo de log sin extension
function GlogX {
   # Si no se pasan los 4 parametros solicitados, es un error
   if [ $# -eq 5 ]
   then
      return 1
   fi
   
   comando=$1
   tipoMensaje=$2
   mensaje=$3
   archivoLog=$4
   directorioLog=$LOGDIR
   
   fecha=$(date)
   usuario=$(whoami)
   
   if [ comando = "InstalarX.sh" ]
   then
      directorioLog=$CONFDIR
      # Recortar log
   fi
   
   # Escribo el log
   # When Who Where What Why
   echo $fecha $usuario $comando $tipoMensaje $mensaje >> $directorioLog/$archivoLog.$LOGEXT   
}
