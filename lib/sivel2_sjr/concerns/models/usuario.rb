# encoding: UTF-8

require 'sivel2_gen/concerns/models/usuario'

module Sivel2Sjr
  module Concerns
    module Models
      module Usuario
        extend ActiveSupport::Concern
        include Sivel2Gen::Concerns::Models::Usuario

        included do
          has_many :casosjr, class_name: 'Sivel2Sjr::Casosjr',
            foreign_key: "asesor", validate: true
          has_many :etiqueta_usuario, class_name: 'Sivel2Sjr::EtiquetaUsuario',
            dependent: :delete_all
          has_many :etiqueta, class_name: 'Sip::Etiqueta',
            through: :etiqueta_usuario

          belongs_to :oficina, foreign_key: "oficina_id", validate: true,
            class_name: 'Sip::Oficina'

          validate :rol_usuario
          def rol_usuario
            if oficina && (rol == Ability::ROLADMIN ||
                           rol == Ability::ROLINV || 
                           rol == Ability::ROLDIR)
              errors.add(:oficina, "Oficina debe estar en blanco para el rol elegido")
            end
            if !oficina && rol != Ability::ROLADMIN && rol != Ability::ROLINV && 
              rol != Ability::ROLDIR
              errors.add(:oficina, "El rol elegido debe tener oficina")
            end
            if (etiqueta.count != 0 && rol != Ability::ROLINV) 
              errors.add(:etiqueta, "El rol elegido no requiere etiquetas de compartir")
            end
            if (!current_usuario.nil? && current_usuario.rol == Ability::ROLCOOR)
              if (oficina.nil? || 
                  oficina.id != current_usuario.oficina_id)
                errors.add(:oficina, "Solo puede editar usuarios de su oficina")
              end
            end
          end

          scope :filtro_oficina_id, lambda {|o|
            where(oficina_id: o)
          }

        end # included

        module ClassMethods
        end

      end
    end
  end
end

