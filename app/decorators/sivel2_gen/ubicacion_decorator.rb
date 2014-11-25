# encoding: UTF-8
Sivel2Gen::Ubicacion.class_eval do
  has_many :expulsion, class_name: "Sivel2Sjr::Desplazamiento", 
    foreign_key: "id_expulsion", validate: true, dependent: :destroy
  has_many :llegada, class_name: "Sivel2Sjr::Desplazamiento", 
    foreign_key: "id_llegada", validate: true, dependent: :destroy
  has_one :salidarefugio, class_name: "Sivel2Sjr::Casosjr", 
    foreign_key: "id_salida", validate: true
  has_one :llegadarefugio, class_name: "Sivel2Sjr::Casosjr", 
    foreign_key: "id_llegada", validate: true
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
