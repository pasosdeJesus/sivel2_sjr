# encoding: UTF-8
Sivel2Gen::Persona.class_eval do
  has_many :casosjr, class_name: 'Sivel2Sjr::Casosjr',
    foreign_key: "contacto"

  belongs_to :nacional, class_name: "Sivel2Gen::Pais", 
    foreign_key: "nacionalde", validate: true
end
