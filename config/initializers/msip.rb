require 'sivel2_gen/version'

Msip.setup do |config|
      config.ruta_anexos = "/var/www/resbase/anexos-sjr"
      config.ruta_volcados = "/var/www/resbase/sivel2_sjr/"
      # En heroku los anexos son super-temporales
      if !ENV["HEROKU_POSTGRESQL_GREEN_URL"].nil?
        config.ruta_anexos = "#{Rails.root}/tmp/"
      end
      config.titulo = "SIVeL - SJR " + Sivel2Gen::VERSION
end
