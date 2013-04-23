
#Inicializar el archivo log con GlogX

function grabarLog {
 cmd="[InicioX]" 
 msj="Inicio de Ejecución"
 tmsj="I"

 #GlogX "$cmd" "$msj" "$tmsj"
 
 echo $cmd $msj $tmsj

}

# Chequea que existan los comandos en la carpeta BINDIR, 
# y tengan los permisos de ejecucion seteados,sino los setea.

function chequearComandos {

 for i in InstalarX.sh InicioX.sh DetectaX.sh Interprete.sh Reporte.pl MoverX.sh StartX.sh StopX.sh GlogX.sh VlogX.sh
   do
     if [ -f $BINDIR/$i ]; then
          echo -e "El comando $i existe\n"
 
          if [ -x $BINDIR/$i ]; then 
            echo -e "y tiene permisos de ejecucion\n"
          else 
            chmod 777 $BINDIR/$i
            echo `ls -l $BINDIR/$i`
          fi
         
     else
        echo -e "El comando $i no existe\n" 
     fi
   done  
}

# Chequea que existan los maestros en la carpeta MAEDIR, 
# y tengan los permisos de lectura seteados,sino los setea.

function chequearMaestros {

 for i in PPI.mae p-s.mae
   do
     if [ -f $MAEDIR/$i ]; then
          echo -e "El archivo maestro $i existe\n"
 
          if [ -r $MAEDIR/$i ] &&  ! [ -w $MAEDIR/$i ]; then 
            echo -e "y tiene permisos de lectura, pero no escritura\n"
          else 
            chmod 444 $MAEDIR/$i
            echo `ls -l $MAEDIR/$i`
          fi
         
     else
        echo -e "El archivo maestro $i no existe\n" 
     fi
   done  

}

# Chequea que existan las tablas en la carpeta CONFDIR, 
# y tengan los permisos de lectura seteados,sino los setea.

function chequearTablas {

 for i in T2.tab T1.tab
   do
     if [ -f $CONFDIR/$i ]; then
          echo -e "El archivo maestro $i existe\n"
 
          if [ -r $CONFDIR/$i ] &&  ! [ -w $CONFDIR/$i ]; then 
            echo -e "y tiene permisos de lectura, pero no escritura\n"
          else 
            chmod 444 $CONFDIR/$i
            echo `ls -l $CONFDIR/$i`
          fi
         
     else
        echo -e "El archivo maestro $i no existe\n"
     fi
   done  

}


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

function chequearPaths {

   exec=`echo $PATH | grep "$BINDIR"`

   if [ -z $exec ]; then
    echo "No esta el path de ejecutables, agregando..."
    PATH=$PATH:$BINDIR
    echo -e "Agregado\n"
    echo $PATH
   else
    echo "Esta el path de ejecutables"
    echo $PATH
   fi 
}


#Funcion principal

function main {

  confFile=InstalX.conf 
  CONFDIR="/home/nacho/Escritorio/PruebasSSOO/Config"
  
  leerVariablesDeConfiguracion $CONFDIR/$confFile
  #chequearComandos
  #chequearMaestros
  #chequearTablas
  chequearPaths
  

}

main
