
#Aca iria la parte de inicializar el archivo log con GlogX

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


#Funcion principal

function main {

  BINDIR="/home/nacho/Escritorio/PruebasSSOO/Comandos"
  MAEDIR="/home/nacho/Escritorio/PruebasSSOO/Maestros"
  CONFDIR="/home/nacho/Escritorio/PruebasSSOO/Config"
  chequearComandos
  chequearMaestros
  chequearTablas
  
}

main
