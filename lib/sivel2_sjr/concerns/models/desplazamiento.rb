# encoding: UTF-8

module Sivel2Sjr
  module Concerns
    module Models
      module Desplazamiento
        extend ActiveSupport::Concern

        included do
          has_many :actosjr, class_name: "Sivel2Sjr::Actosjr", 
            validate: true

          belongs_to :expulsion, class_name: "Sip::Ubicacion", 
            foreign_key: "id_expulsion", validate: true, optional: true
          belongs_to :llegada, class_name: "Sip::Ubicacion", 
            foreign_key: "id_llegada", validate: true, optional: true
          belongs_to :clasifdesp, class_name: "Sivel2Sjr::Clasifdesp", 
            foreign_key: "id_clasifdesp", validate: true, optional: true
          belongs_to :tipodesp, class_name: "Sivel2Sjr::Tipodesp", 
            foreign_key: "id_tipodesp", validate: true, optional: true
          belongs_to :declaroante, class_name: "Sivel2Sjr::Declaroante", 
            foreign_key: "id_declaroante", validate: true, optional: true
          belongs_to :inclusion, class_name: "Sivel2Sjr::Inclusion", 
            foreign_key: "id_inclusion", validate: true, optional: true
          belongs_to :acreditacion, 
            class_name: "Sivel2Sjr::Acreditacion", 
            foreign_key: "id_acreditacion", validate: true, optional: true
          belongs_to :modalidadtierra, 
            class_name: "Sivel2Sjr::Modalidadtierra", 
            foreign_key: "id_modalidadtierra", validate: true, optional: true
          belongs_to :pais, class_name: "Sip::Pais", 
            foreign_key: "paisdecl", validate: true, optional: true
          belongs_to :departamento, class_name: "Sip::Departamento", 
            foreign_key: "departamentodecl", validate: true, optional: true
          belongs_to :municipio, class_name: "Sip::Municipio", 
            foreign_key: "municipiodecl", validate: true, optional: true
          belongs_to :caso, class_name: "Sip::Caso", 
            foreign_key: "id_caso", validate: true

          validates_presence_of :fechaexpulsion, :expulsion, 
            :fechallegada, :llegada
          validates :fechaexpulsion, uniqueness: 
            { scope: :id_caso,
              message: " ya existe otro desplazamiento con la misma fecha de expulsión" 
          }

          validate :llegada_posterior_a_expulsion
          def llegada_posterior_a_expulsion
            if fechallegada.present? && 
              fechaexpulsion.present? && fechallegada<fechaexpulsion
              errors.add(:fechallegada, 
                         " debe ser posterior a la fecha de expulsión")
            end
          end

          validate :sitios_diferentes
          def sitios_diferentes
            if llegada.present? && expulsion.present? && 
              id_llegada == id_expulsion
              errors.add(:llegada, 
                         " debe ser diferente al sitio de expulsion")
            end
          end

          validate :fechaexpulsion_unica
          def fechaexpulsion_unica
            if fechaexpulsion.present? && 
              Sivel2Sjr::Desplazamiento.where(id_caso: id_caso,
                                   fechaexpulsion: fechaexpulsion).count>1
              errors.add(:fechaexpulsion, " debe ser única")
            end
          end

        end

      end
    end
  end
end
