# encoding: UTF-8
module Sivel2Sjr
  class Ayudasjr < ActiveRecord::Base
    include Sivel2Gen::Basica
  
    belongs_to :derecho, class_name: "Sivel2Sjr::Derecho"
  	has_many :ayudasjr_respuesta, class_name: "Sivel2Sjr::AyudasjrRespuesta", 
      foreign_key: "id_ayudasjr", validate: true, dependent: :destroy
    has_many :respuesta, class_name: "Sivel2Sjr::Respuesta", 
      :through => :ayudasjr_respuesta
  end
end
