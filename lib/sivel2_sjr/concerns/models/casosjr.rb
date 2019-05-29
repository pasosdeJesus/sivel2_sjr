# encoding: UTF-8

module Sivel2Sjr
  module Concerns
    module Models
      module Casosjr
        extend ActiveSupport::Concern

        included do
          
          has_many :respuesta, class_name: "Sivel2Sjr::Respuesta", 
            validate: true, foreign_key: "id_caso"#, dependent: :destroy

          # Ordenados por foreign_key para comparar con esquema en base
          belongs_to :usuario, class_name: "Usuario", 
            foreign_key: "asesor", validate: true
          belongs_to :comosupo, class_name: "Sivel2Sjr::Comosupo", 
            foreign_key: "comosupo_id", validate: true, optional: true
          belongs_to :contacto, class_name: "Sip::Persona",  
            foreign_key: "contacto_id"
          belongs_to :caso, class_name: "Sivel2Gen::Caso", validate: true,
            foreign_key: "id_caso", inverse_of: :casosjr
          belongs_to :categoria, class_name: "Sivel2Gen::Categoria", 
            validate: true, foreign_key: "categoriaref", optional: true
          belongs_to :idioma, class_name: "Sivel2Sjr::Idioma", 
            foreign_key: "id_idioma", validate: true, optional: true
          belongs_to :llegada, class_name: "Sip::Ubicacion", validate: true,
            foreign_key: "id_llegada", optional: true
          belongs_to :proteccion, class_name: "Sivel2Sjr::Proteccion", 
            foreign_key: "id_proteccion", validate: true, optional: true
          belongs_to :oficina, class_name: "Sip::Oficina", 
            foreign_key: "oficina_id", validate: true, optional: true
          belongs_to :salida, class_name: "Sip::Ubicacion", validate: true,
            foreign_key: "id_salida", optional: true
          belongs_to :statusmigratorio, 
            class_name: "Sivel2Sjr::Statusmigratorio", 
            foreign_key: "id_statusmigratorio", validate: true, optional: true

          self.primary_key = :id_caso

          validates_presence_of :fecharec
          validates_presence_of :asesor
          validates_presence_of :oficina

          validate :sitios_diferentes
          def sitios_diferentes
            if llegada.present? && salida.present? && id_llegada == id_salida
              errors.add(:llegada, " debe ser diferente al sitio de salida")
            end
          end

          validate :llegada_posterior_a_salida
          def llegada_posterior_a_salida
            if fechallegada.present? && fechasalida.present? && 
              fechallegada < fechasalida
              errors.add(:fechallegada, 
                         " debe ser posterior a la fecha de salida")
            end
          end

          # Verifica que un usuariosea de la misma oficina de otro
          def self.asesor_de_oficina(current_usuario, usuario, oficina)
              current_usuario.rol == Ability::ROLADMIN ||
              current_usuario.rol == Ability::ROLDIR ||
              usuario.rol == Ability::ROLADMIN ||
              usuario.rol == Ability::ROLDIR ||
              usuario.oficina_id == oficina.id || oficina.id == 1
          end

          # Verifica que un usuario edita caso de su oficina
          def self.asesor_edita_de_su_oficina(current_usuario, oficina)
            (current_usuario.rol != Ability::ROLSIST &&
             current_usuario.rol != Ability::ROLCOOR &&
             current_usuario.rol != Ability::ROLANALI) ||
             oficina.id == current_usuario.oficina_id
          end
 
          validate :rol_usuario
          def rol_usuario
            if (caso && caso.current_usuario && 
                !Sivel2Sjr::Casosjr::asesor_de_oficina(
                  caso.current_usuario, usuario, oficina))
              errors.add(:usuario, "Asesor debe ser de oficina")
            end
            if (caso && caso.current_usuario &&
                !Sivel2Sjr::Casosjr::asesor_edita_de_su_oficina(
                  caso.current_usuario, oficina))
              errors.add(:oficina, "Solo puede editar casos de su oficina")
            end
          end
  
        end

        module ClassMethods
        end

      end
    end
  end
end
