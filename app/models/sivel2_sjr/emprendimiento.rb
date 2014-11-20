# encoding: UTF-8
module Sivel2Sjr
  class Emprendimiento < ActiveRecord::Base
    include Sivel2Gen::Basica
  
  	has_many :emprendimiento_respuesta, 
      class_name: "Sivel2Sjr::EmprendimientoRespuesta",
      foreign_key: "id_emprendimiento", validate: true, dependent: :destroy
    has_many :respuesta, class_name: "Sivel2Sjr::Respuesta", 
      :through => :emprendimiento_respuesta
  
    validates :nombre, presence: true, allow_blank: false
    validates :fechacreacion, presence: true, allow_blank: false
  end
end
