* que queden selecciones de cuadro de selección tras cambiar filtro de actividades

Las tablas básicas que tengan relaciones has_many, no pueden borrarse 
cuando hay objetos dependientes, puede ser mejor:

1. Si la tabla basica es la principal y a esa se asocian los de otra en
   el formulario de edición de la tabla, (por ejemplo proyectofinanciero 
   tiene muchos proyectos mediante proyecto_proyectofinanciero), antes de 
   borrar el registro de la tabla básica borrar los que se relacionan
   en la tabla combinada.

2. Si la tabla básica es referenciada por otra, no borrar sino presentar
   avisos de error.  Por ejemplo si se quiere borrar un registro de 
   proyectofinanciero y hay actividades que lo tengan es mejor avisar.

Lo segundo se hace por defecto en sip/controllers/admin/basicas_controller.rb
Pero lo primero requiere intervención clase a clase que lo requiera,
ver por ejemplo en motor sivel2_sjr 
app/controllers/sivel2_sjr/ayudasjr_controller.rb

* Poner cotejación en espanol en campos nombre, observaciones de tablas
  básicas y en otras con textos en español, ver en 
  db/migrate/20151020203421_agrega_cotejacion.rb

* Corregir ortografía concentimiento->consetimiento puede usarse migración
  sivel2_mujeresindigenas/db/migrate/20160420080511_ortografia_cons.rb

