module Sivel2Sjr
  class Proteccion < ActiveRecord::Base
    include Msip::Basica
  
  	has_many :casosjr, class_name: "Sivel2Sjr::Casosjr", 
      foreign_key: "proteccion_id", validate: true
  end
end
