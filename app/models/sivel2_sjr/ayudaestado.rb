module Sivel2Sjr
  class Ayudaestado < ActiveRecord::Base
    include Sip::Basica
  
  	has_many :ayudaestado_respuesta, 
      class_name: "Sivel2Sjr::AyudaestadoRespuesta", 
      foreign_key: "id_ayudaestado", validate: true, dependent: :destroy
    has_many :respuesta, class_name: "Sivel2Sjr::Respuesta", 
      :through => :ayudaestado_respuesta

    has_many :ayudaestado_derecho, 
      class_name: "Sivel2Sjr::AyudaestadoDerecho", 
      foreign_key: "ayudaestado_id", validate: true, dependent: :destroy
    has_many :derecho, class_name: "Sivel2Sjr::Derecho", 
      :through => :ayudaestado_derecho
    accepts_nested_attributes_for :ayudaestado_derecho, reject_if: :all_blank, 
      update_only: true

  end
end
