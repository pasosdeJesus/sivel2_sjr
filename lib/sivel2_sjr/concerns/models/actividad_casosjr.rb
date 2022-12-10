module Sivel2Sjr
  module Concerns
    module Models
      module ActividadCasosjr
        extend ActiveSupport::Concern

        included do
          include Msip::Modelo

          belongs_to :actividad, class_name: 'Cor1440Gen::Actividad',
            foreign_key: 'actividad_id', validate: true, optional: false
          belongs_to :casosjr, class_name: 'Sivel2Sjr::Casosjr',
            foreign_key: 'casosjr_id', validate: true, optional: false
          accepts_nested_attributes_for :casosjr, reject_if: :all_blank 


          validates :actividad, presence: true
          validates :casosjr, presence: true

        end # included

      end 
    end 
  end 
end 
