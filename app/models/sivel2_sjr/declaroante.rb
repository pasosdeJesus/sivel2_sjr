module Sivel2Sjr
  class Declaroante < ActiveRecord::Base
    include Msip::Basica
  
  	has_many :desplazamiento, class_name: "Sivel2Sjr::Desplazamiento", 
      foreign_key: "declaroante_id", validate: true
  end
end
