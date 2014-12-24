# Motor SIVeL 2 para el SJR LAC 
[![Esado Construcción](https://api.travis-ci.org/pasosdeJesus/sivel2_sjr.svg?branch=master)](https://travis-ci.org/pasosdeJesus/sivel2_sjr) [![Clima del Código](https://codeclimate.com/github/pasosdeJesus/sivel2_sjr/badges/gpa.svg)](https://codeclimate.com/github/pasosdeJesus/sivel2_sjr) [![Cobertura de Pruebas](https://codeclimate.com/github/pasosdeJesus/sivel2_sjr/badges/coverage.svg)](https://codeclimate.com/github/pasosdeJesus/sivel2_sjr) [![security](https://hakiri.io/github/pasosdeJesus/sivel2_sjr/master.svg)](https://hakiri.io/github/pasosdeJesus/sivel2_sjr/master) [![Dependencias](https://gemnasium.com/pasosdeJesus/sivel2_sjr.svg)](https://gemnasium.com/pasosdeJesus/sivel2_sjr) 

## Tabla de Contenido
* [Diseño](#diseño)
* [Uso](#uso)
* [Pruebas](#pruebas)
* [Desarrollo](#pruebas)

Este es un motor de SIVeL 2 para el SJR LAC por incluir en el 
sistema de información particular de cada país.

## Uso

Usar junto con sivel2_gen

### Requerimientos
* Ruby version >= 2.1
* PostgreSQL >= 9.3
* Recomendado sobre adJ 5.5 (que incluye todos los componentes mencionados).  
  Las siguientes instrucciones suponen que opera en este ambiente.

## Pruebas
Se han implementado algunas pruebas con RSpec a modelos y pruebas de regresión.

* Instale gemas requeridas (como Rails 4.2) con:
``` sh
  cd spec/dummy
  sudo bundle install
  bundle install
```
* Prepare base de prueba con:
``` sh
  cd spec/dummy
  RAILS_ENV=test rake db:setup
  RAILS_ENV=test rake sivel2gen:indices
```
* Ejecute las pruebas desde el directorio del motor con:
```sh
  rake
```

## Desarrollo

### Convenciones

Las mismas de sivel2_gen

