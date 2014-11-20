# encoding: UTF-8
module Sivel2Sjr
  class EmprendimientoRespuesta < ActiveRecord::Base
    belongs_to :emprendimiento, class_name: "Sivel2Sjr::Emprendimiento", 
      foreign_key: "id_emprendimiento", validate: true
    belongs_to :respuesta, class_name: "Sivel2Sjr::Respuesta", 
      foreign_key: "id_respuesta", validate: true
  end
  
end
