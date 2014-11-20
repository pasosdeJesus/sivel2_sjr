# encoding: UTF-8
module Sivel2Gen
  class Ubicacion < ActiveRecord::Base
    has_many :expulsion, class_name: "Desplazamiento", 
      foreign_key: "id_expulsion", validate: true, dependent: :destroy
    has_many :llegada, class_name: "Desplazamiento", 
      foreign_key: "id_llegada", validate: true, dependent: :destroy
    belongs_to :pais, foreign_key: "id_pais", validate: true
    belongs_to :departamento, foreign_key: "id_departamento", validate: true
    belongs_to :municipio, foreign_key: "id_municipio", validate: true
    belongs_to :clase, foreign_key: "id_clase", validate: true
    belongs_to :tsitio, foreign_key: "id_tsitio", validate: true
    belongs_to :caso, foreign_key: "id_caso", validate: true
    has_one :salidarefugio, class_name: "Casosjr", foreign_key: "id_salida", validate: true
    has_one :llegadarefugio, class_name: "Casosjr", foreign_key: "id_llegada", validate: true
    validates_presence_of :pais
    validates_presence_of :id_tsitio
    validates_presence_of :caso

    def muestra(sep: " / ", conclase: false)
      r = Pais.find(self.id_pais).nombre
      if self.id_departamento 
        r += sep + Departamento.where(id: self.id_departamento, 
                                      id_pais: self.id_pais).take.nombre
        if self.id_municipio
          r += sep + Municipio.where(id: self.id_municipio,
                                     id_departamento: self.id_departamento,
                                     id_pais: self.id_pais).take.nombre
          if self.id_clase && conclase
            r += sep + Clase.where(id: self.id_clase,
                                   id_municipio: self.id_municipio,
                                   id_departamento: self.id_departamento,
                                   id_pais: self.id_pais).take.nombre 
          end
        end
      end
      return r
    end

  end
end
