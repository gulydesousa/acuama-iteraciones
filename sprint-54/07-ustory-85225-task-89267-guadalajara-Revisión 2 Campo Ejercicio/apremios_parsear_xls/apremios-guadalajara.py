import csv
import pandas as pd
import tkinter as tk
import os
import shutil
import openpyxl

from datetime import datetime 
from tkinter import filedialog
from tkinter import messagebox
from openpyxl import load_workbook
from openpyxl.styles import Font
from pandas import read_excel

def obtener_ruta_archivo(subdirectorio):
    root = tk.Tk()
    root.withdraw()
    ruta_txt = filedialog.askopenfilename(initialdir=subdirectorio, filetypes=[("Text files", "*.txt")])
    return ruta_txt

def guardar_dataframe(df, nombre_archivo_resultado):
    df = df.astype(str)
    df.to_excel(nombre_archivo_resultado, index=False)

def abrir_workbook(nombre_archivo_resultado):
    wb = load_workbook(nombre_archivo_resultado)
    ws = wb.active
    return wb, ws

def obtener_definicion_columnas():
    columnas = []
    with open('_configuracion/metadata.csv', 'r') as f:
        lector = csv.reader(f, delimiter=';')
        next(lector)  # Saltar la cabecera
        for fila in lector:
            nombre = fila[0]
            inicio = int(fila[1]) - 1  # Restar 1 al índice
            largo = int(fila[2])
            columnas.append((nombre, inicio, largo))
    return columnas

def leer_txt_y_dividir(ruta_txt, columnas):
    df = pd.DataFrame()
    longitud_linea = None
    with open(ruta_txt, 'r') as f:
        for i, linea in enumerate(f):
            if longitud_linea is None:
                longitud_linea = len(linea)
            inicio_anterior = 0
            for j, (nombre, inicio, largo) in enumerate(columnas):
                df.loc[i, nombre] = str(linea[inicio:inicio+largo])
                if j < len(columnas) - 1:
                    inicio_siguiente = columnas[j+1][1]
                    if inicio + largo < inicio_siguiente:
                        df.loc[i, f'Sin encabezado {j+1}'] = str(linea[inicio+largo:inicio_siguiente])
                inicio_anterior = inicio + largo
            if inicio_anterior < longitud_linea:
                df.loc[i, f'Sin encabezado {len(columnas)}'] = str(linea[inicio_anterior:])
    return df

def leer_archivo(ruta):
    with open(ruta, 'r') as f:
        contenido = f.read()
    return contenido

def crear_nombre_archivo(ruta_txt):
    nombre_archivo = os.path.splitext(os.path.basename(ruta_txt))[0]
    ahora = datetime.now()
    fecha_hora = ahora.strftime("%Y%m%d_%H%M%S")
    return f'{nombre_archivo}.xlsx'

def colorear_fuente(ws):
    for column in ws.columns:
        if column[0].value and 'Sin encabezado' in column[0].value:
            for cell in column:
                cell.font = Font(color="D3D3D3")

def escribir_en_txt(df, ruta_salida):
    with open(ruta_salida, 'w') as f:
        for index, row in df.iterrows():
            # Filtrar los valores vacíos
            row_values = [value for value in row if value]
            if row_values:  # Comprobar si la fila no está vacía
                f.write(''.join(row_values))

def comparar_archivos(contenido_entrada, contenido_salida):
    if contenido_entrada == contenido_salida:
        messagebox.showinfo("Resultado", "OK")
    else:
        messagebox.showwarning("Resultado", "Algo no ha ido bien parseando el archivo de entrada")

def crear_interfaz():
    root = tk.Tk()
    root.withdraw()
    return root

def crear_subdirectorio(nombre_archivo):
    # Crear un nombre de subdirectorio con el nombre del archivo y la hora
    nombre_subdirectorio = f"{nombre_archivo}_{datetime.now().strftime('%H%M%S')}"
    subdirectorio = os.path.join('resultados', nombre_subdirectorio)
    os.makedirs(subdirectorio, exist_ok=True)
    return subdirectorio

def copiar_archivo(ruta_origen, ruta_destino):
    shutil.copy(ruta_origen, ruta_destino)

def main(): 
    # Definir la ruta al subdirectorio
    subdirectorio = 'apremios_txt'

    root = crear_interfaz()

    ruta_txt = obtener_ruta_archivo(subdirectorio)
    columnas = obtener_definicion_columnas()
    df = leer_txt_y_dividir(ruta_txt, columnas)  
    
    # Extraer el nombre del archivo de la ruta del archivo de entrada
    nombre_archivo = os.path.splitext(os.path.basename(ruta_txt))[0]
    
    # Crear un nuevo subdirectorio en el directorio "resultados"
    subdirectorio_resultados = crear_subdirectorio(nombre_archivo)
    
    # Definir la ruta completa al archivo de Excel en el subdirectorio
    nombre_archivo_resultado = os.path.join(subdirectorio_resultados, crear_nombre_archivo(nombre_archivo))

    guardar_dataframe(df, nombre_archivo_resultado)

    wb, ws = abrir_workbook(nombre_archivo_resultado)

    colorear_fuente(ws)

    wb.save(nombre_archivo_resultado)

    # Leer el archivo de Excel y escribirlo en un archivo de texto
    df = pd.read_excel(nombre_archivo_resultado, dtype=str)

    ruta_salida = os.path.join(subdirectorio_resultados, 'resultado.txt')
    escribir_en_txt(df, ruta_salida)
    
    # Leer el archivo de entrada
    contenido_entrada = leer_archivo(ruta_salida)

    # Leer el archivo de salida
    contenido_salida = leer_archivo(ruta_salida)

    # Comparar los archivos de entrada y salida
    comparar_archivos(contenido_entrada, contenido_salida)
    
    # Copiar los archivos al nuevo subdirectorio
    copiar_archivo(ruta_txt, os.path.join(subdirectorio_resultados, os.path.basename(ruta_txt)))    
    
# Llamada a la función principal
main()
