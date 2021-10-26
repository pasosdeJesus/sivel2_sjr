require 'sivel2_sjr/concerns/models/respuesta'
module Sivel2Sjr
  class Respuesta < ActiveRecord::Base
    include Sivel2Sjr::Concerns::Models::Respuesta
  end
end
