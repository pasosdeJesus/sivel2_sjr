# encoding: UTF-8

require 'sip/concerns/models/oficina'

module Sivel2Sjr
  module Concerns
    module Models
      module Oficina
        extend ActiveSupport::Concern
        include Sip::Concerns::Models::Oficina

        included do
          has_many :casosjr, class_name: 'Sivel2Sjr::Casosjr',
            foreign_key: "oficina_id", validate: true
          
          has_many :oficina_proyectofinanciero, 
            class_name: 'Sivel2Sjr::OficinaProyectofinanciero',
            foreign_key: "oficina_id", validate: true
          has_many :proyectofinanciero, through: :oficina_proyectofinanciero,
            class_name: 'Cor1440Gen::Proyectofinanciero'
        end

        module ClassMethods
        end

      end
    end
  end
end
