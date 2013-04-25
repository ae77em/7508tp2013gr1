#! /bin/bash

# 4to parametro: nombre del archivo de log sin extension
function GlogX {
   # Cantidad de lineas a dejar
   nroLineas=50

   # Si no se pasan los 4 parametros solicitados, es un error
   if [ $# -eq 5 ]
   then
      return 1
   fi
   
   # Chequeo si están seteadas las variables de ambiente
   if [ -z $LOGEXT ] && [ -z $LOGDIR ] && [ -z $LOGSIZE ] && [ -z $CONFDIR ]
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
   else
      # Si no es el log de instalacion, veo el tamaño
      if [ -f $directorioLog/$archivoLog.$LOGEXT ] && [ `du -k $directorioLog/$archivoLog.$LOGEXT | awk '{ print $1 }'` -gt $LOGSIZE ]
      then   
         tail -50 $directorioLog/$archivoLog.$LOGEXT > $directorioLog/$archivoLog.$LOGEXT
         echo $fecha $usuario $comando $tipoMensaje "Log Excedido" >> $directorioLog/$archivoLog.$LOGEXT
      fi
   fi
   
   # Escribo el log
   # When Who Where What Why
   echo $fecha $usuario $comando $tipoMensaje $mensaje >> $directorioLog/$archivoLog.$LOGEXT
   
   return 0
}
