require 'sivel2_sjr/concerns/models/ubicacion'

class Msip::Ubicacion < ActiveRecord::Base
  include Sivel2Sjr::Concerns::Models::Ubicacion
end

