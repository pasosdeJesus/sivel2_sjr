# encoding: UTF-8

require 'sivel2_gen/concerns/models/ubicacion'

module Sivel2Sjr
  module Concerns
    module Models
      module Ubicacion
        extend ActiveSupport::Concern
        include Sivel2Gen::Concerns::Models::Ubicacion

        included do
          has_one :salidarefugio, validate: true, foreign_key: "id_salida",
            class_name: "Sivel2Gen::Casosjr"
          has_one :llegadarefugio, foreign_key: "id_llegada", validate: true, 
            class_name: "Sivel2Gen::Casosjr"

          belongs_to :pais, foreign_key: "id_pais", validate: true, 
            class_name: "Sivel2Gen::Pais"
          belongs_to :departamento, foreign_key: "id_departamento", validate: true, 
            class_name: "Sivel2Gen::Departamento" 
          belongs_to :municipio, foreign_key: "id_municipio", validate: true, 
            class_name: "Sivel2Gen::Municipio"
          belongs_to :clase, foreign_key: "id_clase", validate: true, 
            class_name: "Sivel2Gen::Clase" 
          belongs_to :tsitio, foreign_key: "id_tsitio", validate: true, 
            class_name: "Sivel2Gen::Tsitio" 
          belongs_to :caso, foreign_key: "id_caso", validate: true, 
            class_name: "Sivel2Gen::Caso" 

          validates_presence_of :pais
        end

        module ClassMethods
        end

      end
    end
  end
end
