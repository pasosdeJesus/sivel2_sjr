# encoding: UTF-8
module Sivel2Sjr
  class Personadesea < ActiveRecord::Base
    include Sip::Basica
  
  	has_many :respuesta, class_name: "Sivel2Sjr::Respuesta", 
      foreign_key: "id_personadesea", validate: true
  end
end
