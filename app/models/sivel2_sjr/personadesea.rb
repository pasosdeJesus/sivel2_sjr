module Sivel2Sjr
  class Personadesea < ActiveRecord::Base
    include Msip::Basica
  
  	has_many :respuesta, class_name: "Sivel2Sjr::Respuesta", 
      foreign_key: "persona_iddesea", validate: true
  end
end
