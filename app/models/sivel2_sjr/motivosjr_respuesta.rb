# encoding: UTF-8
module Sivel2Sjr
  class MotivosjrRespuesta < ActiveRecord::Base
    belongs_to :motivosjr, class_name: "Sivel2Sjr::Motivosjr", 
      foreign_key: "id_motivosjr", validate: true
    belongs_to :respuesta, class_name: "Sivel2Sjr::Respuesta", 
      foreign_key: "id_respuesta", validate: true
  end
end
