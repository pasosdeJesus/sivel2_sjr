source 'https://rubygems.org'

git_source(:github) { |repo| "https://github.com/#{repo}.git" }

gemspec

gem 'babel-transpiler'

gem 'bcrypt'

gem 'bigdecimal'

gem 'bootsnap', '>=1.1.0', require: false

gem 'cancancan'

gem 'cocoon', git: 'https://github.com/vtamara/cocoon.git', branch: 'new_id_with_ajax' # Formularios anidados (algunos con ajax)

gem 'coffee-rails' # CoffeeScript para recuersos .js.coffee y vistas

gem 'devise' # Autenticación 

gem 'devise-i18n'

# API JSON facil. Ver: https://github.com/rails/jbuilder
gem 'jbuilder'

gem 'jsbundling-rails'

gem 'kt-paperclip',                 # Anexos
  git: 'https://github.com/kreeti/kt-paperclip.git'

gem 'libxml-ruby'

gem 'odf-report' # Genera ODT

gem 'parslet'

gem 'pg' # Postgresql

gem 'prawn' # Generación de PDF

gem 'prawnto_2',  :require => 'prawnto'

gem 'prawn-table'

gem 'rails', '~> 7.0'

gem 'rails-i18n'

gem 'rspreadsheet'

gem 'rubyzip', '>=2.0'

gem 'sassc-rails' # Unifica CSSsp

gem 'simple_form' # Formularios simples 

gem 'sprockets-rails'

gem 'stimulus-rails'

gem 'turbo-rails', '~> 1.0'

gem 'twitter_cldr' # ICU con CLDR
 
gem 'tzinfo' # Zonas horarias

gem 'will_paginate' # Pagina listados


#####
# Motores que se sobrecargan vistas (deben ponerse en orden de apilamiento 
# lógico y no alfabetico como las gemas anteriores) 

gem 'msip', # Motor generico
  git: 'https://gitlab.com/pasosdeJesus/msip.git', branch: :main
  #path: '../msip'

gem 'mr519_gen', # Motor de gestion de formularios y encuestas
  git: 'https://gitlab.com/pasosdeJesus/mr519_gen.git', branch: :main
  #path: '../mr519_gen'

gem 'heb412_gen',  # Motor de nube y llenado de plantillas
  git: 'https://gitlab.com/pasosdeJesus/heb412_gen.git', branch: :main
  #path: '../heb412_gen'

gem 'cor1440_gen',  # Motor de convenios con marco lógico y actividades
  git: 'https://gitlab.com/pasosdeJesus/cor1440_gen.git', branch: :main
  #path: '../cor1440_gen'

gem 'sivel2_gen',  # Motor de SIVeL 2
  git: 'https://gitlab.com/pasosdeJesus/sivel2_gen.git', branch: :main
  #path: '../sivel2_gen'


group :development, :test do
  gem 'debug' # Depurar

  gem 'colorize' # Colores en terminal

  gem 'dotenv-rails'
end


group :development do
  gem 'puma'

  gem 'web-console' # Consola irb en páginas 
end


group :test do
  gem 'capybara'

  gem 'cuprite'

  gem 'selenium-webdriver'

  gem 'simplecov', '<0.18' # Debido a https://github.com/codeclimate/test-reporter/issues/418

  gem 'spring'
end

