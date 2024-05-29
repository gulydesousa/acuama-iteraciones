# 🏃‍♀️ Sprint #54
#### 27-05-2024 - 14-06-2024
#### Sprint Goal 
*El compromiso de este sprint es....*


---
###  🧿 01 - User Story 88136: Cartas inspecciones - Correspondencia campos con BBDD Inspecciones
#### 📦 Task 89015:  Revisar proceso de Actulización de Aptos no aptos

> *Branch*: **feature/88062-sprint53-to039-inspeccionplantilla-melilla**  
*Publicado en Preproducción*: 20-05-2024  
Menú: Técnica/Notificaciones/Insp. Validaciones/**Actualizar OT Inspecciones**  


Procedimiento que actualiza el Valor de las OTs de Inspecciones según la configuración actual en "Inspecciones Validaciones".

El cambio es porque ahora una linea de validaciones puede depender de mas de una columna, para agrupar los valores se usa la columna "clave".

``` powershell
# Para ejecutar los scripts relacionados con esta entrega
 
powershell -File _deploy.ps1
```

[**ver más...**](../01-ustory-88136-task-89015-Cartas%20inspecciones/docs/Readme/pruebas.md)
<br><br><br>




---

### 🍄06 - Bugfix 89320:  Cartas con notificacion a padres no incluidos en la inspección

> *Branch*: **bugfix/89320-sprint54-cartas-notificacion-evitar-notificaciones-mock**  
*Publicado en Preproducción*: 22-05-2024  
Menú: acuama/tecnica/Notificaciones/Emision de notif. (Apta-No.Apta)  

#89320 Se incluye la columna Mock que se usa para que la emision solo incluya aquellas donde mock == false

Sirve para identificar las inspecciones "ficticias" que vienen en la vista para que cada inspeccion venga con los datos del contrato general y los abonados (si existen)

``` powershell
# Para ejecutar los scripts relacionados con esta entrega
 
powershell -File _deploy.ps1
```
<br><br><br>



<br><br><br>
<br><br><br>
<br><br><br>
<br><br><br>
<br><br><br>
<br><br><br>
<br><br><br>
<br><br><br>

---
### 🎯01 - User Story 000:  User story name

> *Branch*: **feature/0000-sprintxx-story-name**  
Publicado en: Preproducción 01-01-2024  
Menú: acuama/catastros/Informes/Informes Excel  

#### Descripcion detallada

[**ver más...**](01-ustory-0000-sprintxx-ustoryName.md)
<br><br><br>





---
###  🧿 02 - User Story 000: User story name
#### 📦 Task 000:  Task Name

> *Branch*: **feature/0000-sprintxx-story-name**  
*Publicado en Preproducción*: 01-01-2024  
Menú: acuama/catastros/Informes/Informes Excel  


Descripcion detallada

[**ver más...**](02-ustory-0000-task-000-sprintxx-taskName.md)
<br><br><br>





---

### 🍄03 - Bugfix 000:  Bug Name

> *Branch*: **bugfix/0000-sprintxx-bug-name**  
*Publicado en Preproducción*: 01-01-2024  
Menú: acuama/catastros/Informes/Informes Excel  

Descripcion detallada

[**ver más...**](03-bugfix-0000-sprintxx-bugName.md)
<br><br><br>




---
### 💥04- Hotfix 000:  Critical Bug Name

> *Branch*: **feature/0000-sprintxx-bugfix-name**  
*<span style='color:red'>Publicado:</span>* 01-01-2024  
Menú: acuama/catastros/Informes/Informes Excel 

Descripcion detallada

[**ver más...**](04-hotfix-0000-sprintxx-bugName.md)
<br><br><br>

---

