# encoding: UTF-8

require 'sivel2_sjr/concerns/models/ubicacion'

class Sivel2Gen::Ubicacion < ActiveRecord::Base
  include Sivel2Sjr::Concerns::Models::Ubicacion
end

