module Sivel2Sjr
  class Inclusion < ActiveRecord::Base
    include Sip::Basica
  
  	has_many :desplazamiento, class_name: "Sivel2Sjr::Desplazamiento", 
      foreign_key: "id_inclusion", validate: true
  end
end
