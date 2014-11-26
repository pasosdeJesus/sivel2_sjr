# encoding: UTF-8

require 'sivel2_sjr/concerns/models/etiqueta'

class Sivel2Gen::Etiqueta < ActiveRecord::Base
  include Sivel2Sjr::Concerns::Models::Etiqueta
end

