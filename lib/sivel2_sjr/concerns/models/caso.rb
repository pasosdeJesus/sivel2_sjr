require 'sivel2_gen/concerns/models/caso'

module Sivel2Sjr
  module Concerns
    module Models
      module Caso 
        extend ActiveSupport::Concern
        include Sivel2Gen::Concerns::Models::Caso

        included do
#          has_many :actosjr, class_name: 'Sivel2Sjr::Actosjr',
#            :through => :acto, dependent: :destroy
#          accepts_nested_attributes_for :actosjr, allow_destroy: true, 
#            reject_if: :all_blank
#
#          has_one :casosjr, class_name: 'Sivel2Sjr::Casosjr',
#            foreign_key: "id_caso", inverse_of: :caso, validate: true, 
#            dependent: :destroy
#          accepts_nested_attributes_for :casosjr, allow_destroy: true, 
#            update_only: true
#
#          # respuesta deberìa ser con :through => :casosjr pero más dificil guardar
#          has_many :respuesta, class_name: 'Sivel2Sjr::Respuesta',
#            foreign_key: "id_caso", validate:true, dependent: :destroy
#          accepts_nested_attributes_for :respuesta, allow_destroy: true, 
#            reject_if: :all_blank
#
#          has_many :desplazamiento, class_name: 'Sivel2Sjr::Desplazamiento',
#            foreign_key: "id_caso", validate: true, dependent: :destroy
#          accepts_nested_attributes_for :desplazamiento , allow_destroy: true, 
#            reject_if: :all_blank
#          has_many :victimasjr, class_name: 'Sivel2Sjr::Victimasjr',
#            :through => :victima, dependent: :destroy
#          accepts_nested_attributes_for :victimasjr, allow_destroy: true, 
#            reject_if: :all_blank
#
        end



        module ClassMethods

        end

      end
    end
  end
end
