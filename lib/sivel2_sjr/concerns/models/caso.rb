require 'sivel2_gen/concerns/models/caso'

module Sivel2Sjr
  module Concerns
    module Models
      module Caso 
        extend ActiveSupport::Concern
        include Sivel2Gen::Concerns::Models::Caso

        included do
          has_many :actosjr, class_name: 'Sivel2Sjr::Actosjr',
            :through => :acto, dependent: :destroy
          accepts_nested_attributes_for :actosjr, allow_destroy: true, 
            reject_if: :all_blank

          has_one :casosjr, class_name: 'Sivel2Sjr::Casosjr',
            foreign_key: "id_caso", inverse_of: :caso, validate: true, 
            dependent: :destroy
          accepts_nested_attributes_for :casosjr, allow_destroy: true, 
            update_only: true

          # respuesta deberìa ser con :through => :casosjr pero más dificil guardar
          has_many :respuesta, class_name: 'Sivel2Sjr::Respuesta',
            foreign_key: "id_caso", validate:true, dependent: :destroy
          accepts_nested_attributes_for :respuesta, allow_destroy: true, 
            reject_if: :all_blank

          has_many :desplazamiento, class_name: 'Sivel2Sjr::Desplazamiento',
            foreign_key: "id_caso", validate: true, dependent: :destroy
          accepts_nested_attributes_for :desplazamiento , allow_destroy: true, 
            reject_if: :all_blank
          has_many :victimasjr, class_name: 'Sivel2Sjr::Victimasjr',
            :through => :victima, dependent: :destroy
          accepts_nested_attributes_for :victimasjr, allow_destroy: true, 
            reject_if: :all_blank

          validate :rol_usuario

        end



        module ClassMethods

        end


        def rol_usuario
          # current_usuario será nil cuando venga de validaciones por ejemplo
          # validate_presence_of :caso
          # que se hace desde acto
          if (current_usuario &&
              current_usuario.rol != Ability::ROLADMIN &&
              current_usuario.rol != Ability::ROLDIR &&
              current_usuario.rol != Ability::ROLSIST &&
              current_usuario.rol != Ability::ROLCOOR &&
              current_usuario.rol != Ability::ROLANALI) 
            errors.add(:id, "Rol de usuario no apropiado para editar")
          end
          if (current_usuario &&
              current_usuario.rol == Ability::ROLSIST && 
              (casosjr.asesor != current_usuario.id))
            errors.add(:id, "Sistematizador solo puede editar sus casos")
          end
        end

        def iporsivel2sjr
          "por"
        end

      end
    end
  end
end
