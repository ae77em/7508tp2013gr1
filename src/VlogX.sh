#! /bin/bash

# Filtros:
# -n: muestra las ultimas n lineas
# string: filtra las lineas que tienen el string
function VlogX {
   # Cantidad de lineas a dejar
   nroLineas=50

   # Si no se pasan los 2 parametros solicitados, es un error
   if [ $# -eq 4 ]
   then
      return 1
   fi
      
   comando=$1
   filtro=$2
   archivoLog=$3
   directorioLog=$LOGDIR
   
   usuario=$(whoami)
   
   if [ comando = "InstalarX.sh" ]
   then
      directorioLog=$CONFDIR
   fi
   
   # Leo el log segun el filtro
   # When Who Where What Why
   
   if [[ $filtro =~ \-[0-9]+ ]]
   then
      tail $filtro $directorioLog/$archivoLog.$LOGEXT
   else
      cat $directorioLog/$archivoLog.$LOGEXT | grep -i $filtro
   fi   
   
   return 0
}
 
