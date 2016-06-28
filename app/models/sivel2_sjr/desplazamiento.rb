# encoding: UTF-8
require 'sivel2_sjr/concerns/models/desplazamiento'

class Sivel2Sjr::Desplazamiento < ActiveRecord::Base
  include Sivel2Sjr::Concerns::Models::Desplazamiento
end

