module Sivel2Sjr
  class Motivosjr < ActiveRecord::Base
    include Msip::Basica
  
    has_many :motivosjr_respuesta, class_name: "Sivel2Sjr::MotivosjrRespuesta",
      foreign_key: "id_motivosjr", validate: true, dependent: :destroy
    has_many :respuesta, class_name: "Sivel2Sjr::Respuesta", 
      through: :motivosjr_respuesta

    has_many :motivosjr_derecho, 
      class_name: "Sivel2Sjr::MotivosjrDerecho", 
      foreign_key: "motivosjr_id", validate: true, dependent: :destroy
    has_many :derecho, class_name: "Sivel2Sjr::Derecho", 
      :through => :motivosjr_derecho
    accepts_nested_attributes_for :motivosjr_derecho, reject_if: :all_blank, 
      update_only: true

  end
end
