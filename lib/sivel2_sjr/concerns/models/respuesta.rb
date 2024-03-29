module Sivel2Sjr
  module Concerns
    module Models
      module Respuesta
        extend ActiveSupport::Concern

        included do

          include Msip::Modelo

          belongs_to :caso, class_name: "Sivel2Gen::Caso", 
            foreign_key: "caso_id", optional: false

          has_and_belongs_to_many :aslegal, 
            class_name: "Sivel2Sjr::Aslegal", 
            foreign_key: "respuesta_id", 
            validate: true, 
            association_foreign_key: "aslegal_id",
            join_table: 'sivel2_sjr_aslegal_respuesta'
          #accepts_nested_attributes_for :aslegal_respuesta, 
          #  reject_if: :all_blank, update_only: true

          has_and_belongs_to_many :aspsicosocial, 
            class_name: "Sivel2Sjr::Aspsicosocial", 
            foreign_key: "respuesta_id",
            association_foreign_key: "aspsicosocial_id",
            join_table: 'sivel2_sjr_aspsicosocial_respuesta'

          has_and_belongs_to_many :ayudasjr, 
            class_name: "Sivel2Sjr::Ayudasjr", 
            foreign_key: "respuesta_id",
            association_foreign_key: "ayudasjr_id",
            join_table: 'sivel2_sjr_ayudasjr_respuesta'

          has_and_belongs_to_many :derecho, 
            class_name: "Sivel2Sjr::Derecho", 
            foreign_key: "respuesta_id",
            association_foreign_key: "derecho_id",
            join_table: 'sivel2_sjr_derecho_respuesta'
          #accepts_nested_attributes_for :derecho_respuesta, 
          #  reject_if: :all_blank, update_only: true

        end
      end
    end
  end
end
