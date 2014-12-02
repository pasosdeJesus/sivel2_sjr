# encoding: UTF-8
module Sivel2Sjr
  class Motivosjr < ActiveRecord::Base
    include Sivel2Gen::Basica
  
    belongs_to :derecho, class_name: "Sivel2Sjr::Derecho"

    has_many :motivosjr_respuesta, class_name: "Sivel2Sjr::MotivosjrRespuesta",
      foreign_key: "id_motivosjr", validate: true, dependent: :destroy
    has_many :respuesta, class_name: "Sivel2Sjr::Respuesta", 
      through: :motivosjr_respuesta
  end
end
