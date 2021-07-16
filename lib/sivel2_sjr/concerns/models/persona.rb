require 'sivel2_gen/concerns/models/persona'
require 'cor1440_gen/concerns/models/persona'

module Sivel2Sjr
  module Concerns
    module Models
      module Persona
        extend ActiveSupport::Concern

        included do
          include Sivel2Gen::Concerns::Models::Persona
          include Cor1440Gen::Concerns::Models::Persona

          has_many :casosjr, class_name: 'Sivel2Sjr::Casosjr',
            foreign_key: "contacto_id"

          belongs_to :nacional, class_name: "Sip::Pais", 
            foreign_key: "nacionalde", validate: true, optional: true

        end

        module ClassMethods
        end

      end
    end
  end
end
