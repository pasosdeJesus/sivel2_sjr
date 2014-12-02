# encoding: UTF-8
module Sivel2Sjr
  class Ayudaestado < ActiveRecord::Base
    include Sivel2Gen::Basica
  
    belongs_to :derecho, class_name: "Sivel2Sjr::Derecho"
  
  	has_many :ayudaestado_respuesta, 
      class_name: "Sivel2Sjr::AyudaestadoRespuesta", 
      foreign_key: "id_ayudaestado", validate: true, dependent: :destroy
    has_many :respuesta, class_name: "Sivel2Sjr::Respuesta", 
      :through => :ayudaestado_respuesta
  end
end
