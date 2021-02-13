require_relative 'boot'

require 'rails/all'

# Requerir las gemas listas en el Gemfile, incluyendo gemas que haya
# limitado a :test, :development, o :production.
Bundler.require(*Rails.groups)

module Dummy
  class Application < Rails::Application

    # config.load_defaults 6.0

    # Las configuraciones de config/environments/* tienen precedencia
    # sobre las especifciadas aquí.
    #
    # La configuración de la aplicación debería ir en archivos en
    # config/initializers -- todos los archivos .rb de esa ruta
    # se cargan automáticamente

    # Establecer Time.zone a la zona por omisión y que Active Record se
    # convierta a esa zona.
    # ejecute "rake -D time" para ver tareas relacionadas con encontrar
    # nombres de zonas. Por omisión es UTC.
    config.time_zone = 'America/Bogota'

    # El locale predeterminado es :en y se cargan todas las traducciones
    # de config/locales/*.rb,yml 
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    config.i18n.default_locale = :es

    config.active_record.schema_format = :sql

    config.railties_order = [:main_app, Sivel2Sjr::Engine, 
                             Cor1440Gen::Engine, Sivel2Gen::Engine,
                             Heb412Gen::Engine, Mr519Gen::Engine, 
                             Sip::Engine, :all]

    config.hosts <<  (ENV['CONFIG_HOSTS'] && ENV['CONFIG_HOSTS'] != '' ? 
                      ENV['CONFIG_HOSTS'].downcase : 
                      'defensor.info'.downcase)

    config.relative_url_root = ENV['RUTA_RELATIVA'] || "/anzorc/si"


    # sip
    config.x.formato_fecha = ENV['FORMATO_FECHA'] || 'dd/M/yyyy'


    # heb412
    config.x.heb412_ruta = ENV['HEB412_RUTA'] && ENV['HEB412_RUTA'] != '' ?
      Pathname(ENV['HEB412_RUTA']) : Rails.root.join('public', 'heb412')


    # sivel2
    config.x.sivel2_consulta_web_publica = ENV['SIVEL2_CONSWEB_PUBLICA'] &&
      ENV['SIVEL2_CONSWEB_PUBLICA'] != ''

    config.x.sivel2_consweb_max = ENV['SIVEL2_CONSWEB_MAX'] || 2000

    config.x.sivel2_consweb_epilogo = ENV['SIVEL2_CONSWEB_EPILOGO'] ?
      ENV['SIVEL2_CONSWEB_EPILOGO'].html_safe :
      "<br>Si requiere más puede suscribirse a SIVeL Pro".html_safe

    config.x.sivel2_mapaosm_diasatras = ENV['SIVEL2_CONSWEB_EPILOGO'] || 182


    # sal7711
    config.x.sal7711_presencia_adjunto = true
    config.x.sal7711_presencia_adjuntodesc = true
    config.x.sal7711_presencia_fuenteprensa = true
    config.x.sal7711_presencia_fecha = true
    config.x.sal7711_presencia_pagina = false


    # cor1440
    config.x.cor1440_permisos_por_oficina = 
      (ENV['COR1440_PERMISOS_POR_OFICINA'] && ENV['COR1440_PERMISOS_POR_OFICINA'] != '')
   end
end
