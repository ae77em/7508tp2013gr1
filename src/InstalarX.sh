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

#Lee las variables del archivo de configuración.
function leerVariablesDeConfiguracion {

	GRUPO=`grep "GRUPO" "$1" | cut -d"=" -f 2`
	BINDIR=`grep "BINDIR" "$1" | cut -d"=" -f 2`
	MAEDIR=`grep "MAEDIR" "$1" | cut -d"=" -f 2`
	ARRIDIR=`grep "ARRIDIR" "$1" | cut -d"=" -f 2`
	ACEPDIR=`grep "ACEPDIR" "$1" | cut -d"=" -f 2`
	RECHDIR=`grep "RECHDIR" "$1" | cut -d"=" -f 2`
	PROCDIR=`grep "PROCDIR" "$1" | cut -d"=" -f 2`
	REPODIR=`grep "REPODIR" "$1" | cut -d"=" -f 2`
	LOGDIR=`grep "LOGDIR" "$1" | cut -d"=" -f 2`
	LOGEXT=`grep "LOGEXT" "$1" | cut -d"=" -f 2`
	LOGSIZE=`grep "LOGSIZE" "$1" | cut -d"=" -f 2`
	DATASIZE=`grep "DATASIZE" "$1" | cut -d"=" -f 2`

}

#Valida la extencion del archivo de log
function validarExtensionLog {
	
	res=`echo "$1" | grep "^[.]"`
	if [  "$1" != "$res" ]; then
		echo "ERROR - La extensión del log debe comenzar con un punto (.)"
		cond="error"
	fi
	unset res
}

#Define el tamanio maximo para los archivos de log
function definirLogSize {
	
	cond="error"

	while [ $cond == "error" ]; do
		cond="ok"
		#18 - Definir el tamanio maximo para los archivos de log
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

	LOGSIZE=$maxSize
	unset cond

}

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
	
	LOGEXT=$extLog
	unset cond

}

#Define el directorio del log de auditoria
function definirDirLog {


	cond="error"

	while [ $cond == "error" ]; do
		cond="ok"	
		echo "
* Defina el directorio de grabación de los logs:
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

#Valida espacio libre en disco para archivos externos
function validarEspacioEnDisco {

	espacio_libre=`df | grep "/\$" | awk '{ print $4 }'`

	espacio_libre_kb=$[ $espacio_libre * 1024 ]   #paso de MB a KB
	espacio_requerido=$[ $1 * 1024 ]   #paso de MB a KB


	if [ $espacio_requerido -gt $espacio_libre_kb ]; then
		
		mensaje="
Insuficiente espacio en disco. 
Espacio disponible: $espacio_libre Mb. 
Espacio requerido $1 Mb
Cancele la instalación e inténtelo más tarde o vuelva a intentarlo con otro valor.
	"
			
		echo "$mensaje"
		grabarLog "$mensaje"		
		cond="error"
	fi

}

#Valida que lo ingresado sea un valor numerico entero y mayor a cero
function validarNumerico {

	res=`echo "$1" | grep "[^0-9]"`
	if [ "$1" == "$res" ]; then
		echo "ERROR -  \"$1\" tiene que ser un número entero."
		cond="error"
	fi
	if [ "$1" -eq "0" ];then
		echo "ERROR - el valor ingresado no puede ser cero."
		cond="error"
	fi

	unset res
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
		    #11 - Verificar espacio en disco
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

#Valida que no se pueda elegir mas de una vez el mismo directorio
function validarListaDirecciones {

	for i in ${listaDirecciones[*]}; do
		if [ "$i" == "$1" ]; then
		echo "ERROR - No puede elegir más de una vez el mismo directorio"
		cond="error"	
		fi
	done

	listaDirecciones=(${listaDirecciones[*]} $1)

}


#Valida que el directorio no exista
function validarDirectorios {

	if [ -d "$1" ]; then
		echo "ERROR - el directorio ya existe"
		cond="error"
	fi

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

	dirBinarios="bin"
	dirMaestros="mae"
	dirArribos="arribos"
	dirAceptados="aceptados"
	dirRechazados="rechazados"
	dirProcesados="procesados"
	dirReportes="reportes"
	dirLog="log"

}

#Modifica el archivo de configuración.
function modificarArchivoConfiguracion {

	#TODO: completar!
	echo "
Actualizando la configuración del sistema..."

	fecha=`date +%d/%m/%y`
	hora=`date +%R`

	fecha="${fecha} $hora"

	usuario=`who | awk '{ print $1 }'`

	#TODO: faltan variables para los mae

	GRUPO="${GRUPO}=$usuario=$fecha"
	BINDIR="${BINDIR}=$usuario=$fecha"
	MAEDIR="${MAEDIR}=$usuario=$fecha"
	ARRIDIR="${ARRIDIR}=$usuario=$fecha"
	ACEPDIR="${ACEPDIR}=$usuario=$fecha"
	RECHDIR="${RECHDIR}=$usuario=$fecha"
	PROCDIR="${PROCDIR}=$usuario=$fecha"
	REPODIR="${REPODIR}=$usuario=$fecha"
	LOGDIR="${LOGDIR}=$usuario=$fecha"
	LOGEXT="${LOGEXT}=$usuario=$fecha"
	LOGSIZE="${LOGSIZE}=$usuario=$fecha"
	DATASIZE="${DATASIZE}=$usuario=$fecha"


	echo "
GRUPO=$GRUPO
BINDIR=$BINDIR
MAEDIR=$MAEDIR
ARRIDIR=$ARRIDIR
ACEPDIR=$ACEPDIR
RECHDIR=$RECHDIR
PROCDIR=$PROCDIR
REPODIR=$REPODIR
LOGDIR=$LOGDIR
LOGEXT=$LOGEXT
LOGSIZE=$LOGSIZE
DATASIZE=$DATASIZE
	"> $CONFDIR/$confFile

}

#Da permisos de ejecucion a los archivos 
function darPermisosDeEjecucion {

	#TODO: cambiar nombre de los archivos por los archivos de BINDIR
	chmod 777 $BINDIR/ej1.sh
	chmod 777 $BINDIR/ej2.sh
	chmod 777 $BINDIR/ej3.sh

}

#Mueve archivos maestros al directorio MAEDIR.
#Mueve la tabla de separadores y la tabla de campos al directorio CONFDIR
#Mueve los ejecutables y funciones al directorio BINDIR
function moverArchivos {

	echo "
Instalando Archivos Maestros..."

	#TODO: cambiar nombre de los .mae
	for i in ej1.mae ej2.mae ej3.mae
	do
		if [ -f "$grupo/instalacion/mae/$i" ]; then
			 
			source "$grupo/instalacion/bin/MoverX.sh"; MoverX  "$grupo/instalacion/mae/$i" "$MAEDIR" "InstalarX.sh"

			resultado=$?

			#echo "RESULTADO: $resultado"
		 	
			if [ "$resultado" -ne 0 ]; then

				mensaje="[Instalar.sh] Ha ocurrido un error al mover $i"
	
				echo "$mensaje"

				grabarLog "$mensaje"
			fi

		else
			echo -e "El comando $i no existe\n" 
		fi
	done  

	#TODO: falta mover la tabla de separadores y la tabla de campos 

		echo "
Instalando Programas y Funciones..."

	#TODO: cambiar nombre de los .sh
	for i in ej1.sh ej2.sh ej3.sh
	do
		if [ -f "$grupo/instalacion/bin/$i" ]; then
			 
			source "$grupo/instalacion/bin/MoverX.sh"; MoverX  "$grupo/instalacion/bin/$i" "$BINDIR" "InstalarX.sh"
		 	
			resultado=$?

			#echo "RESULTADO: $resultado"

			if [ "$resultado" -ne 0 ]; then

				mensaje="[Instalar.sh] Ha ocurrido un error al mover $i"
	
				echo "$mensaje"

				grabarLog "$mensaje"
			fi
				
		else
			echo -e "El comando $i no existe\n" 
		fi
	done  
}

#Crea los directorios que no existen
function crearEstructurasDeDirectorios {

	echo "Creando Estructuras de Directorio....
"
	listaDirectorios=( $BINDIR $MAEDIR $ARRIDIR $ACEPDIR $RECHDIR $PROCDIR $REPODIR $LOGDIR)

	for i in ${listaDirectorios[*]}; do
		echo "Creando $i..."		
		mkdir -p $i
	done

}

#Muestra los path seteados para el archivo de configuracion
function mostrarPaths {
	
	mensaje="
TP SO7508 1er cuatrimestre 2013. Tema T Copyright (c) Grupo 01

* Directorio de Trabajo: $GRUPO
* Librería del Sistema:  $CONFDIR
* Directorio de grabación de los ejecutables: $BINDIR
* Directorio de instalación de los archivos maestros: $MAEDIR
* Directorio de arribo de archivos externos: $ARRIDIR
* Espacio mínimo libre para el arribo de archivos externos: $DATASIZE Mb
* Directorio de grabación de los archivos externos aceptados: $ACEPDIR
* Directorio de grabación de los archivos externos rechazados: $RECHDIR
* Directorio de grabación de los archivos externos procesados: $PROCDIR
* Directorio de grabación de los reportes de salida: $REPODIR
* Directorio de grabación de los logs de auditoría: $LOGDIR
* Extensión para los archivos de Log: $LOGEXT
* Tamaño máximo para los archivos de log: $LOGSIZE Kb

	"	

	echo "$mensaje"
	grabarLog "$mensaje"

}


#Valida si el usuario tiene instalado perl. De ser asi muestra la version del mismo. En caso contrario muestra 
#un mensaje y sale de la instalacion. 
function validarPerl {
	
	pathPerl=`which perl`
	validacionPerl="false"

	if [ "$?" == 0 ]; then
	#6.2 - Perl esta instalado. Mostrar y grabar en el log un mensaje informativo con la version de Perl que se encuentra instalada.
		version=` $pathPerl -v | grep "v[5-9]\."` 
		if [ -n "$version" ]; then
		validacionPerl="true"
		mensaje="
TP SO7508 1er cuatrimestre 2013. Tema T Copyright (c) Grupo 01.
Perl Version: $version
	"
		echo "$mensaje"
		
		grabarLog "$mensaje"

		fi
	fi

	if [ $validacionPerl == "false" ]; then
	#6.1 - Validacion de Perl da error. Mostrar y grabar en el log.
		mensaje="
TP S07508 1er cuatrimestre 2013. Tema T Copyright (C) Grupo 01.
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
	faltaacep=""
	faltarech=""
	faltaproc=""
	faltarepo=""
	faltalog=""
	faltaext=""
	faltatamaniolog=""
	faltatamanio=""


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

	if [ $aceptados -gt 0 ]; 
	then 

		faltaacep="No se encontró el directorio de los archivos aceptados especificado en el archivo de configuracion.
	Se toma por default:  ACEPDIR=\"$ACEPDIR\""

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

	if [ $tamanio -gt 0 ];
	then

		faltatamanio="No se encontró el tamaño mínimo de espacio en disco para la aplicación.
	Se toma por default:  DATASIZE=$DATASIZE"

	fi
	 

	mensaje="
TP SO7508 1er cuatrimestre 2013. Tema T Copyright (c) Grupo 01.

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
$faltaacep
$faltarech
$faltaproc
$faltarepo
$faltalog
$faltaext
$faltatamaniolog
$faltatamanio

	"
	echo "$mensaje"
	grabarLog "$mensaje"	

}


function mostrarMensajeInstalacionFinalizada {

	dirconf=`ls $CONFDIR`
	dirbin=`ls $BINDIR`
	dirmae=`ls $MAEDIR`

	mensaje="
TP SO7508 Primer Cuatrimestre 2013. Tema X Copyright (c) Grupo 01.

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
Logs de auditoría del Sistema: $LOGDIR/InstalarX.$LOGEXT

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
	
	#4.3 - El usuario indico SI por lo que paso a chequear que Perl este instalado
	validarPerl

	#4.3.3 - Mostrar los valores de instalacion
	mostrarPaths

	echo "Estado de la instalación: LISTA" 

	#20 - Confirmar Inicio de Instalacion
	validarRespuesta "Iniciando Instalación. ¿Está UD. seguro? [s/n]" 

	#21 - Instalacion
	crearEstructurasDeDirectorios

	#21.2 - Mueve archivos maestros al directorio MAEDIR.
	#21.3 - Mueve la tabla de separadores y la tabla de campos al directorio CONFDIR
	#21.4 - Mueve los ejecutables y funciones al directorio BINDIR
	moverArchivos

	darPermisosDeEjecucion
	
	# 21.5 - Actualizar el archivo de configuracion.
	modificarArchivoConfiguracion

	#22 - Borrar los archivos temporarios, si los hubiese generado. NO APLICA
}

#Verifica la existencia de una cantidad de Xmb disponibles para la instalacion del tp. Si no lo esta asigna 100mb.
function chequearDATASIZE {

	if [ -z "$DATASIZE" ]; then
		DATASIZE=100
		tamanio=1
		cantErrores=$[ $cantErrores + 1 ]
	fi

}

#Verifica la existencia de una cantidad de X kb de longitud para el archivo de log. Si no lo esta asigna 400kb.
function chequearLOGSIZE {

	if [ -z "$LOGSIZE" ]; then
		LOGSIZE=400
		tamanioLog=1
		cantErrores=$[ $cantErrores + 1 ]
	fi

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

#Verifica la existencia de directorio de aceptados definido en el archivo de configuracion 
function chequearACEPDIR {

	if [ -z "$ACEPDIR" ]; then
		ACEPDIR="$grupo/aceptados"
		aceptados=1
		cantErrores=$[ $cantErrores + 1]
	else
		if ! [ -d "$ACEPDIR" ]; then
			aceptados=1
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
	
	chequearBINDIR
	chequearMAEDIR
	chequearARRIDIR
	chequearACEPDIR
	chequearRECHDIR
	chequearPROCDIR
	chequearREPODIR
	chequearLOGDIR
	chequearLOGEXT
	chequearLOGSIZE
	chequearDATASIZE

}

#Muestra mensaje inicio instalacion
function mostrarMensajeInicioInstalacion {
	echo '
************************************************************************
* TP SO7508 Primer Cuatrimestre 2013. Tema X Copyright (c) Grupo 01
* A T E N C I O N: Al instalar TP SO7508 Primer Cuatrimestre 2013 UD.
* expresa aceptar los términos y condiciones del "ACUERDO DE LICENCIA DE
* SOFTWARE" incluído en este paquete.
************************************************************************
'
}

#Comienza la instalcion
function instalar {

	#5.0 - Mostrar mensaje de acuerdo de licencia de software
	mostrarMensajeInicioInstalacion

	validarRespuesta "¿Desea continuar con la instalación? [s/n]"

	#Son las sugerencias que se dan al usuario a la hora de definir los directorios
	inicializarVariablesADefinir

	while [ "$respuesta1" != "s" ]
	do
		clear
		
		#6 - Chequear que Perl este instalado
		validarPerl

		mostrarInformacionInstalacion		

		listaDirecciones=()

		#7 - Definir el directorio de instalacion de los ejecutables
		definirDirEjecutables

		#8 - Definir el directorio de instalacion de los archivos maestros
		definirDirMaestros

		#9 - Definir el directorio de arribo de archivos externos
		definirDirArribos
		
		#10 - Definir el espacio minimo libre para el arribo de archivos externos
		# Dentro de definirDataSize verifico espacio en disco (11 - Verificar espacio en disco)
		definirDataSize
		
		#12 - Definir el directorio de grabacion de los archivos rechazados
		definirDirRechazados

		#13 - Definir el directorio de grabacion de los archivos aceptados
		definirDirAceptados

		#14 - Definir el directorio de trabajo principal del proceso interprete
		definirDirProcesados

		#15 - Definir el directorio de grabacion de los reportes de salida
		definirDirReportes
		
		#16 - Definir el directorio de logs para los comandos
		definirDirLog

		#17 - Definir la extension para los archivos de log
		definirLogExt		

		#18 - Definir el tamanio maximo para los archivos de log
		definirLogSize
		
		clear

		#19 - Mostrar estructura de directorios resultante y valores de parametros de configuracion
		mostrarPaths

		echo "Estado de la instalación: LISTA" 
		
		echo "¿Los datos ingresados son correctos? [s/n]"
				
		read respuesta1
	done

	#20 - Confirmar inicio de instalacion
	validarRespuesta "Iniciando Instalación. Está UD. seguro? [s/n]" 

	#21 - Instalacion 
	#21.1 - Crear las estructuras de directorio requeridas.
	crearEstructurasDeDirectorios

	#21.2 - Mover los archivos maestros al directorio MAEDIR
	#21.3 - Mover la tabla de separadores y la tabla de campos al directorio CONFDIR
	#21.4 - Mover los ejecutables y funciones al directorio BINDIR
	moverArchivos
	
	darPermisosDeEjecucion 
	
	#21.5 - Actualizar el archivo de configuracion
	modificarArchivoConfiguracion

	#22 - Borrar archivos temporarios, si los hubiese generado. NO APLICA
}

#Inicializa las variables del directorio del archivo de configuracion
function inicializarVariablesDefault {

	GRUPO=$grupo
	CONFDIR=$GRUPO/conf
	BINDIR=$GRUPO/bin
	MAEDIR=$GRUPO/mae
	ARRIDIR=$GRUPO/arribos
	ACEPDIR=$GRUPO/aceptados
	RECHDIR=$GRUPO/rechazados
	PROCDIR=$GRUPO/procesados
	REPODIR=$GRUPO/reportes
	LOGDIR=$GRUPO/log
	LOGEXT=.log
	# Maximo tamanio de archivo de log = 400kb
	LOGSIZE=400
	# 100mb de espacio libre para archivos externos
	DATASIZE=100
	
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
	#chmod 777 -Tiene que haber un handler para el log. GlogX.sh y VlogX.sh.
	
} 

#Graba mensajes de inicio en el log
function mensajesInicioLog {

	mensaje="[InstalarX] Inicio de Ejecución"
	echo "$mensaje"
	grabarLog "$mensaje"
	mensaje="[InstalarX] Log del Comando InstalarX: $CONFDIR/$logFile"
	echo "$mensaje"
	grabarLog "$mensaje"
	mensaje="Directorio de Configuración: $CONFDIR"
	echo "$mensaje"
	grabarLog "$mensaje"

}

#Chequea la existencia de archivos maestros en el directorio maestros para poder efectuar la instalación.
function testArchivosMaestros  {

	#TODO: cambiar nombre de los maestros
	MAESTROS=(ej1.mae ej2.mae ej3.mae)

	for i in ${MAESTROS[*]}; do
		if ! [ -f $1/"$i" ]; then
			echo "* Falta el archivo maestro: \"$i\""
			cantErrores=$[ $cantErrores + 1 ]	
		fi
	done

}


#Chequea la existencia de los archivos ejecutables en el directorio de ejecutables para poder efectuar la instalación.
function testComandos  {

	#TODO: cambiar nombre de los maestros
	EJECUTABLES=(ej1.sh ej2.sh ej3.sh)

	for i in ${EJECUTABLES[*]}; do
		if ! [ -f $1/"$i" ]; then
			echo "* Falta el ejecutable: \"$i\""
			cantErrores=$[ $cantErrores + 1 ]	
		fi
	done

}

#Verifico la existencia de los archivos necesarios para realizar la instalacion. Maestros y Ejecutables.
function verificarArchivosInstalacion {


	cantErrores=0

	testComandos "$grupo/instalacion/bin"
	testArchivosMaestros "$grupo/instalacion/mae"
	
	if [ $cantErrores -gt 0 ]; then
		echo "
Proceso de Instalación cancelado.
Asegúrese de que contar con los archivos arriba mencionados y vuelva a intentarlo."
		exit 0
	fi

}

function main {

	clear
	cd ..

	#grupo: path donde se encuentra el tp ../grupo01/
	grupo="$PWD"

	#CONFDIR: ubicacion del directorio de configuracion
	CONFDIR="$grupo/conf"
	
	#confFile: nombre archivo configuracion
	confFile="InstalarX.conf"

	#logFile: nombre archivo de log
	logFile="InstalarX.log"

	echo "************************************************************************
*   Bienvenido al Asistente de instalación del sistema ControlX        *
*   TP SO7508 Primer Cuatrimestre 2013. Tema X Copyright (c) Grupo 01  *
************************************************************************"

	#Verifico la existencia de archivos maestros y de los ejecutables
	verificarArchivosInstalacion

	crearDirectorioArchivoConfiguracion
	#1 - Inicializar archivo de log
	crearLog
	#2 - Mostrar (y grabar en el log) donde se graba el log de la instalacion
	#3 - Mostrar (y grabar en el log) el nombre del directorio de configuracion
	mensajesInicioLog

	#4 - Detectar si el paquete ControlX o alguno de sus componentes ya esta instalado
	# Cuento la cantidad de lines del archivo de configuracion
	cantLineas=$(wc -l $CONFDIR/$confFile | awk '{print $1}')

	#Si tiene 0 lineas el archivo de configuración es porque no tiene nada instalado
	if [ "$cantLineas" -eq "0" ];
	then 
		#5 - Aceptacion de terminos y condiciones
		inicializarVariablesDefault
		instalar
	else
		#4.0 - Verifico instalacion previa
		leerVariablesDeConfiguracion "$CONFDIR/$confFile"
		
		cantErrores=0
		maestros=1
		ejecutables=1
		arribos=0
		aceptados=0
		rechazados=0
		procesados=0
		reportes=0
		log=0
		extension=0		
		tamanio=0
		tamanioLog=0

		chequearComponentesInstalados

		if [ $cantErrores -gt 0 ]; then 
			#4.2 - Si falta algun componente
			completarInstalacion
		else
			#4.1 - Si esta completo
			mostrarMensajeInstalacionFinalizada
		fi
	fi

	#23 - Mostrar mensaje de fin de instalacion
	echo "[InstalarX] Instalación Finalizada"

	#24 - FIN
	#TODO: hacer!
	#Cerrar el archivo de log
	#Terminar el proceso	

}
main
