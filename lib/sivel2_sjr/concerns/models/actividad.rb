# encoding: UTF-8

module Sivel2Sjr
  module Concerns
    module Models
      module Actividad
        extend ActiveSupport::Concern

        included do
          include Cor1440Gen::Conerns::Models::Actividad

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
