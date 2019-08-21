# encoding: UTF-8

require 'cor1440_gen/concerns/models/actividad'

module Sivel2Sjr
  module Concerns
    module Models
      module Actividad
        extend ActiveSupport::Concern

        included do
          include Cor1440Gen::Concerns::Models::Actividad

          has_many :actividad_casosjr, dependent: :delete_all,
            class_name: 'Sivel2Sjr::ActividadCasosjr',
            foreign_key: 'actividad_id'

          has_many :casosjr, through: :actividad_casosjr, 
            class_name: 'Sivel2Sjr::Casosjr'
          accepts_nested_attributes_for :casosjr, reject_if: :all_blank
          accepts_nested_attributes_for :actividad_casosjr,
            allow_destroy: true, reject_if: :all_blank

          validate :oficina_responsable_current_usuario
          def oficina_responsable_current_usuario
            if (current_usuario && current_usuario.oficina_id && 
                responsable && responsable.oficina_id &&
                responsable.oficina_id != current_usuario.oficina_id)
                errors.add(:responsable, "Para editar responsable el " +
                  "usuario actual debe estar en la misma oficina")
            end
          end

        end # included

      end 
    end 
  end 
end 
