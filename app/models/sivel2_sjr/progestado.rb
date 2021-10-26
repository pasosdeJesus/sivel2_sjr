module Sivel2Sjr
  class Progestado < ActiveRecord::Base
    include Sip::Basica
  
    has_many :progestado_respuesta, 
      class_name: "Sivel2Sjr::ProgestadoRespuesta",
      foreign_key: "id_progestado", validate: true, dependent: :destroy
    has_many :respuesta, class_name: "Sivel2Sjr::Respuesta", 
      :through => :progestado_respuesta

    has_many :progestado_derecho, 
      class_name: "Sivel2Sjr::ProgestadoDerecho", 
      foreign_key: "progestado_id", validate: true, dependent: :destroy
    has_many :derecho, class_name: "Sivel2Sjr::Derecho", 
      :through => :progestado_derecho
    accepts_nested_attributes_for :progestado_derecho, reject_if: :all_blank, 
      update_only: true
  end
end
