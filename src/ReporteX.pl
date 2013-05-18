#!/usr/bin/perl

########################
#                      #
#  VARIABLES GLOBALES  #
#                      #
#########################FFFFFF

$MAEDIR="";		# Directorio de archivos maestros
$PROCDIR="";	# Directorio de archivos para procesamiento
$REPODIR="";	# Directorio donde se guardan los reportes

$PAIS_ID="";    # id del pais
$PAIS_DESC="";  # descripcion del pais
$SIS_ID="";		# id del sistema
$CTB_ANIO="";   # año contable
$CTB_MES="";    # mes contable
$PRES_ID="";    # id del préstamo

$MT_PRES=0;     # monto del préstamo
$MT_IMPAGO=0;   # monto impago
$MT_INDE=0; 	# monto intereses devengados
$MT_INNODE=0;   # monto intereses no devengados
$MT_DEB=0;  	# monto debitado
$MT_REST=0; 	# monto restante
$GUARDAR_REPORTE=0; # flag para saber si guardar el reporte
$VALOR_DIFERENCIA=0;# diferencia para los comandos de diferencia

$PERIODO="";
$RANGO_PERIODOS="";
$COMANDOS_USADOS="";
$USUARIO="";

%registros_ppi;
%registros_prestamos;

@reg_ppi;
@reg_p_p;

@reporte;

################
#              #
#  SUBRUTINAS  #
#              #
################

#
# Me fijo que esten inicializadas las variables de ambiente
#
sub verificarAmbiente{
	
	if ( not ( 	
				$ENV{'GRUPO'} and $ENV{'BINDIR'} and $ENV{'MAEDIR'} and $ENV{'ARRIDIR'} and $ENV{'ACEPDIR'} and $ENV{'RECHDIR'}
				and $ENV{'PROCDIR'}	and $ENV{'REPODIR'} and $ENV{'LOGDIR'} and $ENV{'LOGEXT'} and $ENV{'LOGSIZE'} and $ENV{'DATASIZE'}
			)
		)
	{
		print "El reporte no se puede mostrar ya que el ambiente no está correctamente inicializado.\n";
		return 0;
	}
	else
	{
		return 1;
	}
}

#
# Inicializo las variables globales
#
sub inicializarGlobales{
    
    $PAIS_ID="";    # id del pais
    $PAIS_DESC="";  # descripcion del pais
    $SIS_ID="";     # id del sistema
    $CTB_ANIO="";   # año contable
    $CTB_MES="";    # mes contable
    $PRES_ID="";    # id del préstamo

    $MT_PRES=0;     # monto del préstamo
    $MT_IMPAGO=0;   # monto impago
    $MT_INDE=0;     # monto intereses devengados
    $MT_INNODE=0;   # monto intereses no devengados
    $MT_DEB=0;      # monto debitado
    $MT_REST=0;     # monto restante
    $GUARDAR_REPORTE=0; # flag para saber si guardar el reporte
    $VALOR_DIFERENCIA=0;

    $PERIODO="";
    $RANGO_PERIODOS="";
    $COMANDOS_USADOS="";
    
    %registros_ppi=();
    %registros_prestamos=();

    @reporte=();
    @reg_ppi=();
	@reg_p_p=();
}

#
# Se fija si la respuesta es si o no, o si es invalida
#
sub normalizarValorDeUnDigito{
	
	my $valor = @_[0];
		
	if( int($valor) < 10 )
	{
		$valor = '0'.int($valor);
	}
	
	return $valor;
}

#
# Se fija si la respuesta es si o no, o si es invalida
#
sub validarRespuesta{
    
    my $rta = @_[0];
    
    if ( uc($rta) eq uc("n") )
    {
        return(0);
        last;
    }
    elsif ( uc($rta) eq uc("s") ) 
    {
        return(1);
    }
    else
    {
        print "¡Respuesta incorrecta!";
        return(-1);
    }
}

#
# Valida que la fecha ingresada tenga formato correcto
#
sub validarPeriodo{
	
	my $fecha = @_[0];
	
	my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
	$year += 1900;
	
	# obtengo las distintas partes de la fecha
	my $anio = substr $fecha, 0, 4;
	my $separador = substr $fecha, 4, 1;
	my $mes = substr $fecha, 5, 2;
	
	# si cualquiera de los dos no es una cadena de números
	# o no tiene la barra / en la fecha 
	if ( length( $fecha ) != 7 )
	{
		# devuelvo falso
		return 0;
	}
	if ( $anio !~ /^-?\d+\z/ )
	{
		# devuelvo falso
		return 0;		
	}
	if ( int($anio) > int($year) or int($anio) < 1900 )
	{
		# devuelvo falso
		return 0;
	}
	if ( $mes !~ /^-?\d+\z/ )
	{
		# devuelvo falso
		return 0;		
	}
	if ( int($mes) > 12 or int($mes) < 1 )
	{
		# devuelvo falso
		return 0;
	}
	if ( $separador ne "/" )
	{
		# devuelvo falso
		return 0;
	}
	
	# devuelvo ok
	return 1;
}

#
# Valida que el rango de fechas ingresada tenga formato correcto
#
sub validarRangoPeriodos{
	
	my $rango_fechas = @_[0];
	
	# obtengo las distintas partes de la fecha
	my $fecha1 = substr $rango_fechas, 0, 7;
	my $separador = substr $rango_fechas, 7, 1;
	my $fecha2 = substr $rango_fechas, 8, 7;
	
	# si cualquiera de los dos no es una fecha
	# o no tiene el guión - como separador
	if ( length( $rango_fechas ) != 15 )
	{
		# devuelvo falso
		return 0;
	}
	if ( not &validarPeriodo( $fecha1 ) )
	{
		# devuelvo falso
		return 0;
	}
	if ( not &validarPeriodo( $fecha2 ) )
	{
		# devuelvo falso
		return 0;
	}
	if ( $separador ne "-" )
	{
		# devuelvo falso
		return 0;
	}
	
	# devuelvo ok por default
	return 1;
	
}

#
# Confirma si sigue la ejecucion del comando actual
#
sub confirma{
    
    my $mensaje = @_[0];
    my $respuesta = -1;
    while ( $respuesta == -1 )
    {
        print $mensaje;
        $rta = <STDIN>;
        chomp($rta);
        
        $respuesta = &validarRespuesta( $rta );     
    }
    return $respuesta;
}

sub buscarDatosPais{
    
    my @valores_registro;
    
    # obtengo los valores del archivo de paises y  sistemas
    open (P_S,"$MAEDIR/p-s.mae");
    
    # busco el codigo del pais ingresado
    while (<P_S>)
    {
        @valores_registro = split('-',$_);

        if( uc(@valores_registro[1]) eq uc($PAIS_DESC)  )
        {
            $PAIS_ID = @valores_registro[0];
            $PAIS_DESC = @valores_registro[1];
            last;
        }           
    }
}

#
# Obtiene los directorios de los archivos maestros y de procesamiento,
# y donde se guardaran los reportes.
#
sub obtenerDirectorios{
	
	my @valores_registro;
	my $cantDir = 0;
	
	# Abro el archivo InstalarX.conf
	open(CONF,"../conf/InstalarX.conf") || die "ERROR: No puedo abrir el fichero InstalarX.conf\n";
	
	# obtengo el maedir, procdir y repodir
	while (<CONF>)
	{
		# quito eol
		chomp;
		
		@valores_registro = split("=",$_);
		if (@valores_registro[0] eq "MAEDIR")
		{
			$MAEDIR = @valores_registro[1];
			$USUARIO = @valores_registro[2];
			$cantDir++;
		}
		elsif (@valores_registro[0] eq "PROCDIR")
		{
			$PROCDIR = @valores_registro[1];
			$USUARIO = @valores_registro[2];
			$cantDir++;
		}		
		elsif (@valores_registro[0] eq "REPODIR")
		{
			$REPODIR = @valores_registro[1];
			$USUARIO = @valores_registro[2];
			$cantDir++;
		}
		if ($cantDir == 3)
		{
			last;
		}
	}
	close(CONF);
	
	#print "DIRS: MAE: $MAEDIR, PROC: $PROCDIR, REPO: $REPODIR\n\n";
}

#
# Graba el reporte en un archivo de texto. 
# param1 : nombre del archivo donde grabar.
# param2 : cantidad de columnas que tiene el reporte.
#
sub grabarRecalculo{
	
	my $nombreArchivo = @_[0];
    my $CodigoSistema;
	my $AnioContable;
	my $MesContable;
	my $DiaContable;
	my $EstadoContable;
	my $CodigoPrestamo;
	my $MontoPrestamo;
	my $MontoImpago;
	my $MontoInteresDevengado;
	my $MontoInteresNoDevengado;
	my $MontoDebitado;
	my $MontoRestante;
	my $CodigoCliente;
	my $NombreCliente;
	my $FechaGrabacion;
	my $UsuarioGrabacion;
	my $linea="";
    
	my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
	$year += 1900;
	$mon++;
	
	$mon = &normalizarValorDeUnDigito($mon);
	$mday = &normalizarValorDeUnDigito($mday);

    open(ARCHIVO_REPORTE,">>$REPODIR/$nombreArchivo") || die "ERROR: No puedo abrir el fichero $nombreArchivo\n";
    
     # recorro los datos y voy viendo si es necesario el recalculo
    foreach my $llave (keys %registros_ppi)
    {
        # me fijo que exista en ambos archivos
        if ( exists ($registros_prestamos{$llave}) )
        {
            # obtengo los datos del registro
            @reg_p_p = split(";",$registros_prestamos{$llave});
            @reg_ppi = split(";",$registros_ppi{$llave});

            #print "reg_p_p: $registros_prestamos{$llave}\n";
            #print "reg_ppi: $registros_ppi{$llave}\n";

            # si es recalculo lo grabo
            #if ( ( $reg_ppi[5] eq "SMOR" && $reg_p_p[4] ne "SMOR" ) || ( $reg_ppi[14] lt $reg_p_p[11]  ) )
            #{
				$CodigoSistema = @reg_ppi[1];chomp($CodigoSistema);
				$AnioContable = @reg_ppi[2];chomp($AnioContable);
				$MesContable = @reg_ppi[3];chomp($MesContable);
				$DiaContable = @reg_p_p[3];chomp($EstadoContable);
				$EstadoContable = @reg_ppi[5];chomp($EstadoContable);
				$CodigoPrestamo = @reg_ppi[7];chomp($CodigoPrestamo);
				$MontoPrestamo = @reg_ppi[9];chomp($MontoPrestamo);
				$MontoImpago = @reg_ppi[10];chomp($MontoImpago);
				$MontoInteresDevengado = @reg_ppi[11];chomp($MontoInteresDevengado);
				$MontoInteresNoDevengado = @reg_ppi[12];chomp($MontoInteresNoDevengado);
				$MontoDebitado = @reg_ppi[13];chomp($MontoDebitado);
				$MontoRestante = @reg_ppi[14];chomp($MontoRestante);
				$CodigoCliente = @reg_p_p[12];chomp($CodigoCliente);
				$NombreCliente = @reg_p_p[13];chomp($NombreCliente);
				$FechaGrabacion = "$year/$mon/$mday";
				$UsuarioGrabacion = $USUARIO;chomp($UsuarioGrabacion);
				
				# grabo el registro
				$linea = $CodigoSistema.";".$AnioContable.";".$MesContable.";".$DiaContable.";".$EstadoContable.";".$CodigoPrestamo.";".$MontoPrestamo.";".$MontoImpago.";".$MontoInteresDevengado.";".$MontoInteresNoDevengado.";".$MontoDebitado.";".$MontoRestante.";".$CodigoCliente.";".$NombreCliente.";".$FechaGrabacion.";".$UsuarioGrabacion;
				# les quito los car return y los newline
				$linea =~ s/\r|\n//g;
				print ARCHIVO_REPORTE "$linea\n";
            #}
        }
    }   
    
    close(ARCHIVO_REPORTE);
}

#
# Ayuda
#
sub mostrarAyuda{

    # obtengo el comando del cual quiere obtener ayuda.
    my $param = @_[0];
    my $parametros_obligatorios = "Parámetros obligatorios:\n"."		-p=<país>: Es el país acerca del cual quiero obtener la información.\n\n"."Parámetros para otros filtros:\n"."		-x=<valor de diferencia>\n"."		-s=<sistema>\n"."		-a=<año>\n"."		-pe=<período=[AAAA/MM]>: indica el mes de un año en el cual se quiere que esté\n"."			comprendido el mes contable del reporte.\n"."		-rp=<rango de períodos=[AAAA/MM]-[AAAA/MM]>: ídem punto anterior\n"."		    para un rango de meses.\n\n";
    chomp($param);

    if ( uc($param) eq "" )
    {
        print "Ayuda del Generador de reportes del Grupo 1.\n";
        print "Modo de uso:     ReporteX <subcomando> [opciones][argumentos]\n";
        print "Tipee 'ReporteX -a <subcomando>' para obtener información acerca del subcomando.\n\n";
        print "Subcomandos disponibles:\n";
        print " -a\n";
        print " -cr\n";
        print " -dm\n";
        print " -dp\n";
        print " -g\n\n";
    }
    elsif ( uc($param) eq uc("-a") )
    {
        print "Muestra información acerca del parámetro pasado como parámetro.\n";
        print "Si se escribe el subcomando sólo, muestra la ayuda general.\n\n";
    }
    elsif ( uc($param) eq uc("-cr") )
    {
        print "Este subcomando genera el reporte de recomendación para recálculo,\n";
        print "indicando para cuáles de las cuentas ingresadas es necesario hacer\n";
        print "un recálculo de la deuda en la base maestra.\n\n";
        print "Parámetros obligatorios:\n";
		print "		-p=<país>: Es el país acerca del cual quiero obtener la información.\n\n";
		print "Parámetros para otros filtros:\n";
		print "		-s=<sistema>\n";
		print "		-a=<año>\n";
		print "		-pe=<período=[AAAA/MM]>: indica el mes de un año en el cual se quiere que esté\n";
		print "			comprendido el mes contable del reporte.\n";
		print "		-rp=<rango de períodos=[AAAA/MM]-[AAAA/MM]>: ídem punto anterior\n";
		print "		    para un rango de meses.\n\n";
    }
    elsif ( uc($param) eq uc("-dm") )
    {
        print "Este comando genera un reporte con los registros en cuyos casos casos\n";
        print "la diferencia (en valor absoluto) entre el monto restante del maestro\n";
        print "y el monto restante del país es mayor a X monto. El valor X se pasa como\n";
        print "parámetro. En caso de no pasarse nada se muestran todos los registros.\n\n";
        print "$parametros_obligatorios";
    }
    elsif ( uc($param) eq uc("-dp") )
    {
        print "Este comando genera un reporte con los registros en cuyos casos casos\n";
        print "la diferencia (en valor absoluto) entre el monto restante del maestro\n";
        print "y el monto restante del país es mayor al X %. El valor X se pasa como\n";
        print "parámetro. En caso de no pasarse nada se muestran todos los registros.\n\n";
        print "$parametros_obligatorios";
    }

    elsif ( uc($param) eq uc("-g") )
    {
        print "Si se incluye se guardará el reporte mostrado en pantalla en archivo de texto.\n\n";
    }
    else 
    {
        print "El comando ingresado no existe para el Generador de reportes.\n\n";
    }

}

#
# Obtengo los valores del archivo de prestamos por pais
#
sub obtenerPrestamosPais{
    
    my @valores_registro;
    my $anio_ctb;
    my $mes_ctb;
    my $dia_ctb;
    my $fecha_grab;
    
    my $clave_p_p;
    my $aux;

    # paso a minusculas la descripcion del pais (para abrir el archivo de prestamos por pais)
    $PAIS_DESC =~ tr/A-Z/a-z/;
    
    #renombro los archivos procesados
	opendir TEMP, $PROCDIR;
	my @archivos = readdir TEMP;
	chdir $PROCDIR;
		
	for my $archivo (@archivos) 
	{
		if ( $archivo =~ /prest.+\.$PAIS_DESC/i )
		{
			#  el archivo de prestamos.pais
			open(PRESTAMOS_PAIS,"$PROCDIR/$archivo");
			
			while(<PRESTAMOS_PAIS>)
			{   
				chomp; # quito el eol

				# obtengo los datos y los almaceno en un array
				@valores_registro = split(';',$_);
				
				# tomo los datos necesarios para la comparacion
				$anio_ctb   = @valores_registro[1];
				$mes_ctb    = &normalizarValorDeUnDigito(@valores_registro[2]);
				$dia_ctb    = @valores_registro[3];
				$fecha_grab = @valores_registro[14];
				
				# compongo la clave de busqueda
				$clave_p_p  = @valores_registro[5].int($anio_ctb).int($mes_ctb);
				
				# almaceno los valores en una estructura hash
				if ( exists $registros_prestamos{$clave_p_p} )
				{
					# obtengo los datos almacenados
					$aux = split(';',$registros_prestamos{$clave_p_p});
					# si la fecha de grabacion del nuevo registro es mas actual lo almaceno
					if ( uc($aux[14]) lt uc($fecha_grab)  )
					{
						# borro y reinserto datos validos
						delete($registros_prestamos{$clave_p_p}); 
						$registros_prestamos{$clave_p_p} = $_;

					}
					# si no, no hago nada...
				}
				else
				{
					$registros_prestamos{$clave_p_p} = $_;
				}
			}
			close PRESTAMOS_PAIS;
		}
    }	
	
	closedir TEMP;    
    #print "REGISTROS PRESTAMOS PAIS\n";
    #print map "Hash: $_ = $registros_prestamos{$_}\n", keys %registros_prestamos;
}

#
# Obtengo los valores del archivo de prestamos personales impagos
#
sub obtenerPrestamosImpagos{

    my @valores_registro;
    my @aux;
    
    my $reg;
    my $clave_ppi;

    # abro el archivo maestro (PPI)
    open (PPI,"$MAEDIR/PPI.mae") || die "ERROR: No puedo abrir el fichero PPI.\n";
    
    # realizo la lectura para ver que registros coinciden con el filtro
    while (<PPI>)
    {
        chomp; # quito el eol
		
	    # guardo los valores en una cadena
        @valores_registro = split(';',$_);
        
        @valores_registro[3] = &normalizarValorDeUnDigito(@valores_registro[3]);
        
        # verifico que cumpla todas las condiciones
        if ( uc($PAIS_ID) ne uc(@valores_registro[0])){ next; }
        if ( $SIS_ID ne "" ) 
        {
            if ( uc($SIS_ID) ne uc(@valores_registro[1]) ){ next; }
        }
        if ( $CTB_ANIO ne "" )
        {
            if ( uc($CTB_ANIO) ne uc(@valores_registro[2])){ next; }
        }
        if ( $PERIODO ne "" )
        {
						
            if ( uc($PERIODO) ne uc(@valores_registro[2]."/".@valores_registro[3])){ next; }
        }
        if ( $RANGO_PERIODOS ne "" )
        {
			if ( uc(substr($RANGO_PERIODOS,0,7)) gt uc(@valores_registro[2]."/".@valores_registro[3])
               || uc(substr($RANGO_PERIODOS,8,7)) lt uc(@valores_registro[2]."/".@valores_registro[3])){ next; }
        }
        
        # obtengo el id del prestamo     
        $PRES_ID = @valores_registro[7];
        
        # cambio comas por puntos
        @valores_registro[9] =~ s/\,/\./;
        @valores_registro[10] =~ s/\,/\./;
        @valores_registro[11] =~ s/\,/\./;
        @valores_registro[12] =~ s/\,/\./;
        @valores_registro[13] =~ s/\,/\./;
        # obtengo los valores y con ellos hago los calculos
        $MT_PRES    = sprintf("%.2f",@valores_registro[9]);
        $MT_IMPAGO  = sprintf("%.2f",@valores_registro[10]);
        $MT_INDE    = sprintf("%.2f",@valores_registro[11]);
        $MT_INNODE  = sprintf("%.2f",@valores_registro[12]);
        $MT_DEB     = sprintf("%.2f",@valores_registro[13]);
        
        # calculo el monto restante
        $MT_REST    = sprintf("%.2f",$MT_PRES + $MT_IMPAGO + $MT_INDE + $MT_INNODE - $MT_DEB);
        
        # agrego a los valores el monto restante
        push(@valores_registro,$MT_REST);
	
		#print "vañpres registro: @valores_registro\n";

        # almaceno el array en un string
        $reg = join(';',@valores_registro);
        
        #print "Registro ppi procesado: $reg\n";
        
        # creo la clave del registro
        $clave_ppi = $PRES_ID.int(@valores_registro[2]).int(@valores_registro[3]);
        
        # guardo los valores obtenidos en una estructura hash
        if ( ! exists $registros_ppi{$clave_ppi} )
        {
            $registros_ppi{$clave_ppi} = $reg;
        }       
    }

    # cierro el archivo
    close(PPI);

    #print "REGISTROS PPI\n";
    #print map "Hash: $_ = $registros_ppi{$_}\n", keys %registros_ppi;
}

#
# Calculo y muestro la recomendacion
#
sub mostrarRecomendacion{

    my @aux;
        
    my $linea;
    my $recomendacion;
    
    # recorro los datos y voy viendo si es necesario el recalculo
    foreach my $llave (keys %registros_ppi)
    {
        # me fijo que exista en ambos archivos
        if ( exists ($registros_prestamos{$llave}) )
        {
            # obtengo los datos del registro
            @reg_p_p = split(";",$registros_prestamos{$llave});
            @reg_ppi = split(";",$registros_ppi{$llave});

            #print "reg_p_p: $registros_prestamos{$llave}\n";
            #print "reg_ppi: $registros_ppi{$llave}\n";

            # defino si hay que hacer recalculo o no
            if ( ( $reg_ppi[5] eq "SMOR" && $reg_p_p[4] ne "SMOR" ) || ( $reg_ppi[14] lt $reg_p_p[11]  ) )
            {
                $recomendacion = "RECALCULO";
            }   
            else
            {
                $recomendacion = "BUENO";
            }
            #           prestamo    -   cliente  -  estado cont mae-estado cont pais- mt rest mae   - mt rest pais 
            $linea = $reg_ppi[7].";".$reg_p_p[12].";".$reg_ppi[5].";".$reg_p_p[4].";".$reg_ppi[14].";".$reg_p_p[11].";".$recomendacion;

            push (@aux,$linea);         
        }
    }   
    
    # ordeno el reporte alfabéticamente
    @aux = sort { lc($a) cmp lc($b) } @aux;
    
    # meto el auxiliar en el reporte
    foreach $linea (@aux)
    {
            my @aux2;
            @aux2 = split(";",$linea);
            @aux2 = reverse(@aux2);
            # cambio los puntos por comas
            @aux2[1] =~ s/\./\,/;
            @aux2[2] =~ s/\./\,/;
            push (@reporte,@aux2[0]); # recomendacion
            push (@reporte,@aux2[1]); # mt rest pais
            push (@reporte,@aux2[2]); # mt rest mae
            push (@reporte,@aux2[3]); # estado cont pais
            push (@reporte,@aux2[4]); # estado cont mae
            push (@reporte,@aux2[5]); # cliente
            push (@reporte,@aux2[6]); # prestamo
    }
    
    # imprimo la cabecera
    my $titulos = "\nREPORTE DE RECÁLCULOS\n\nParámetros ingresados\n";
    $titulos .= $COMANDOS_USADOS."\n\n";
    $titulos .= sprintf 	"%-15s%-15s%-15s%-15s%-15s%-15s%-15s%s", 
							"Prestamo","Cliente","ECM","ECP","MRM","MRP","Recomendacion",
							"\n---------------------------------------------------------------------------------------------------------\n";
    print "$titulos";
    
    # muestro el reporte
    @reporte = reverse(@reporte);
    my $cantCol = 0;
    my $cantReg = 0;
    my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
	$year += 1900;
	$mon++;
	$mon = &normalizarValorDeUnDigito($mon);
	$mday = &normalizarValorDeUnDigito($mday);
	$hour = &normalizarValorDeUnDigito($hour);
	$min = &normalizarValorDeUnDigito($min);
	$sec = &normalizarValorDeUnDigito($sec);
		
	my $descriptor = $year.$mon.$mday.$hour.$min.$sec;
		
	# si me pidieron guardar el reporte creo el archivo
    if ( $GUARDAR_REPORTE )
    {
		open(REPORTEX,">>$REPODIR/ReporteX_RECALCULO.$descriptor") || die "ERROR: No puedo abrir el fichero ReporteX_$tipo_rep.$descriptor\n";
		print REPORTEX "$titulos";		
	}
	
    foreach $elem (@reporte)
    {
            chomp;
            printf ("%-15s",$elem);
            
            # guardo si me lo pidieron
			if ( $GUARDAR_REPORTE )
			{
				printf ( REPORTEX "%-15s",$elem);
			}
            
            $cantCol++;
            
            # paso al siguiente renglon
            if ( $cantCol == 7 )
            {
                print "\n";
                if ( $GUARDAR_REPORTE )
				{
					print REPORTEX "\n";
				}
                $cantCol = 0;
                $cantReg++;
            }
    }
    
    # imprimo la cantidad de registros calculados
    print "\n";
    printf("%d registros",$cantReg);
    print "\n";
    
    if ( $GUARDAR_REPORTE )
    {
		print REPORTEX "\n";
		printf (REPORTEX "%d registros",$cantReg);
		print REPORTEX "\n";
		close(REPORTEX);
	}
}

#
# Muestra el reporte de diferencia porcentual o en monto, segun el parametro
#
sub mostrarDiferencia{
    
    my @aux;
        
    my $linea;
    my $recomendacion;
    my $tipo_rep;
    
    my $monto_mae;
    my $monto_pais;
    my $diferencia;
    my $resultado;
    
    my $cmd = @_[0];
    
    if ( $cmd eq "-dp" )
	{
		$tipo_rep  = "PORCENTAJE";
	}
	else
	{
		$tipo_rep  = "MONTO";
	}
	    
    # recorro los datos
    foreach my $llave (keys %registros_ppi)
    {
        # me fijo que exista en ambos archivos
        if ( exists ($registros_prestamos{$llave}) )
        {
            # obtengo los datos del registro
            @reg_p_p = split(";",$registros_prestamos{$llave});
            @reg_ppi = split(";",$registros_ppi{$llave});
            
            $reg_p_p[11] =~ s/\,/\./;
            $reg_p_p[14] =~ s/\,/\./;
            
            $monto_pais = sprintf("%#FFF9DA.2f",$reg_p_p[11]);
            $monto_mae = sprintf("%.2f",$reg_ppi[14]);
            $diferencia = $monto_mae - $monto_pais;
            
            if ( $cmd eq "-dp" )
            {
				$tipo_rep  = "PORCENTAJE";
                $resultado = $diferencia * 100 / $monto_mae;
                $resultado = sprintf("%.2f",$resultado);
            }
            else
            {
				$tipo_rep  = "MONTO";
                $resultado = sprintf("%.2f",$diferencia);
            }
            
            # si el monto o porcentaje es mayor al pasado como parametro
            if ( abs($resultado) >= abs($VALOR_DIFERENCIA) )
            {
				#           prestamo - mt rest mae   - mt rest pais 
				$linea = $reg_ppi[7].";".$reg_ppi[14].";".$reg_p_p[11].";".$resultado;
				push (@aux,$linea);
			}            
        }
    }   
    
    # ordeno el reporte alfabéticamente
    @aux = sort { lc($a) cmp lc($b) } @aux;
    @aux = reverse(@aux);
    
    # meto el auxiliar en el reporte
    foreach $linea (@aux)
    {
		my @aux2;
		@aux2 = split(";",$linea);
		@aux2 = reverse(@aux2);
		
		@aux2[1] = sprintf("\$ %s",@aux2[1]);
		@aux2[2] = sprintf("\$ %s",@aux2[2]);
					
		if ( $cmd eq "-dm" )
		{				
			@aux2[0] = sprintf ("\$ %s",@aux2[0] );					
		}
		else
		{
			@aux2[0] = sprintf ("%s %%",@aux2[0] );
		}
		
		@aux2[1] =~ s/\./\,/;
		@aux2[2] =~ s/\./\,/;
		push (@reporte,@aux2[0]); # diferencia
		push (@reporte,@aux2[1]); # mt rest pais
		push (@reporte,@aux2[2]); # mt rest mae
		push (@reporte,@aux2[3]); # prestamo
    }
    
    # imprimo la cabecera
    my $titulos = "\nREPORTE DE DIFERENCIA EN ".$tipo_rep."\n\nParámetros ingresados\n";
    $titulos .= $COMANDOS_USADOS."\n\n";
    $titulos .= sprintf 	"%-15s%-15s%-15s%-15s%s", 
							"Prestamo","MRM","MRP","Diferencia",
							"\n------------------------------------------------------------\n";
    print "$titulos";
        
    # muestro el reporte
    @reporte = reverse(@reporte);
    my $cantCol = 0;
    my $cantReg = 0;
    my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
	$year += 1900;
	$mon++;
	$mon = &normalizarValorDeUnDigito($mon);
	$mday = &normalizarValorDeUnDigito($mday);
	$hour = &normalizarValorDeUnDigito($hour);
	$min = &normalizarValorDeUnDigito($min);
	$sec = &normalizarValorDeUnDigito($sec);
	my $descriptor = $year.$mon.$mday.$hour.$min.$sec;
    
    # si me pidieron guardar el reporte creo el archivo
    if ( $GUARDAR_REPORTE )
    {
		open(REPORTEX,">>$REPODIR/ReporteX_$tipo_rep.$descriptor") || die "ERROR: No puedo abrir el fichero ReporteX_$tipo_rep.$descriptor\n";
		print REPORTEX "$titulos";		
	}
    
    foreach $elem (@reporte)
    {
		chomp;
		printf ("%-15s",$elem);
		
		# guardo si me lo pidieron
		if ( $GUARDAR_REPORTE )
		{
			printf ( REPORTEX "%-15s",$elem);
		}
		
		$cantCol++;
					
		# paso al siguiente renglon
		if ( $cantCol == 4 )
		{
			print "\n";
			if ( $GUARDAR_REPORTE )
			{
				print REPORTEX "\n";
			}
			$cantCol = 0;
			$cantReg++;
		}
    }
    
	# imprimo la cantidad de registros
    print "\n";
    printf("%d registros",$cantReg);
    print "\n";
    
    if ( $GUARDAR_REPORTE )
    {
		print REPORTEX "\n";
		printf (REPORTEX "%d registros",$cantReg);
		print REPORTEX "\n";
		close(REPORTEX);
	}
}

#
# Muestra el reporte correspondiente según el parametro enviado
#
sub mostrarReportes{
    
    my @valores_registro;   

    my $pais;
    my $sistema;
    my $anio;
    my $parametro;
    my $comando;

    my $subs;
    my $rta;
    my $parametro_de_rangos=0;
    my $parametro_de_pais=0;
    my $parametro_val_ref=0;
    my $parametro_sistema=0;
    
    # inicializo las variables globales
    &inicializarGlobales;

    # tomo los parametros y los convierto a strings
    my $aux = join(' ',@_); 
    
    # quito caracter de eol
    chomp($aux);
    
    # paso parametros a array
    my @parametros = split(/ /,$aux);
    
    # obtengo el comando de la subrutina
    $comando = @parametros[0];
    
    # elimino el comando correspondiente a la subrutina
    splice(@parametros, 0, 1);

    # me fijo los parametros enviados
    foreach $parametro( @parametros )
    {
        # el primer parametro es el pais, que no lleva identificador
        # porque va siempre...si no encuentra un igual antes, es ese...
        if ( $parametro =~ m/-p=/ )
        {
			if ( $parametro_de_pais == 0 )
			{
				$PAIS_DESC = substr $parametro, index($parametro,'=')+1, (length $parametro)-3;
				$parametro_de_pais = 1;
				$COMANDOS_USADOS.="País: $PAIS_DESC. ";
			}
			else
			{
				print "\nPuede indicar solo un país por consulta.\n";
				return(0);
			}
        }
        elsif ( $parametro =~ m/x=/ )
        {
			if( uc($comando) eq uc("-dp") or uc($comando) eq uc("-dm") ) 
			{
				if ( $parametro_val_ref == 0 )
				{
					$VALOR_DIFERENCIA = sprintf("%.2f",(substr $parametro, index($parametro,'=')+1, (length $parametro)-2));
					$COMANDOS_USADOS.="Valor Diferencia: $VALOR_DIFERENCIA. ";
					$parametro_val_ref = 1;
				}
				else
				{
					print "\nPuede indicar solo un valor para diferencias por consulta.\n";
					return(0);
				}
			}
			else
			{
				print "\nEl comando ingresado no admite el parametro \"x\".\n";
				return(0);
			}			
		}
        elsif ( $parametro =~ m/-s=/)
        {
			if ( $parametro_sistema != 0 )
			{
				print "\nPuede indicar solo un sistema por consulta.\n";
				return(0);
			}
			else
			{
				$SIS_ID = substr $parametro, index($parametro,'=')+1, (length $parametro)-3;
				$parametro_sistema=1;
				$COMANDOS_USADOS.="Id del Sistema: $SIS_ID. ";
			}
        }
        elsif ( $parametro =~ m/-a=/)
        {
			if ( $parametro_de_rangos != 0 )
			{
				print "\nPuede indicar solo un año, periodo o rango de periodos por consulta.\n";
				return(0);
			}
			else
			{
				$CTB_ANIO = substr $parametro, index($parametro,'=')+1, (length $parametro)-3;
				if ( $CTB_ANIO !~ m/\d+$/ )
				{
					print "\nEl año ingresado es incorrecto.\n";
					return(0);
				}
				$parametro_de_rangos = 1;
				$COMANDOS_USADOS.="Año: $CTB_ANIO. ";
			}
        }
        elsif ( $parametro =~ m/-pe=/ )
        {
			if ( $parametro_de_rangos != 0 )
			{
				print "\nPuede indicar solo un año, periodo o rango de periodos por consulta.\n";
				return(0);
			}
			else
			{
				$PERIODO = substr $parametro, index($parametro,'=')+1, (length $parametro)-4;
				if ( not &validarPeriodo($PERIODO) )
				{
					print "\nEl formato de período ingresado es incorrecto.\n";
					return(0);
				}
				$parametro_de_rangos = 1;
				$COMANDOS_USADOS.="Período: $PERIODO. ";
			}
        }
        elsif ( $parametro =~ m/-rp=/ )
        {
			if ( $parametro_de_rangos != 0 )
			{
				print "\nPuede indicar solo un año, periodo o rango de periodos por consulta.\n";
				return(0);
			}
			else
			{
				$RANGO_PERIODOS = substr $parametro, index($parametro,'=')+1, (length $parametro)-4;
				if ( not &validarRangoPeriodos($RANGO_PERIODOS) )
				{
					print "\nEl formato de rango de períodos ingresado es incorrecto.\n";
					return(0);
				}
				$parametro_de_rangos = 1;
				$COMANDOS_USADOS.="Rango de Períodos: $RANGO_PERIODOS. ";
			}
        }
        elsif ( $parametro =~ m/-g/)
        {
            $GUARDAR_REPORTE = 1;
            $COMANDOS_USADOS.="El reporte fue guardado. ";
        }
        else
        {
            print "\nEl parametro $parametro es incorrecto.\n";
            return(0);
        }        
    }
    
    if ( ! $parametro_de_pais )
    {
		print "\nDebe indicar un país.\n";
		return(0);
	}
       
    # busco el codigo del pais ingresado
    &buscarDatosPais;
    
    # si no se encontro el país, salgo de la subrutina
    if ( $PAIS_ID eq "" )
    {
        print "\nEl país ingresado no está en la base de datos.";
        return(0);
    }
        
    # obtengo los prestamos impagos segun los filtros
    &obtenerPrestamosImpagos;
    
    # obtengo los prestamos de cada pais
    &obtenerPrestamosPais;

    # muestro el reporte correspondiente
    if ( $comando eq "-cr" )
    {
        # muestro los resultados y recomendaciones
        &mostrarRecomendacion;
        
        # grabo si corresponde
        if (&confirma("\n¿Desea grabar el recalculo? [s/n]: "))
        {
            &grabarRecalculo("RECALCULO.".$PAIS_DESC,7);
        }
    }
    elsif ( $comando eq "-dp" || $comando eq "-dm" )
    {
        # muestro las diferencias
        &mostrarDiferencia($comando);
    }    
}   

# analizo los valores de los parametros que me pasaron
sub analizarParametros{
    
    #inicializo las variables   
    my $rta = "s";
    my $cmd;
    my $pmt;
    my $respuesta;

    # obtengo los valores pasados como parametros
    $cmd = @_[0];
    
    if ($cmd eq "-a")
    {
        &mostrarAyuda(@_[1]);               
    }
    elsif ( $cmd eq "-cr" || $cmd eq "-dp" || $cmd eq "-dm" )
    {
        &mostrarReportes(@_);
    }
    else
    {
        print "El comando es incorrecto.\n";
    }
    
    return &confirma("\n¿Desea realizar otra consulta? [s/n]: ");
    
}

######################
#                    #
# PROGRAMA PRINCIPAL #
#                    #
######################

	# me fijo si las variables de entorno necesarias estan inicializadas
	if ( &verificarAmbiente )
	{
		# obtengo los directorios necesarios para el procesamiento
		&obtenerDirectorios;
		# tomo los parametros y los convierto a strings
		my $aux = join(' ',@ARGV); 
		# quito caracter de eol
		chomp($aux);
		# paso parametros a array
		my @parametros = split(/ /,$aux);
		
		# muestra resultado de consultas, hasta que 
		# el usuario indique que quiere terminar
		my $seguir = &analizarParametros(@parametros);
		while ( $seguir )
		{   
			print "./ReporteX.pl ";
			$aux = <STDIN>;
			chomp($aux);
			@parametros = split(/ /,$aux);
			$seguir = &analizarParametros(@parametros);         
		}
	}



