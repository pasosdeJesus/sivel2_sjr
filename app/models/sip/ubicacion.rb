require 'sivel2_sjr/concerns/models/ubicacion'

class Sip::Ubicacion < ActiveRecord::Base
  include Sivel2Sjr::Concerns::Models::Ubicacion
end

