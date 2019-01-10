# encoding: UTF-8

module Sivel2Sjr
  module Concerns
    module Models
      module Derecho
        extend ActiveSupport::Concern

        include Sip::Basica
        included do
  
          has_and_belongs_to_many :respuesta, 
            class_name: "Sivel2Sjr::Respuesta", 
            foreign_key: "id_derecho", 
            validate: true,
            association_foreign_key: "id_respuesta",
            join_table: 'sivel2_sjr_derecho_respuesta' 

          has_and_belongs_to_many :ayudaestado, 
            class_name: "Sivel2Sjr::Ayudaestado", 
            foreign_key: "derecho_id",
            association_foreign_key: "ayudaestado_id",
            join_table: 'sivel2_sjr_ayudaestado_derecho' 

          has_and_belongs_to_many :ayudasjr, 
            class_name: "Sivel2Sjr::Ayudasjr", 
            foreign_key: "derecho_id",
            association_foreign_key: "ayudasjr_id",
            join_table: 'sivel2_sjr_ayudasjr_derecho' 

          has_and_belongs_to_many :motivosjr, 
            class_name: "Sivel2Sjr::Motivosjr", 
            foreign_key: "derecho_id",
            association_foreign_key: "motivosjr_id",
            join_table: 'sivel2_sjr_motivosjr_derecho' 

          has_and_belongs_to_many :progestado, 
            class_name: "Sivel2Sjr::Progestado", 
            foreign_key: "derecho_id",
            association_foreign_key: "progestado_id",
            join_table: 'sivel2_sjr_progestado_derecho' 

        end

        module ClassMethods
        end

      end
    end
  end
end

