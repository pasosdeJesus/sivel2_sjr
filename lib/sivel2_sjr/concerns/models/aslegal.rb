module Sivel2Sjr
  module Concerns
    module Models
      module Aslegal
        extend ActiveSupport::Concern

        include Msip::Basica
        included do
  
          has_and_belongs_to_many :respuesta, 
            class_name: "Sivel2Sjr::Respuesta",
            foreign_key: "aslegal_id", 
            validate: true, 
            association_foreign_key: "respuesta_id",
            join_table: 'sivel2_sjr_aslegal_respuesta' 

        end #included

      end
    end
  end
end
