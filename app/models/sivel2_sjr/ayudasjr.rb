# encoding: UTF-8
module Sivel2Sjr
  class Ayudasjr < ActiveRecord::Base
    include Sivel2Gen::Basica
  
    belongs_to :derecho, class_name: "Sivel2Sjr::Derecho"
  	has_many :ayudasjr_respuesta, class_name: "Sivel2Sjr::AyudasjrRespuesta", 
      foreign_key: "id_ayudasjr", validate: true, dependent: :destroy
    has_many :respuesta, class_name: "Sivel2Sjr::Respuesta", 
      :through => :ayudasjr_respuesta

    has_many :ayudasjr_derecho, 
      class_name: "Sivel2Sjr::AyudasjrDerecho", 
      foreign_key: "id_ayudasjr", validate: true, dependent: :destroy
    has_many :derecho, class_name: "Sivel2Sjr::Derecho", 
      :through => :ayudasjr_derecho
    accepts_nested_attributes_for :ayudasjr_derecho, reject_if: :all_blank, 
      update_only: true

  end
end
