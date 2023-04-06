require 'sivel2_gen/concerns/models/ubicacion'

module Sivel2Sjr
  module Concerns
    module Models
      module Ubicacion
        extend ActiveSupport::Concern
        include Sivel2Gen::Concerns::Models::Ubicacion

        included do
          if Sivel2Sjr::Desplazamiento.has_attribute?(:expulsion_id)
            has_many :expulsion, class_name: "Sivel2Sjr::Desplazamiento", 
              foreign_key: "expulsion_id", validate: true, dependent: :destroy
          end
          if Sivel2Sjr::Desplazamiento.has_attribute?(:llegada_id)
            has_many :llegada, class_name: "Sivel2Sjr::Desplazamiento", 
              foreign_key: "llegada_id", validate: true, dependent: :destroy
          end
          has_one :salidarefugio, class_name: "Sivel2Sjr::Casosjr", 
            foreign_key: "salida_id", validate: true, dependent: :nullify
          has_one :llegadarefugio, class_name: "Sivel2Sjr::Casosjr", 
            foreign_key: "llegada_id", validate: true, dependent: :nullify
        end

        module ClassMethods
        end

      end
    end
  end
end
