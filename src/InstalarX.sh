#!/bin/bash

#===========================================================
# ARCHIVO: InstalarX.sh
#
# FIRMA: TODO:HACER!
#
# DESCRIPCION: TODO:HACER!
#
# AUTOR: Bayetto, Ignacio Javier. 
# PADRON: 88896
#
#===========================================================

function mostrarMensajeInstalacionFinalizada {

	dirconf=`ls $CONFDIR`
	dirbin=`ls $BINDIR`
	dirmae=`ls $MAEDIR`

	mensaje="
TP SO7508 Primer Cuatrimestre 2013. Tema X Copyright (c) Grupo 1.

Librería del sistema: $CONFDIR

Archivos: 
$dirconf


Ejecutables: $BINDIR

Archivos: 
$dirbin


Archivos maestros: $MAEDIR

Archivos: 
$dirmae


Directorio de arribo de archivos externos: $ARRIDIR

Archivos externos aceptados: $ACEPDIR

Archivos externos rechazados: $RECHDIR

Archivos procesados: $PROCDIR

Reportes de salida: $REPODIR

#TODO: ver que comando poner!!!
Logs de auditoría del Sistema: $LOGDIR/<comando>.$LOGEXT

Estado de la instalación: COMPLETA

Proceso de Instalación CANCELADO.
"

	echo "$mensaje"
	grabarLog "$mensaje"

}

#Completa la instalacion en caso de haber encontrado una ya existente (incompleta)
function completarInstalacion {

	#TODO: COMPLETAR!
}


#Verifica la existencia de directorio de reportes  definido en el archivo de configuracion 
function chequearREPODIR {

	if [ -z "$REPODIR" ]; then
		REPODIR="$grupo/reportes"
		reportes=1
		cantErrores=$[ $cantErrores + 1]
	else
		if ! [ -d "$REPODIR" ]; then
			reportes=1
			cantErrores=$[ $cantErrores + 1]
		fi
	fi

}

#Verifica la extension del archivo de log 
function chequearLOGEXT {

	if [ -z "$LOGEXT" ]; then
		LOGEXT=".log"
		extension=1
		cantErrores=$[ $cantErrores + 1]		
	fi

}

#Verifica la existencia de directorio de archivos de log  definido en el archivo de configuracion 
function chequearLOGDIR {

	if [ -z "$LOGDIR" ]; then
		LOGDIR="$grupo/log"
		log=1
		cantErrores=$[ $cantErrores + 1]
	else
		if ! [ -d "$LOGDIR" ]; then
			log=1
			cantErrores=$[ $cantErrores + 1]
		fi
	fi

}

#Verifica la existencia de directorio de archivos maestros definido en el archivo de configuracion 
function chequearMAEDIR {

	if [ -z "$MAEDIR" ]; then
		MAEDIR="$grupo/mae"
		maestros=0
		cantErrores=$[ $cantErrores + 1]
	else
		if ! [ -d "$MAEDIR" ]; then
			maestros=0
			cantErrores=$[ $cantErrores + 1]
		fi
	fi

}

#Verifica la existencia de directorio de procesados definido en el archivo de configuracion 
function chequearPROCDIR {

	if [ -z "$PROCDIR" ]; then
		PROCDIR="$grupo/procesados"
		procesados=1
		cantErrores=$[ $cantErrores + 1]
	else
		if ! [ -d "$PROCDIR" ]; then
			procesados=1
			cantErrores=$[ $cantErrores + 1]
		fi
	fi

}

#Verifica la existencia de directorio de rechazados definido en el archivo de configuracion 
function chequearRECHDIR {

	if [ -z "$RECHDIR" ]; then
		RECHDIR="$grupo/rechazados"
		rechazados=1
		cantErrores=$[ $cantErrores + 1]
	else
		if ! [ -d "$RECHDIR" ]; then
			rechazados=1
			cantErrores=$[ $cantErrores + 1]
		fi
	fi

}

#Verifica la existencia de directorio de arribos definido en el archivo de configuracion 
function chequearARRIDIR {

	if [ -z "$ARRIDIR" ]; then
		ARRIDIR="$grupo/arribos"
		arribos=1
		cantErrores=$[ $cantErrores + 1]
	else
		if ! [ -d "$ARRIDIR" ]; then
			arribos=1
			cantErrores=$[ $cantErrores + 1]
		fi
	fi

}

#Verifica la existencia de directorio de archivos ejecutables definido en el archivo de configuracion
function chequearBINDIR {

	if [ -z "$BINDIR" ]; then
		BINDIR="$grupo/bin"
		cantErrores=$[ $cantErrores + 1]
		ejecutables=0
	else
		if ! [ -d "$BINDIR" ]; then
			cantErrores=$[ $cantErrores + 1]
			ejecutables=0
		fi
	fi

}

#Verifica cuales son los componentes ya instalados
function chequearComponentesInstalados {
	
	#chequearDATASIZE
	chequearBINDIR
	chequearARRIDIR
	chequearACEPDIR
	chequearRECHDIR
	chequearPROCDIR
	chequearMAEDIR
	chequearLOGDIR
	chequearLOGEXT
	chequearREPODIR
	#chequearLOGSIZE

}

#Muestra mensaje inicio instalacion
function mostrarMensajeInicioInstalacion {
	echo '
************************************************************************
* TP SO7508 Primer Cuatrimestre 2013. Tema X Copyright (c) Grupo 1
* A T E N C I O N: Al instalar TP SO7508 Primer Cuatrimestre 2013 UD.
* expresa aceptar los términos y condiciones del "ACUERDO DE LICENCIA DE
* SOFTWARE" incluído en este paquete.
************************************************************************
'
}

#Comienza la instalcion
function instalar {

	mostrarMensajeInicioInstalacion
	#TODO: COMPLETAR!
}

#Inicializa las variables del directorio del archivo de configuracion
function inicializarVariablesDefault {

	GRUPO=$grupo
	CONFDIR=$GRUPO/conf
	#DATASIZE=100
	BINDIR=$GRUPO/bin
	ARRIDIR=$GRUPO/arribos
	ACEPDIR=$GRUPO/aceptados
	RECHDIR=$GRUPO/rechazados
	PROCDIR=$GRUPO/procesados
	MAEDIR=$GRUPO/mae
	LOGDIR=$GRUPO/log
	LOGEXT=.log
	REPODIR=$GRUPO/reportes
	#LOGSIZE=400
	
}

#Llama al log para grabar
function grabarLog {

	#TODO: hacer
	echo "[Glog] grabo :)"
}

#Crea el directorio y el archivo de configuracion si no existe
function crearDirectorioArchivoConfiguracion {

	mkdir -p $CONFDIR
	>>$CONFDIR/$confFile

}

#Crea el archivo de log
function crearLog {

	>>$CONFDIR/$logFile

	#TODO: Ver!
	#Doy permiso de ejecucion al log
	#chmod 777 -Tiene que haber un handler para el log
	
} 

#Graba mensajes de inicio en el log
function mensajesInicioLog {

	mensaje="[InstalarX] Inicio de Ejecución"
	echo $mensaje
	grabarLog "$mensaje"
	mensaje="[InstalarX] Log del Comando InstalarX: $CONFDIR/$logFile"
	echo $mensaje
	grabarLog "$mensaje"
	mensaje="Directorio de Configuración: $CONFDIR"
	echo $mensaje
	grabarLog "$mensaje"
	
	#TODO: SACAR
	echo "Grabo mensajes iniciales en el log"
}

function main {

	clear
	cd ..

	#grupo: path donde se encuentra el tp ../grupo1/
	grupo=$PWD/grupo1

	#TODO: Sacar
	echo "$grupo"

	#CONFDIR: ubicacion del directorio de configuracion
	CONFDIR=$grupo/conf
	
	#TODO: SACAR
	echo "$CONFDIR"

	#confFile: nombre archivo configuracion
	confFile="InstalarX.conf"

	#logFile: nombre archivo de log
	logFile="InstalarX.log"

	echo "************************************************************************
*   Bienvenido al Asistente de instalación del sistema ControlX        *
*   TP SO7508 Primer Cuatrimestre 2013. Tema X Copyright (c) Grupo 1   *
************************************************************************"

	crearDirectorioArchivoConfiguracion
	#1 - Inicializar archivo de log
	crearLog
	#2 - Mostrar (y grabar en el log) donde se graba el log de la instalacion
	#3 - Mostrar (y grabar en el log) el nombre del directorio de configuracion
	mensajesInicioLog

	#4 - Detectar si el paquete ControlX o alguno de sus componentes ya esta instalado
	# Cuento la cantidad de lines del archivo de configuracion
	cantLineas=$(wc -l $CONFDIR/$confFile | awk '{print $1}')
	#echo $cantLineas
	if ["$cantLineas" -eq "0"];
	then 
		#5 - Aceptacion de terminos y condiciones
		inicializarVariablesDefault
		instalar
	else
		#4.1 - Verifico instalacion previa
		leerVariablesConfiguracion "$CONFDIR/$confFile"
		
		cantErrores=0
		arribos=0
		log=0
		rechazados=0
		reportes=0
		#tamanio=0
		extension=0
		tamanioLog=0
		maestros=1
		ejecutables=1

		chequearComponentesInstalados

		if [ $cantErrores -gt 0 ]; then 
			completarInstalacion
		else
			mostrarMensajeInstalacionFinalizada
		fi
	fi

	echo "[InstalarX] Instalación Finalizada"

}
main
