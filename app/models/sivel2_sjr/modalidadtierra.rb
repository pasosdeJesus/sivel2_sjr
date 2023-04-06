module Sivel2Sjr
  class Modalidadtierra < ActiveRecord::Base
    include Msip::Basica
  
  	has_many :desplazamiento, class_name: "Sivel2Sjr::Desplazamiento", 
      foreign_key: "modalidadtierra_id", validate: true
  end
end
