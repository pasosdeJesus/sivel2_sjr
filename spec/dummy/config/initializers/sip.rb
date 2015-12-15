# encoding: UTF-8

require 'sivel2_sjr/version'

Sip.setup do |config|
      config.ruta_anexos = "/var/www/resbase/anexos-sjr"
      config.ruta_volcados = "/var/www/resbase/anexos-sjr/bd/"
      # En heroku los anexos son super-temporales
      if !ENV["HEROKU_POSTGRESQL_GREEN_URL"].nil?
        config.ruta_anexos = "#{Rails.root}/tmp/"
      end
      config.titulo = "SIVeL - SJR " + Sivel2Sjr::VERSION
end
