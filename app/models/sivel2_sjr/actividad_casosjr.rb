# encoding: UTF-8

require 'sivel2_sjr/concerns/models/actividad_casosjr'

class Sivel2Sjr::ActividadCasosjr < ActiveRecord::Base
  include Sivel2Sjr::Concerns::Models::ActividadCasosjr
end
