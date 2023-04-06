module Sivel2Sjr
  class Clasifdesp < ActiveRecord::Base
    include Msip::Basica
  
  	has_many :desplazamiento, class_name: "Sivel2Sjr::Desplazamiento", 
      foreign_key: "clasifdesp_id", validate: true
  end
end
