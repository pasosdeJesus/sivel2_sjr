module Sivel2Sjr
  class DerechoRespuesta < ActiveRecord::Base
    belongs_to :derecho, class_name: "Sivel2Sjr::Derecho", 
      foreign_key: "id_derecho", validate: true
    belongs_to :respuesta, class_name: "Sivel2Sjr::Respuesta", 
      foreign_key: "id_respuesta", validate: true
  end
end
