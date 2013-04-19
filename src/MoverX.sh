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
   
   carpetaOrigen = ${origen%/*}
   archivoOrigen = ${origen##*/}

   # 1.1 Verifico si la carpeta de origen y de destino son iguales
   if [ $carpetaOrigen = $destino ] 
   then
      return 1
   fi

   # 1.2 Verifico que existan el archivo origen y la carpeta destino
   if [ ! -f $origen  ] || [ ! -d $destino ]
   then
      return 1
   fi

   # 1.3 Verifico si es un archivo duplicado
   if [ -f $destino$archivo ] 
   then
      # Verifico si existe la carpeta dup, si no, la creo
	  if [ ! -d "dup" ]; then
	     mkdir dup
      fi
	  
	  # Falta generar el número de control
	  
	  #Copio el archivo a la carpeta de duplicados
	  mv $origen dup/$destino
   else 
      mv $origen $destino
   fi
}
