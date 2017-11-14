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

          has_many :oficina_proyectofinanciero, dependent: :delete_all,
            class_name: 'Sivel2Sjr::OficinaProyectofinanciero',
            foreign_key: 'proyectofinanciero_id'
          has_many :oficina, through: :oficina_proyectofinanciero,
            class_name: 'Sip::Oficina'

          scope :filtro_oficina_ids, lambda { |o|
            joins(:oficina_proyectofinanciero).
              where('sivel2_sjr_oficina_proyectofinanciero.oficina_id=?', o)
          }

        end

      end # module Proyectofinanciero
    end
  end
end
