# encoding: UTF-8
module Sivel2Sjr
  class Desplazamiento < ActiveRecord::Base
  
  	has_many :actosjr, class_name: "Sivel2Sjr::Actosjr", validate: true
  
  	belongs_to :expulsion, class_name: "Sivel2Gen::Ubicacion", 
      foreign_key: "id_expulsion", validate: true
  	belongs_to :llegada, class_name: "Sivel2Gen::Ubicacion", 
      foreign_key: "id_llegada", validate: true
  	belongs_to :clasifdesp, class_name: "Sivel2Sjr::Clasifdesp", 
      foreign_key: "id_clasifdesp", validate: true
  	belongs_to :tipodesp, class_name: "Sivel2Sjr::Tipodesp", 
      foreign_key: "id_tipodesp", validate: true
  	belongs_to :declaroante, class_name: "Sivel2Sjr::Declaroante", 
      foreign_key: "id_declaroante", validate: true
  	belongs_to :inclusion, class_name: "Sivel2Sjr::Inclusion", 
      foreign_key: "id_inclusion", validate: true
  	belongs_to :acreditacion, class_name: "Sivel2Sjr::Acreditacion", 
      foreign_key: "id_acreditacion", validate: true
  	belongs_to :modalidadtierra, class_name: "Sivel2Sjr::Modalidadtierra", 
      foreign_key: "id_modalidadtierra", validate: true
  	belongs_to :pais, class_name: "Sivel2Gen::Pais", 
      foreign_key: "paisdecl", validate: true
  	belongs_to :departamento, class_name: "Sivel2Gen::Departamento", 
      foreign_key: "departamentodecl", validate: true
  	belongs_to :municipio, class_name: "Sivel2Gen::Municipio", 
      foreign_key: "municipiodecl", validate: true
  	belongs_to :caso, class_name: "Sivel2Gen::Caso", 
      foreign_key: "id_caso", validate: true
  
    validates_presence_of :fechaexpulsion, :expulsion, :fechallegada, :llegada
    validates :fechaexpulsion, uniqueness: { scope: :id_caso,
      message: " ya existe otro desplazamiento con la misma fecha de expulsión"
    }
  
    validate :llegada_posterior_a_expulsion
    def llegada_posterior_a_expulsion
      if fechallegada.present? && fechaexpulsion.present? && fechallegada<fechaexpulsion
        errors.add(:fechallegada, " debe ser posterior a la fecha de expulsión")
      end
    end
  
    validate :sitios_diferentes
    def sitios_diferentes
      if llegada.present? && expulsion.present? && id_llegada == id_expulsion
        errors.add(:llegada, " debe ser diferente al sitio de expulsion")
      end
    end
  
    validate :fechaexpulsion_unica
    def fechaexpulsion_unica
      if fechaexpulsion.present? && Desplazamiento.where(id_caso: id_caso,
        fechaexpulsion: fechaexpulsion).count>1
        errors.add(:fechaexpulsion, " debe ser única")
      end
    end
  
  
  
  end
end
