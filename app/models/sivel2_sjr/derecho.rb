# encoding: UTF-8
module Sivel2Sjr
  class Derecho < ActiveRecord::Base
    include Sip::Basica
  
  	has_many :derecho_respuesta, class_name: "Sivel2Sjr::DerechoRespuesta", 
      foreign_key: "id_derecho", validate: true, dependent: :destroy
    has_many :respuesta, class_name: "Sivel2Sjr::Respuesta", 
      :through => :derecho_respuesta
  	has_many :derecho_procesosjr, class_name: "Sivel2Sjr::DerechoProcesosjr", 
      foreign_key: "id_derecho", validate: true

    has_many :ayudaestado_derecho, 
      class_name: "Sivel2Sjr::AyudaestadoDerecho",  
      foreign_key: "derecho_id", dependent: :destroy
    has_many :ayudaestado, class_name: "Sivel2Sjr::Ayudaestado", 
      :through => :ayudaestado_derecho

    has_many :ayudasjr_derecho, class_name: "Sivel2Sjr::AyudasjrDerecho",  
      foreign_key: "derecho_id", dependent: :destroy
    has_many :ayudasjr, class_name: "Sivel2Sjr::Ayudasjr", 
      :through => :ayudasjr_derecho

    has_many :motivosjr_derecho, 
      class_name: "Sivel2Sjr::MotivosjrDerecho",  
      foreign_key: "derecho_id", dependent: :destroy
    has_many :motivosjr, class_name: "Sivel2Sjr::Motivosjr", 
      :through => :motivosjr_derecho

    has_many :progestado_derecho, 
      class_name: "Sivel2Sjr::ProgestadoDerecho",  
      foreign_key: "derecho_id", dependent: :destroy
    has_many :progestado, class_name: "Sivel2Sjr::Progestado", 
      :through => :progestado_derecho

  end
end
