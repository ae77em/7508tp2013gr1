#! /bin/bash

function MoverX {
   # Si no se pasan los 3 parametros solicitados, es un error
   if [ $# -eq 3] 
   then
      return 1
   fi

   # Tomo los parametros
   origen = $1
   destino = $2
   comando = $3

   # 1.1 Verifico si origen y destino son iguales
   if [ $origen = $destino ] 
   then
      return 1
   fi

   # 1.2 Verifico que existan origen y destino
   if [ ! -f $origen  ] || [ ! -f $destino ]
   then
      return 1
   fi

   # 1.3 Verifico si es un archivo duplicado
   if [ -f $destino ] 
   then
      #Manejo el duplicado ...
   else 
      mv $origen $destino
   fi
}
