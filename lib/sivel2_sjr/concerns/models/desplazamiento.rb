module Sivel2Sjr
  module Concerns
    module Models
      module Desplazamiento
        extend ActiveSupport::Concern

        included do

          include Msip::Modelo

          has_many :actosjr, class_name: "Sivel2Sjr::Actosjr", 
            validate: true

          if ActiveRecord::Base.connection.data_source_exists?(
              'sivel2_sjr_desplazamiento') && 
             Sivel2Sjr::Desplazamiento.has_attribute?(:expulsion_id)
            belongs_to :expulsion, class_name: "Msip::Ubicacion", 
              foreign_key: "expulsion_id", validate: true, optional: true
          end
          if ActiveRecord::Base.connection.data_source_exists?(
              'sivel2_sjr_desplazamiento') && 
              Sivel2Sjr::Desplazamiento.has_attribute?(:llegada_id)
            belongs_to :llegada, class_name: "Msip::Ubicacion", 
              foreign_key: "llegada_id", validate: true, optional: true
          end
          belongs_to :clasifdesp, class_name: "Sivel2Sjr::Clasifdesp", 
            foreign_key: "clasifdesp_id", validate: true, optional: true
          belongs_to :tipodesp, class_name: "Sivel2Sjr::Tipodesp", 
            foreign_key: "tipodesp_id", validate: true, optional: true
          belongs_to :declaroante, class_name: "Sivel2Sjr::Declaroante", 
            foreign_key: "declaroante_id", validate: true, optional: true
          belongs_to :inclusion, class_name: "Sivel2Sjr::Inclusion", 
            foreign_key: "inclusion_id", validate: true, optional: true
          belongs_to :acreditacion, 
            class_name: "Sivel2Sjr::Acreditacion", 
            foreign_key: "acreditacion_id", validate: true, optional: true
          belongs_to :modalidadtierra, 
            class_name: "Sivel2Sjr::Modalidadtierra", 
            foreign_key: "modalidadtierra_id", validate: true, optional: true
          belongs_to :pais, class_name: "Msip::Pais", 
            foreign_key: "paisdecl", validate: true, optional: true
          belongs_to :departamento, class_name: "Msip::Departamento", 
            foreign_key: "departamentodecl", validate: true, optional: true
          belongs_to :municipio, class_name: "Msip::Municipio", 
            foreign_key: "municipiodecl", validate: true, optional: true
          belongs_to :caso, class_name: "Sivel2Gen::Caso", 
            foreign_key: "caso_id", validate: true, optional: false

          validates_presence_of :fechaexpulsion, :fechallegada
          validates :fechaexpulsion, uniqueness: 
            { scope: :caso_id,
              message: " ya existe otro desplazamiento "\
              "con la misma fecha de expulsión"
          }

          validate :llegada_posterior_a_expulsion
          def llegada_posterior_a_expulsion
            if fechallegada.present? && 
              fechaexpulsion.present? && fechallegada<fechaexpulsion
              errors.add(:fechallegada, 
                         " debe ser posterior a la fecha de expulsión")
            end
          end

          if ActiveRecord::Base.connection.data_source_exists?(
              'sivel2_sjr_desplazamiento') && 
              Sivel2Sjr::Desplazamiento.has_attribute?(:expulsion_id)
            validate :sitios_diferentes
            def sitios_diferentes
              if llegada.present? && expulsion.present? && 
                  llegada_id == expulsion_id
                errors.add(:llegada, 
                           " debe ser diferente al sitio de expulsion")
              end
            end
          end

          validate :fechaexpulsion_unica
          def fechaexpulsion_unica
            if fechaexpulsion.present? && 
              Sivel2Sjr::Desplazamiento.where(caso_id: caso_id,
                                   fechaexpulsion: fechaexpulsion).count>1
              errors.add(:fechaexpulsion, " debe ser única")
            end
          end

        end

      end
    end
  end
end
