
#Aca iria la parte de inicializar el archivo log con GlogX

function grabarLog {
 cmd="[InicioX]" 
 msj="Inicio de Ejecución"
 tmsj="I"

 #GlogX "$cmd" "$msj" "$tmsj" 
 
 echo $cmd $msj $tmsj

}

#Chequea que existan los comandos en la carpeta BINDIR, y tengan los permisos de ejecucion seteados.

function chequearComandos {

 for i in InstalarX.sh InicioX.sh DetectaX.sh Interprete.sh ReporteX.sh MoverX.sh StartX.sh StopX.sh GlogX.sh VlogX.sh
   do
     if [ -f $BINDIR/$i ]; then
          echo "El comando $i existe"
 
          if [ -x $BINDIR/$i ]; then 
            echo "y tiene permisos de ejecucion"
          else 
            chmod +x $BINDIR/$i
            echo `ls -l $BINDIR/$i` 
          fi
         
     else
        echo "El comando $i no existe"
     fi
   done  
}


#Funcion principal

function main {

  BINDIR=$PWD
  chequearComandos
}

main
