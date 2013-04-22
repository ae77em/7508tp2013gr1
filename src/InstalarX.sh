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

#Define la extensión de los archivos de log
function definirLogExt {

	cond="error"

	while [ $cond == "error" ]; do
		cond="ok"
		echo "
* Defina la extensión para los archivos de log:
* Sugerencia: ($LOGEXT)"
		read extLog

		#Si la persona no ingreso nada entonces se toma por default la sugerencia
		if [ -z $extLog ];then
			extLog=$LOGEXT
		fi

		validarExtensionLog $extLog
	done
	unset cond
	
	LOGEXT=$extLog


	cond="error"

	while [ $cond == "error" ]; do
		cond="ok"
		echo "
* Defina el tamaño máximo para los archivos de Log (en Kbytes):
* Sugerencia: ($LOGSIZE)"
		read maxSize

		#Si la persona no ingreso nada entonces se toma por default la sugerencia
		if [ -z $maxSize ];then
			maxSize=$LOGSIZE
		fi

		validarNumerico $maxSize
	done
	unset cond

	LOGSIZE=$maxSize
}

#Define el directorio del log de auditoria
function definirDirLogAuditoria {


	cond="error"

	while [ $cond == "error" ]; do
		cond="ok"	
		echo "
* Defina el directorio de grabación de los logs de auditoría:
* Sugerencia: ($dirLog)"

		read respuesta

		#Si la persona no ingreso nada entonces se toma por default la sugerencia
		if [ -z $respuesta ];then
			respuesta=$dirLog
		fi
		if [ -n $respuesta ];then
			dirLog=$respuesta
		fi	
		validarDirectorios $respuesta
		if [ $cond == "ok" ]; then validarListaDirecciones $respuesta; fi

	done

	LOGDIR=$GRUPO/$dirLog
	unset cond


}


#Define el directorio de reportes
function definirDirReportes {

	cond="error"

	while [ $cond == "error" ]; do
		cond="ok"	
		echo "
* Defina el directorio de grabación de los reportes de salida:
* Sugerencia: ($dirReportes)"
		read respuesta

		#Si la persona no ingreso nada entonces se toma por default la sugerencia
		if [ -z $respuesta ];then
			respuesta=$dirReportes
		fi
		if [ -n $respuesta ];then
			dirReportes=$respuesta
		fi	
		validarDirectorios $respuesta
		if [ $cond == "ok" ]; then validarListaDirecciones $respuesta; fi
	done

	REPODIR=$GRUPO/$dirReportes
	unset cond


}


#Define el directorio de procesados
function definirDirProcesados {

	cond="error"

	while [ $cond == "error" ]; do
		cond="ok"	
		echo "
* Defina el directorio de grabación de los archivos externos procesados:
* Sugerencia: ($dirProcesados) "
		read respuesta

		#Si la persona no ingreso nada entonces se toma por default la sugerencia
		if [ -z $respuesta ];then
			respuesta=$dirProcesados
		fi
		if [ -n $respuesta ];then
			dirProcesados=$respuesta
		fi	
		validarDirectorios $respuesta
		if [ $cond == "ok" ]; then validarListaDirecciones $respuesta; fi

	done

	PROCDIR=$GRUPO/$dirProcesados
	unset cond

}

#Define el directorio de aceptados
function definirDirAceptados {

	cond="error"

	while [ $cond == "error" ]; do
		cond="ok"	
		echo "
* Defina el directorio de grabación de los archivos externos aceptados:
* Sugerencia: ($dirAceptados) "
		read respuesta

		#Si la persona no ingreso nada entonces se toma por default la sugerencia
		if [ -z $respuesta ];then
			respuesta=$dirAceptados
		fi
		if [ -n $respuesta ];then
			dirAceptados=$respuesta
		fi	
		validarDirectorios $respuesta
		if [ $cond == "ok" ]; then validarListaDirecciones $respuesta; fi

	done

	ACEPDIR=$GRUPO/$dirAceptados
	unset cond

}

#Define el directorio de rechazados
function definirDirRechazados {

	cond="error"

	while [ $cond == "error" ]; do
		cond="ok"	
		echo "
* Defina el directorio de grabación de los archivos externos rechazados:
* Sugerencia: ($dirRechazados) "
		read respuesta

		#Si la persona no ingreso nada entonces se toma por default la sugerencia
		if [ -z $respuesta ];then
			respuesta=$dirRechazados
		fi
		if [ -n $respuesta ];then
			dirRechazados=$respuesta
		fi	
		validarDirectorios $respuesta
		if [ $cond == "ok" ]; then validarListaDirecciones $respuesta; fi

	done

	RECHDIR=$GRUPO/$dirRechazados
	unset cond

}

#Define el datasize
function definirDataSize {

	cond="error"

	while [ $cond == "error" ]; do
		cond="ok"
		echo "
* Defina el espacio mínimo libre para el arribo de archivos externos en Mbytes
* Sugerencia: ($DATASIZE)"
		read respuesta

		#Si la persona no ingreso nada entonces se toma por default la sugerencia
		if [ -z $respuesta ];then
			respuesta=$DATASIZE
		fi

		validarNumerico $respuesta
		
		if [ "$cond"  == "ok" ]; 
		then 
		    validarEspacioEnDisco $respuesta; 
		fi
	done
	unset cond

	DATASIZE=$respuesta

}

#Define el directorio de arribos
function definirDirArribos {

	cond="error"
	
	while [ $cond == "error" ]; do
		cond="ok"	
		echo "
* Defina el directorio de arribo de archivos externos:
* Sugerencia: ($dirArribos) "
		read respuesta

		#Si la persona no ingreso nada entonces se toma por default la sugerencia
		if [ -z $respuesta ];then
			respuesta=$dirArribos
		fi
		if [ -n $respuesta ];then
			dirArribos=$respuesta
		fi	
		validarDirectorios $respuesta
		if [ $cond == "ok" ]; then validarListaDirecciones $respuesta; fi
	done

	ARRIDIR=$GRUPO/$dirArribos
	unset cond

}


#Define el directorio de maestros
function definirDirMaestros {

	cond="error"

	while [ $cond == "error" ]; do
		cond="ok"	
		echo "
* Defina el directorio de instalación de los archivos maestros:
* Sugerencia: ($dirMaestros)"
		read respuesta

		#Si la persona no ingreso nada entonces se toma por default la sugerencia
		if [ -z $respuesta ];then
			respuesta=$dirMaestros
		fi
		if [ -n $respuesta ];then
			dirMaestros=$respuesta
		fi	
		validarDirectorios $respuesta
		if [ $cond == "ok" ]; then validarListaDirecciones $respuesta; fi
	done

	MAEDIR=$GRUPO/$dirMaestros
	unset cond

}


#Define el directorio de ejecutables
function definirDirEjecutables {

	cond="error"

	while [ $cond == "error" ]; do
		cond="ok"	
		echo "
* Defina el directorio de instalación de los ejecutables:
* Sugerencia: ($dirBinarios)"
		read respuesta

		#Si la persona no ingreso nada entonces se toma por default la sugerencia
		if [ -z $respuesta ];then
			respuesta=$dirBinarios
		fi
		if [ -n $respuesta ];then
			dirBinarios=$respuesta
		fi	
		validarDirectorios $respuesta
		if [ $cond == "ok" ]; then validarListaDirecciones $respuesta; fi

	done

	BINDIR=$GRUPO/$dirBinarios
	unset cond


}


function mostrarInformacionInstalacion {

	dirconf=`ls $CONFDIR`
	dirgrupo=`ls $GRUPO`


	mensaje="
	Directorio de Trabajo para la instalación: $GRUPO.

	Archivos y subdirectorios:  
	$dirgrupo


	Librería del Sistema: $CONFDIR.

	Archivos y subdirectorios: 
	$dirconf


	Estado de la instalación: PENDIENTE

	Para completar la instalación Ud. deberá:

	*Definir el directorio de instalación de los ejecutables. 
	*Definir el directorio de instalación de los archivos maestros.
	*Definir el directorio de arribo de archivos externos. 
	*Definir el espacio mínimo libre para el arribo de archivos externos. 
	*Definir el directorio de grabación de los archivos externos rechazados.
	*Definir el directorio de grabación de los archivos externos aceptados.
	*Definir el directorio de grabación de los archivos externos procesados.
	*Definir el directorio de grabación de los reportes de salida.
	*Definir el directorio de grabación de los logs de auditoría.
	*Definir la extensión y tamaño máximo para los archivos de log.

	"

	echo "$mensaje"
	grabarLog "$mensaje"

}

#Inicializa las variables utilizadas para definir los directorios
function inicializarVariablesADefinir {

	dirArribos="arribos"
	dirRechazados="rechazados"
	dirProcesados="procesados"
	dirBinarios="bin"
	dirMaestros="mae"
	dirLog="log"
	dirReportes="reportes"

}

#Modifica el archivo de configuración.
function modificarArchivoConfiguracion {

	#TODO: completar!
}

#Da permisos de ejecucion a los archivos 
function darPermisosDeEjecucion {

	#TODO: completar!
	#chmod 777 $BINDIR/IniciarT.sh

}

#Crea los directorios que no existen
function crearEstructurasDeDirectorios {

	#TODO: completar!
}

#Muestra los path seteados para el archivo de configuracion
function mostrarPaths {
	
	mensaje="
	TP SO7508 1er cuatrimestre 2013. Tema T Copyright (c) Grupo 1

	* Directorio de Trabajo: $GRUPO
	* Librería del Sistema:  $CONFDIR
	* Directorio de arribo de archivos externos: $ARRIDIR
	* Espacio mínimo libre para el arribo de archivos externos: $DATASIZE Mb
	* Directorio de grabación de los archivos externos rechazados: $RECHDIR
	* Directorio de grabación de los archivos externos procesados: $PROCDIR
	* Directorio de grabación de los ejecutables: $BINDIR
	* Directorio de instalación de los archivos maestros: $MAEDIR
	* Directorio de grabación de los logs de auditoría: $LOGDIR
	* Extensión para los archivos de Log: $LOGEXT
	* Tamaño máximo para los archivos de log: $LOGSIZE Kb
	* Directorio de grabación de los reportes de salida: $REPODIR
	"

	echo "$mensaje"
	grabarEnElLog "$mensaje"

}


#Valida si el usuario tiene instalado perl. De ser asi muestra la version del mismo. En caso contrario muestra 
#un mensaje y sale de la instalacion. 
function validarPerl {
	
	pathPerl=`which perl`
	validacionPerl="false"

	if [ "$?" == 0 ]; then
		version=` $pathPerl -v | grep "v[5-9]\."` 
		if [ -n "$version" ]; then
		validacionPerl="true"
		mensaje="
TP SO7508 1er cuatrimestre 2013. Tema T Copyright (c) Grupo 1.
Perl Version: $version
"
		echo "$mensaje"
		
		grabarLog "$mensaje"

		fi
	fi

	if [ $validacionPerl == "false" ]; then
		mensaje="
TP S07508 1er cuatrimestre 2013. Tema T Copyright (C) Grupo 1.
Para instalar el TP es necesario contar con  Perl 5 o superior instalado. Efectúe su instalación e inténtelo nuevamente.
 
Proceso de Instalación Cancelado.
"
		echo "$mensaje"
	
		grabarLog "$mensaje"

		exit 0
	fi

}

#Valida que la respuesta sea S o N
function validarRespuesta {

	respuesta=""

	while [ "$respuesta" != "s" ]
	do
		if [ "$respuesta" == "n" ]; then
			echo "* El proceso de instalación ha sido CANCELADO. *"			
			exit 0 
		fi
		echo "$1"
		read respuesta
	done

}

function mostrarComponentesInstalados {

	dirmae=""
	dirbin=""
	faltanej=""
	faltanmae=""
	faltaarr=""
	faltalog=""
	faltarech=""
	faltatamanio=""
	faltarepo=""
	faltaext=""
	faltatamaniolog=""
	faltaproc=""


	if [ "$ejecutables" -ne "0" ];
	then
		dirbin=`ls $BINDIR` 
	fi

	if [ "$maestros" -ne "0" ];
	then
		dirmae=`ls $MAEDIR`
	fi


	if [ "$ejecutables" -eq "0" ];
	then
		faltanej="Faltan todos los archivos ejecutables necesarios, se copiaran los mismos del directorio de instalación."
	fi


	if [ "$maestros" -eq "0" ];
	then
		faltanmae="Faltan todos los archivos maestros necesarios, se copiaran los mismos del directorio de instalación."

	fi

	if [ $arribos -gt 0 ]; 
	then 

		faltaarr="No se encontró el directorio de arribos especificado en el archivo de configuracion.
	Se toma por default:  ARRIDIR=\"$ARRIDIR\""

	fi

	if [ $rechazados -gt 0 ];
	then
	
		faltarech="No se encontró el directorio de los archivos rechazados especificado en el archivo de configuracion.
	Se toma por default:  RECHDIR=\"$RECHDIR\""

	fi

	if [ $procesados -gt 0 ];
	then
	
		faltaproc="No se encontró el directorio de los archivos procesados especificado en el archivo de configuracion.
	Se toma por default:  PROCDIR=\"$PROCDIR\""

	fi

	if [ $reportes -gt 0 ];
	then
	
		faltarepo="No se encontró el directorio de los archivos de reporte especificado en el archivo de configuracion.
	Se toma por default:  REPODIR=\"$REPODIR\""

	fi

	if [ $log -gt 0 ]; 
	then 

		faltalog="No se encontró el directorio del archivo de Log especificado en el archivo de configuracion.
	Se toma por default:  LOGDIR=\"$LOGDIR\""

	fi

	if [ $tamanio -gt 0 ];
	then

		faltatamanio="No se encontró el tamaño mínimo de espacio en disco para la aplicación.
	Se toma por default:  DATASIZE=$DATASIZE"

	fi
	 
	if [ $extension -gt 0 ];
	then
	
		faltaext="No se encontró la extensión del archivo de log.
	Se toma por default:  LOGEXT=$LOGEXT"

	fi

	if [ $tamanioLog -gt 0 ];
	then

		faltatamaniolog="No se encontró el tamaño máximo del archivo de Log.
	Se toma por default:  LOGSIZE=$LOGSIZE"

	fi



	mensaje="
	TP SO7508 1er cuatrimestre 2013. Tema T Copyright (c) Grupo 1.

	Componentes existentes:

	Directorio de instalación de los ejecutables: $BINDIR 

	Archivos:  

	$dirbin


	Directorio de instalación de los archivos maestros: $MAEDIR

	Archivos: 

	$dirmae


	Componentes faltantes: 

	$faltanej
	$faltanmae
	$faltaarr
	$faltarech
	$faltaproc
	$faltarepo
	$faltaext
	$faltalog
	$faltatamanio
	$faltatamaniolog
	"
	echo "$mensaje"
	grabarEnElLog "$mensaje"
	

}


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

	mostrarComponentesInstalados

	echo "
Estado de la instalación: INCOMPLETA "
	
	validarRespuesta "Desea completar la instalación? [s/n]"

	validarPerl

	mostrarPaths

	echo "Estado de la instalación: LISTA" 

	validarRespuesta "Iniciando Instalación. Está UD. seguro? [s/n]" 

	crearEstructurasDeDirectorios

	#TODO: ver!
	#moverArchivos

	darPermisosDeEjecucion

	modificarArchivoConfiguracion
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

	validarRespuesta "¿Desea continuar con la instalación? [s/n]"

	inicializarVariablesADefinir

	while [ "$respuesta1" != "s" ]
	do
		clear
		
		validarPerl

		mostrarInformacionInstalacion		

		listaDirecciones=()

		definirDirEjecutables

		definirDirMaestros

		definirDirArribos
		
		definirDataSize
		
		definirDirRechazados

		definirDirAceptados

		definirDirProcesados

		definirDirReportes
		
		definirDirLogAuditoria

		definirLogExt		
		
		clear

		mostrarPaths

		echo "Estado de la instalación: LISTA" 
		
		echo "¿Los datos ingresados son correctos? [s/n]"
				
		read respuesta1
	done

	validarRespuesta "Iniciando Instalación. Está UD. seguro? [s/n]" 

	crearEstructurasDeDirectorios

	moverArchivos
	
	establecerPermisosDeEjecucion 
	
	modificarArchivoConfiguracion
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
