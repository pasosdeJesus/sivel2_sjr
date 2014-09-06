# encoding: UTF-8
class Derecho < ActiveRecord::Base
	has_many :derecho_respuesta, foreign_key: "id_derecho", 
    validate: true, dependent: :destroy
  has_many :respuesta, :through => :derecho_respuesta
	has_many :derecho_procesosjr, foreign_key: "id_derecho", validate: true
end
