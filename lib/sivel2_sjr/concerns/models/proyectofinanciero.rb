# encoding: UTF-8

require 'cor1440_gen/concerns/models/proyectofinanciero'

module Sivel2Sjr
  module Concerns
    module Models
      module Proyectofinanciero
        extend ActiveSupport::Concern
        include Cor1440Gen::Concerns::Models::Proyectofinanciero

        included do
          @current_usuario = nil
          attr_accessor :current_usuario

          has_and_belongs_to_many :oficina, 
            class_name: 'Sip::Oficina',
            foreign_key: 'proyectofinanciero_id',
            association_foreign_key: "oficina_id",
            join_table: 'sivel2_sjr_oficina_proyectofinanciero'

          scope :filtro_oficina_ids, lambda { |o|
            joins(:oficina_proyectofinanciero).
              where('sivel2_sjr_oficina_proyectofinanciero.oficina_id=?', o)
          }

        end

      end # module Proyectofinanciero
    end
  end
end
