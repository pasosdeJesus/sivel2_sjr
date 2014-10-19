# encoding: UTF-8
class Derecho < ActiveRecord::Base
  include Basica

	has_many :derecho_respuesta, class_name: 'DerechoRespuesta',  
    foreign_key: "id_derecho", validate: true, dependent: :destroy
  has_many :respuesta, :through => :derecho_respuesta
	has_many :derecho_procesosjr, foreign_key: "id_derecho", validate: true

  validates :nombre, presence: true, allow_blank: false
  validates :fechacreacion, presence: true, allow_blank: false
end
