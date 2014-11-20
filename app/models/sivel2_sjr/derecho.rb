# encoding: UTF-8
module Sivel2Sjr
  class Derecho < ActiveRecord::Base
    include Sivel2Gen::Basica
  
  	has_many :derecho_respuesta, class_name: "Sivel2Sjr::DerechoRespuesta", 
      foreign_key: "id_derecho", validate: true, dependent: :destroy
    has_many :respuesta, class_name: "Sivel2Sjr::Respuesta", 
      :through => :derecho_respuesta
  	has_many :derecho_procesosjr, class_name: "Sivel2Sjr::DerechoProcesosjr", 
      foreign_key: "id_derecho", validate: true
  
    validates :nombre, presence: true, allow_blank: false
    validates :fechacreacion, presence: true, allow_blank: false
  end
end
