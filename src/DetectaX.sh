#!/bin/bash

#
# Demonio que detecta llegada de archivos a $ARRIDIR, y los acepta o rechaza
#
#
#ACTUAL="$PWD/Detectar"
#ARRIDIR="$ACTUAL/arridir"
#ACEPDIR="$ACTUAL/acepdir"
#RECHDIR="$ACTUAL/rechdir"
#MAEDIR="$ACTUAL/maedir"

source "valPais.sh";
source "$BINDIR/GlogX.sh";
source "$BINDIR/MoverX.sh";
source "$BINDIR/StartX.sh";
archMae="$MAEDIR/p-s.mae"

#chequeo que me esten pasando 2 parametros

echo $MAEDIR
echo $ARRIDIR

if [[ $# != 2 ]]
	then
	echo "Error: Falta un parámetro - debe pasarse como parametro la cantidad de ciclos y el tiempo de espera en segundos"
	exit 0
fi

mesActual=$(date +%m)
anioActual=$(date +%Y)
periodoActual=$anioActual$mesActual


canloop=$1
tespera=$2

echo $canloop
echo $tespera
########## comienza a correr
while [[ "$canloop" != 0 ]]
do
#Grabar en el Log Ciclo Nro "$3-$canloop+1"(Glog)
#
	if [[ -n $(ls $ARRIDIR) ]]  #Chequeo si hay archivos en $ARRIDIR
	then
		
	
		for arch in "$ARRIDIR"/*   #para todos los archivos en el directorio $ARRIDIR
		do
			tipoArch="$(file -b "$arch")" #me da el tipo de archivo
			tipoArch=$(echo $tipoArch | cut -f 1 -d",")
			echo $tipoArch	
			echo "arch = $arch"
			valido=true;
			if [[ "$tipoArch" = "ASCII text" ]] || [[ "$tipoArch" = "empty" ]] #si el archivo es de texto o vacio, es valido
			then						
						
				aux=${arch##*/} #saco hasta la ultima barra
				sinExt=${aux%'.'*} #saco la extension al nombre del archivo
	#########################
				pais=$(echo "$sinExt" | cut -s -f1 -d'-')
				sistema=$(echo "$sinExt" | cut -s -f2 -d'-')
				anio=$(echo "$sinExt" | cut -s -f3 -d'-')
				cantDigAnio=$(echo -n "$anio" | wc -m)
				mes=$(echo "$sinExt" | cut -s -f4 -d'-')
				cantDigMes=$(echo -n "$mes" | wc -m)
				if [[ "$pais" != [A-Z] ]] || [[ "$sistema" != [0-9] ]] || [[ "$cantDigAnio" != 4 ]] || [[ "$cantDigMes" != 2 ]]
					then
					echo "error: nombre de archivo con formato invalido. Ejemplo de formato valido: A-6-2010-02"
					GlogX "DetectaX.sh" "ERROR" "nombre de archivo con formato invalido. Ejemplo de formato valido: A-6-2010-02" $0
					MoverX  "$arch" "$RECHDIR" "DetectaX.sh"
					#mover a RECHDIR
					valido=false
					continue
				fi
	################################3
				periodo=$anio$mes
				if [[ "$periodo" > "$periodoActual" ]] || [[ "$periodo" < "200000" ]] #2000+00
					then
					echo "error: periodo invalido. Debe ser desde 2001-01 hasta $anioActual-$mesActual"
					 GlogX "DetectaX.sh" "ERROR" "periodo invalido. Debe ser desde 2001-01 hasta $anioActual-$mesActual" $0
					 MoverX  "$arch" "$RECHDIR" "DetectaX.sh"
					#mover a RECHDIR
					valido=false	
					continue	
				fi 
			########### pais/sistema/mes
				if [[ "$mes" -lt 0 ]] || [[ "$mes" -gt 12 ]]
					then
					echo "escribo log con mensaje: mes invalido"
					 GlogX "DetectaX.sh" "ERROR" "mes invalido" $0
					 MoverX  "$arch" "$RECHDIR" "DetectaX.sh"
					#mover a RECHDIR
					valido=false
					continue
				fi

				ret=$( validar "$pais" "$sistema" "$archMae")
				if [[ "$ret" != "Valido" ]]
				then			
					echo "escribo el log con mensaje "$ret""
					valido=false
					continue
				fi


			#######aca terminan los invalidos, si llega es que es valido
				if [[ "$valido" = true ]]
					then
					echo "valido" #si no pongo esto se enoja xq esta vacio el if
					 GlogX "DetectaX.sh" "Informativo" "Archivo valido" $0
					echo $arch
					echo $ACEPDIR
					MoverX  "$arch" "$ACEPDIR" "DetectaX.sh"
					#mover a ACEPDIR
					#grabar log con mensaje de exito
				else
					echo "error de programacion, no deberia llegar aca invalido"	
				fi

	
			else
				GlogX "DetectaX.sh" "ERROR" "tipo de arch invalido (escribir log)" $0
				MoverX  "$arch" "$RECHDIR" "DetectaX.sh"
				#mover archivo a $RECHDIR
				echo "Error: tipo de arch invalido (escribir log)"
				validez=false

			fi	#fin del if que evalua el tipo de archivo
 
		done #fin del for que mueve archivos a la carpeta correspondiente y graba logs

	fi
############### todos los archivos que corresponden fueron movidos a $acepdir o $rechdir

	if [[ $(ls -A "$ACEPDIR") ]] #si $ACEPTDIR tiene algun archivo
		then
		echo "carpeta con archivos, se ejecutara el interprete si no hay otro corriendo"
		
		#procesos=$(ps | grep Interprete.sh) #cambiar por Interprete

		StartX "DetectaX.sh" "Interprete.sh"
		
		#if [[ $? -ne 1 ]]   
		#then
		#	echo $?
		#fi

		#if [[ -n "$procesos" ]]
		#	then
		#	echo "DetectaX.sh esta corriendo, no se pudo ejecutar" #cambiar por Interprete y msj de error si no se ejecuta
		#else
		#	echo "se comienza a ejecutar Interprete"
		#	echo "se devuelve el PID de Interprete"
		#	#si interprete tira algun error hay que mostrar mensaje
		#	echo $( ps cax | grep DetectaX.sh | cut -c1-5 ) # CHEQUEAR PORQUE TIRA UN PROCESO DE MAS Y CAMBIAR POR INTERPRETE
		#fi	

	fi

#### termino el ciclo, actualizo variable
	canloop=$(expr $canloop - 1)
	if [[ $canloop != 0 ]]
	then
		sleep $tespera
	fi
done

