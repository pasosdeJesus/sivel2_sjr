# encoding: UTF-8

require 'sivel2_sjr/concerns/models/actividad'

module Cor1440Gen
  class Actividad < ActiveRecord::Base

    include Sivel2Sjr::Concerns::Models::Actividad
   
  end
end
