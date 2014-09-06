# encoding: UTF-8
class Respuesta < ActiveRecord::Base

  # Debería ser: belongs_to :casosjr, foreign_key: "id_caso", validate: true
  belongs_to :caso, foreign_key: "id_caso", validate: true

  has_many :aslegal, :through => :aslegal_respuesta
  has_many :aslegal_respuesta,  foreign_key: "id_respuesta", 
    dependent: :destroy, validate: true

  has_many :aspsicosocial, :through => :aspsicosocial_respuesta
  has_many :aspsicosocial_respuesta,  foreign_key: "id_respuesta", dependent: :destroy

  has_many :ayudaestado, :through => :ayudaestado_respuesta
  has_many :ayudaestado_respuesta,  foreign_key: "id_respuesta", 
    dependent: :destroy, validate: true

  has_many :ayudasjr, :through => :ayudasjr_respuesta
  has_many :ayudasjr_respuesta,  foreign_key: "id_respuesta", 
    dependent: :destroy, validate: true

  has_many :derecho, :through => :derecho_respuesta
  has_many :derecho_respuesta,  foreign_key: "id_respuesta", 
    dependent: :destroy, validate: true

  has_many :emprendimiento, :through => :emprendimiento_respuesta
  has_many :emprendimiento_respuesta,  foreign_key: "id_respuesta", 
    dependent: :destroy

  has_many :motivosjr, :through => :motivosjr_respuesta
  has_many :motivosjr_respuesta,  foreign_key: "id_respuesta", 
    dependent: :destroy

  has_many :progestado, :through => :progestado_respuesta
  has_many :progestado_respuesta,  foreign_key: "id_respuesta", 
    dependent: :destroy, validate: true

end
