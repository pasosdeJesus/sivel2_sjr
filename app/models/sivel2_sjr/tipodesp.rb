module Sivel2Sjr
  class Tipodesp < ActiveRecord::Base
    include Sip::Basica
  
  	has_many :desplazamiento, class_name: "Sivel2Sjr::Desplazamiento", 
      foreign_key: "id_tipodesp", validate: true
  end
end
