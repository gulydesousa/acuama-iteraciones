# Definición de parámetros de conexión
 $server = "SQLDESA41"
 $database = "ACUAMA_DESA"

# $server = "CL_LST_PRE_APP"
# $database = "ACUAMA_MELILLA_PRE"


$user = "D3ploy2020"
$password = "n8lzH9APa9ig"

# Lista de scripts a ejecutar en orden
$scripts = @(
    "00_INSERT_otInspeccionesValidaciones.sql",
    "otInspecciones_ActualizarOtDatosValor_Melilla.sql"
)

# Inicialización del índice
$i = 1

# Bucle para ejecutar cada script
foreach ($script in $scripts) {
	$formattedIndex = $i.ToString("D2")

    Write-Host "$formattedIndex ===> $script"
    sqlcmd -S $server -d $database -U $user -P $password -i $script
    
    # Verificar si hubo errores en la ejecución del script
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Error ejecutando $script. Se aborta el despliegue."
        exit $LASTEXITCODE
    }

    # Incrementar el índice
    $i++
}

# Mensaje de confirmación al finalizar todos los scripts
Write-Host "Todos los scripts han sido ejecutados con éxito."
