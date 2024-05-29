# Definici�n de par�metros de conexi�n
$server = "SQLDESA41"
$database = "ACUAMA_DESA"
$user = "D3ploy2020"
$password = "n8lzH9APa9ig"

# Lista de scripts a ejecutar en orden
$scripts = @(
    "vOtInspecciones_Melilla.sql",
	"vOtInspeccionesNotificacionEmisiones_Melilla.sql"
    "TO039_Inspecciones_Melilla.sql"
)

# Inicializaci�n del �ndice
$i = 1

# Bucle para ejecutar cada script
foreach ($script in $scripts) {
	$formattedIndex = $i.ToString("D2")

    Write-Host "$formattedIndex ===> $script"
    sqlcmd -S $server -d $database -U $user -P $password -i $script
    
    # Verificar si hubo errores en la ejecuci�n del script
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Error ejecutando $script. Se aborta el despliegue."
        exit $LASTEXITCODE
    }

    # Incrementar el �ndice
    $i++
}

# Mensaje de confirmaci�n al finalizar todos los scripts
Write-Host "Todos los scripts han sido ejecutados con �xito."
