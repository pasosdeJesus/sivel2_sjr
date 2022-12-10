require 'sivel2_sjr/concerns/models/etiqueta'

class Msip::Etiqueta < ActiveRecord::Base
  include Sivel2Sjr::Concerns::Models::Etiqueta
end

