module Sivel2Sjr
  module Concerns
    module Models
      module Statusmigratorio
        
        extend ActiveSupport::Concern
        include Sip::Basica

        included do
          has_many :casosjr, class_name: "Sivel2Sjr::Casosjr", 
            foreign_key: "id_statusmigratorio", validate: true
        end

      end
    end
  end
end
