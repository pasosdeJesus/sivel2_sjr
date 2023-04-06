module Sivel2Sjr
  module Concerns
    module Models
      module Statusmigratorio
        
        extend ActiveSupport::Concern
        include Msip::Basica

        included do
          has_many :casosjr, class_name: "Sivel2Sjr::Casosjr", 
            foreign_key: "estatusmigratorio_id", validate: true
        end

      end
    end
  end
end
