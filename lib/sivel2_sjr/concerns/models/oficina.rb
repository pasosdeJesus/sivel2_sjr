require 'msip/concerns/models/oficina'

module Sivel2Sjr
  module Concerns
    module Models
      module Oficina
        extend ActiveSupport::Concern
        include Msip::Concerns::Models::Oficina

        included do
          has_many :casosjr, class_name: 'Sivel2Sjr::Casosjr',
            foreign_key: "oficina_id", validate: true
          
          has_and_belongs_to_many :proyectofinanciero, 
            class_name: 'Cor1440Gen::Proyectofinanciero',
            foreign_key: 'oficina_id', 
            validate: true,
            association_foreign_key: "proyectofinanciero_id",
            join_table: 'sivel2_sjr_oficina_proyectofinanciero'

        end

        module ClassMethods
        end

      end
    end
  end
end
