# encoding: UTF-8

module Sivel2Sjr
  module Concerns
    module Models
      module Respuesta
        extend ActiveSupport::Concern

        included do
          belongs_to :caso, class_name: "Sivel2Gen::Caso", 
            foreign_key: "id_caso"

          has_many :aslegal_respuesta, 
            class_name: "Sivel2Sjr::AslegalRespuesta",  
            foreign_key: "id_respuesta", validate:true, 
            dependent: :delete_all
          accepts_nested_attributes_for :aslegal_respuesta, 
            reject_if: :all_blank, update_only: true
          has_many :aslegal, class_name: "Sivel2Sjr::Aslegal", 
            :through => :aslegal_respuesta

          has_many :aspsicosocial_respuesta,  validate: true,
            class_name: "Sivel2Sjr::AspsicosocialRespuesta",  
            foreign_key: "id_respuesta", dependent: :destroy 
          has_many :aspsicosocial, 
            class_name: "Sivel2Sjr::Aspsicosocial", 
            :through => :aspsicosocial_respuesta
          accepts_nested_attributes_for :aspsicosocial_respuesta, 
            reject_if: :all_blank, update_only: true


          has_many :ayudasjr_respuesta, 
            class_name: "Sivel2Sjr::AyudasjrRespuesta",  
            foreign_key: "id_respuesta", dependent: :delete_all
          # no funcionó accepts_nested_attributes_for :ayudasjr_respuesta, reject_if: :all_blank, update_only: true
          has_many :ayudasjr, class_name: "Sivel2Sjr::Ayudasjr", 
            :through => :ayudasjr_respuesta

          has_many :derecho_respuesta, 
            class_name: "Sivel2Sjr::DerechoRespuesta",  
            foreign_key: "id_respuesta", dependent: :delete_all
          accepts_nested_attributes_for :derecho_respuesta, 
            reject_if: :all_blank, update_only: true
          has_many :derecho, class_name: "Sivel2Sjr::Derecho", 
            :through => :derecho_respuesta

        end
      end
    end
  end
end
