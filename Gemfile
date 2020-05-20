source 'https://rubygems.org'

git_source(:github) { |repo| "https://github.com/#{repo}.git" }

gemspec


gem 'bcrypt'

gem 'bigdecimal'

gem 'bootsnap', '>=1.1.0', require: false

gem 'cancancan'

gem 'cocoon', git: 'https://github.com/vtamara/cocoon.git', branch: 'new_id_with_ajax' # Formularios anidados (algunos con ajax)

gem 'coffee-rails' , '>= 5.0.0' # CoffeeScript para recuersos .js.coffee y vistas

gem 'devise' , '>= 4.7.1' # Autenticación 

gem 'devise-i18n', '>= 1.9.1'

# API JSON facil. Ver: https://github.com/rails/jbuilder
gem 'jbuilder', '>= 2.10.0'

gem 'libxml-ruby'

gem 'odf-report' # Genera ODT

gem 'paperclip' , '>= 6.1.0' # Maneja adjuntos

gem 'pg' # Postgresql

gem 'prawn' # Generación de PDF

gem 'prawnto_2', '>= 0.3.0', :require => 'prawnto'

gem 'prawn-table'

gem 'puma'

gem 'rails', '~> 6.0.3.1'

gem 'rails-i18n', '>= 6.0.0'

gem 'rspreadsheet'

gem 'rubyzip', '>=2.0'

gem 'sassc-rails' , '>= 2.1.2' # Unifica CSSsp

gem 'simple_form' , '>= 5.0.2' # Formularios simples 

gem 'twitter_cldr' # ICU con CLDR
 
gem 'tzinfo' # Zonas horarias

gem 'webpacker', '>= 5.1.1'

gem 'will_paginate' # Pagina listados


#####
# Motores que se sobrecargan vistas (deben ponerse en orden de apilamiento 
# lógico y no alfabetico como las gemas anteriores) 

gem 'sip', # Motor generico
  git: 'https://github.com/pasosdeJesus/sip.git'
  #path: '../sip'

gem 'mr519_gen', # Motor de gestion de formularios y encuestas
  git: 'https://github.com/pasosdeJesus/mr519_gen.git'
  #path: '../mr519_gen'

gem 'heb412_gen',  # Motor de nube y llenado de plantillas
  git: 'https://github.com/pasosdeJesus/heb412_gen.git'
  #path: '../heb412_gen'

gem 'cor1440_gen',  # Motor de convenios con marco lógico y actividades
  git: 'https://github.com/pasosdeJesus/cor1440_gen.git'
  #path: '../cor1440_gen'

gem 'sivel2_gen',  # Motor de SIVeL 2
  git: 'https://github.com/pasosdeJesus/sivel2_gen.git'
  #path: '../sivel2_gen'


group :development do

  #gem 'byebug' # Depurar

  gem 'colorize' # Colores en terminal

  gem 'web-console' , '>= 4.0.2' # Consola irb en páginas 

end



group :test do

  gem 'selenium-webdriver'

  gem 'simplecov'

  gem 'spring'

end

