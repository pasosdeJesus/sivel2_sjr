source 'https://rubygems.org'

git_source(:github) { |repo| "https://github.com/#{repo}.git" }

gemspec


gem 'bcrypt'

gem 'bigdecimal'

gem 'bootsnap', '>=1.1.0', require: false

gem 'cancancan'

gem 'chosen-rails', git: 'https://github.com/vtamara/chosen-rails.git', branch: 'several-fixes'

gem 'cocoon', git: 'https://github.com/vtamara/cocoon.git', branch: 'new_id_with_ajax' # Formularios anidados (algunos con ajax)

gem 'coffee-rails' # CoffeeScript para recuersos .js.coffee y vistas

gem 'colorize' # Colores en terminal

gem 'devise' # Autenticación 

gem 'devise-i18n'

gem 'font-awesome-rails' 

# API JSON facil. Ver: https://github.com/rails/jbuilder
gem 'jbuilder'

gem 'jquery-rails' # jquery como librería JavaScript

gem 'jquery-ui-rails'

gem 'libxml-ruby'

gem 'odf-report' # Genera ODT

gem 'paperclip' # Maneja adjuntos

gem 'pg' # Postgresql

gem 'pick-a-color-rails'

gem 'prawn' # Generación de PDF

gem 'prawnto_2',  :require => 'prawnto'

gem 'prawn-table'

gem 'puma'

gem 'rails', '~> 6.0.0.rc1'

gem 'rails-i18n'

gem 'rspreadsheet'

gem 'rubyzip', '>=2.0'

gem 'sass' # Unifica CSSsp

gem 'simple_form' # Formularios simples 

gem 'tiny-color-rails'

gem 'turbolinks' # Seguir enlaces más rápido. 

gem 'twitter_cldr' # ICU con CLDR
 
gem 'tzinfo' # Zonas horarias

gem 'uglifier' # Uglifier comprime recursos Javascript

gem 'webpacker'

gem 'will_paginate' # Pagina listados


#####
# Motores que se sobrecargan vistas (deben ponerse en orden de apilamiento 
# lógico y no alfabetico como las gemas anteriores) 

gem 'sip', # Motor generico
  git: 'https://github.com/pasosdeJesus/sip.git', branch: :bs4
#gem 'sip', path: '../sip'

gem 'mr519_gen', # Motor de gestion de formularios y encuestas
  git: 'https://github.com/pasosdeJesus/mr519_gen.git', branch: :bs4
#gem 'mr519_gen', path: '../mr519_gen'

gem 'heb412_gen',  # Motor de nube y llenado de plantillas
  git: 'https://github.com/pasosdeJesus/heb412_gen.git', branch: :bs4
#gem 'heb412_gen', path: '../heb412_gen'

gem 'cor1440_gen',  # Motor de convenios con marco lógico y actividades
  git: 'https://github.com/pasosdeJesus/cor1440_gen.git', branch: :bs4

gem 'sivel2_gen',  # Motor de SIVeL 2
  git: 'https://github.com/pasosdeJesus/sivel2_gen.git', branch: :bs4


group :development do

  #gem 'byebug' # Depurar
  
  gem 'web-console' # Consola irb en páginas 

end



group :test do

  gem 'selenium-webdriver'

  gem 'simplecov'

  gem 'spring'

end

