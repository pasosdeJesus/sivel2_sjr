# encoding: UTF-8

require 'sivel2_gen/concerns/models/ubicacion'

module Sivel2Sjr
  module Concerns
    module Models
      module Ubicacion
        extend ActiveSupport::Concern
        include Sivel2Gen::Concerns::Models::Ubicacion

        included do
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
