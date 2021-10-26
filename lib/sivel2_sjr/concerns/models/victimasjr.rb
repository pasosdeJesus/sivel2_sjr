module Sivel2Sjr
  module Concerns
    module Models
      module Victimasjr
        extend ActiveSupport::Concern

        included do
          # Orden de esquema en base
          belongs_to :actividadoficio, 
            class_name: "Sivel2Sjr::Actividadoficio", 
            foreign_key: "id_actividadoficio", validate: true, optional: true
          belongs_to :departamento, class_name: "Sip::Departamento", 
            foreign_key: "id_departamento", validate: true, optional: true
          belongs_to :escolaridad, class_name: "Sivel2Gen::Escolaridad", 
            foreign_key: "id_escolaridad", validate: true, optional: true
          belongs_to :estadocivil, class_name: "Sivel2Gen::Estadocivil", 
            foreign_key: "id_estadocivil", validate: true, optional: true
          belongs_to :maternidad, class_name: "Sivel2Gen::Maternidad", 
            foreign_key: "id_maternidad", validate: true, optional: true
          belongs_to :municipio, class_name: "Sip::Municipio", 
            foreign_key: "id_municipio", validate: true, optional: true
          belongs_to :pais, class_name: "Sip::Pais", 
            foreign_key: "id_pais", validate: true, optional: true
          #belongs_to :regimensalud, class_name: "Sivel2Sjr::Regimensalud", 
          #  foreign_key: "id_regimensalud", validate: true
          belongs_to :rolfamilia, class_name: "Sivel2Sjr::Rolfamilia", 
            foreign_key: "id_rolfamilia", validate: true, optional: true
          # no validamos :victima porque el controlador crea nuevos 
          # (con persona en nombre vacio y victima no es valido)
          belongs_to :victima, class_name: "Sivel2Gen::Victima", 
            foreign_key: "id_victima", inverse_of: :victimasjr
        end

        module ClassMethods
        end
      end
    end
  end
end
