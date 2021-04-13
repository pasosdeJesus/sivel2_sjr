# encoding: UTF-8

require 'sivel2_gen/concerns/models/ubicacion'

module Sivel2Sjr
  module Concerns
    module Models
      module Ubicacion
        extend ActiveSupport::Concern
        include Sivel2Gen::Concerns::Models::Ubicacion

        included do
          if Sivel2Sjr::Desplazamiento.has_attribute?(:id_expulsion)
            has_many :expulsion, class_name: "Sivel2Sjr::Desplazamiento", 
              foreign_key: "id_expulsion", validate: true, dependent: :destroy
          end
          if Sivel2Sjr::Desplazamiento.has_attribute?(:id_llegada)
            has_many :llegada, class_name: "Sivel2Sjr::Desplazamiento", 
              foreign_key: "id_llegada", validate: true, dependent: :destroy
          end
          has_one :salidarefugio, class_name: "Sivel2Sjr::Casosjr", 
            foreign_key: "id_salida", validate: true, dependent: :nullify
          has_one :llegadarefugio, class_name: "Sivel2Sjr::Casosjr", 
            foreign_key: "id_llegada", validate: true, dependent: :nullify
        end

        module ClassMethods
        end

      end
    end
  end
end
