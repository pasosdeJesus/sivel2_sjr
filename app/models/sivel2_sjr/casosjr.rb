# encoding: UTF-8
module Sivel2Sjr
  class Casosjr < ActiveRecord::Base
  	has_many :respuesta, class_name: "Sivel2Sjr::Respuesta", validate: true,
      foreign_key: "id_caso", dependent: :destroy
  
  	# Ordenados por foreign_key para comparar con esquema en base
  	belongs_to :usuario, class_name: "Sivel2Sjr::Usuario", 
      foreign_key: "asesor", validate: true
  	belongs_to :comosupo, class_name: "Sivel2Sjr::Comosupo", 
      foreign_key: "comosupo_id", validate: true
  	belongs_to :contacto, class_name: "Sivel2Gen::Persona",  
      foreign_key: "contacto", validate: true
  	belongs_to :caso, class_name: "Sivel2Gen::Caso", validate: true,
      foreign_key: "id_caso", inverse_of: :casosjr
  	belongs_to :categoria, class_name: "Sivel2Sjr::Categoria", validate: true, 
      foreign_key: "categoriaref"
  	belongs_to :idioma, class_name: "Sivel2Sjr::Idioma", 
      foreign_key: "id_idioma", validate: true
  	belongs_to :llegada, class_name: "Sivel2Gen::Ubicacion", validate: true,
      class_name: "Ubicacion", foreign_key: "id_llegada"
  	belongs_to :proteccion, class_name: "Sivel2Sjr::Proteccion", 
      foreign_key: "id_proteccion", validate: true
  	belongs_to :regionsjr, class_name: "Sivel2Sjr::Regionsjr", 
      foreign_key: "id_regionsjr", validate: true
  	belongs_to :salida, class_name: "Sivel2Sjr::Ubicacion", validate: true,
      foreign_key: "id_salida"
  	belongs_to :statusmigratorio, class_name: "Sivel2Sjr::Statusmigratorio", 
      foreign_key: "id_statusmigratorio", validate: true
  
  	self.primary_key = :id_caso
  
  	validates_presence_of :fecharec
  	validates_presence_of :asesor
    validates_presence_of :regionsjr
  
    validate :sitios_diferentes
    def sitios_diferentes
      if llegada.present? && salida.present? && id_llegada == id_salida
        errors.add(:llegada, " debe ser diferente al sitio de salida")
      end
    end
  
    validate :llegada_posterior_a_salida
    def llegada_posterior_a_salida
      if fechallegada.present? && fechasalida.present? && fechallegada<fechasalida
        errors.add(:fechallegada, " debe ser posterior a la fecha de salida")
      end
    end
  
    validate :rol_usuario
    def rol_usuario
  		if (caso && caso.current_usuario &&
          caso.current_usuario.rol != Ability::ROLADMIN &&
          caso.current_usuario.rol != Ability::ROLDIR && 
          usuario.regionsjr_id != regionsjr.id && regionsjr.id != 1)
  			errors.add(:usuario, "Asesor debe ser de oficina")
  		end
      if (caso && caso.current_usuario &&
          caso.current_usuario.rol == Ability::ROLSIST || 
           caso.current_usuario.rol == Ability::ROLCOOR || 
           caso.current_usuario.rol == Ability::ROLANALI)
          if (regionsjr.id != caso.current_usuario.regionsjr_id)
              errors.add(:regionsjr, "Solo puede editar casos de su oficina")
          end
      end
    end
  
  end
end
