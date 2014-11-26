# encoding: UTF-8
module Sivel2Sjr
  class Respuesta < ActiveRecord::Base
  
    # Debería ser: belongs_to :casosjr, class_name: "Sivel2Sjr::Casosjr", foreign_key: "id_caso", validate: true
    belongs_to :caso, class_name: "Sivel2Sjr::Caso", foreign_key: "id_caso", 
      validate: true
  
    has_many :aslegal, class_name: "Sivel2Sjr::Aslegal", 
      :through => :aslegal_respuesta
    has_many :aslegal_respuesta, class_name: "Sivel2Sjr::AslegalRespuesta",  
      foreign_key: "id_respuesta", dependent: :destroy, validate: true
    accepts_nested_attributes_for :aslegal_respuesta, reject_if: :all_blank, 
      update_only: true
  
    has_many :ayudasjr, class_name: "Sivel2Sjr::Ayudasjr", 
      :through => :ayudasjr_respuesta
    has_many :ayudasjr_respuesta, class_name: "Sivel2Sjr::AyudasjrRespuesta",  
      foreign_key: "id_respuesta", dependent: :destroy
    # didn't work either: accepts_nested_attributes_for :ayudasjr_respuesta, reject_if: :all_blank, update_only: true
  
    has_many :derecho, class_name: "Sivel2Sjr::Derecho", 
      :through => :derecho_respuesta
    has_many :derecho_respuesta, class_name: "Sivel2Sjr::DerechoRespuesta",  
      foreign_key: "id_respuesta", dependent: :destroy, validate: true
    accepts_nested_attributes_for :derecho_respuesta, reject_if: :all_blank, 
      update_only: true
  
  end
end
