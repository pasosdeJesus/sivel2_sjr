# encoding: UTF-8
module Sivel2Sjr
  class Progestado < ActiveRecord::Base
    include Sivel2Gen::Basica
  
    belongs_to :derecho, class_name: "Sivel2Sjr::Derecho"

  	has_many :progestado_respuesta, 
      class_name: "Sivel2Sjr::ProgestadoRespuesta",
      foreign_key: "id_progestado", validate: true, dependent: :destroy
    has_many :respuesta, class_name: "Sivel2Sjr::Respuesta", 
      :through => :progestado_respuesta
  end
end
