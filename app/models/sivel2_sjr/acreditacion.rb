module Sivel2Sjr
  class Acreditacion < ActiveRecord::Base
    include Msip::Basica
  
    has_many :desplazamiento, class_name: "Sivel2Sjr::Desplazamiento", 
      foreign_key: "acreditacion_id", validate: true
  end
end
