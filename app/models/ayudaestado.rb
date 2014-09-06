# encoding: UTF-8
class Ayudaestado < ActiveRecord::Base
	has_many :ayudaestado_respuesta, foreign_key: "id_ayudaestado", 
    validate: true, dependent: :destroy
  has_many :respuesta, :through => :ayudaestado_respuesta
end
