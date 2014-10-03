# encoding: UTF-8
class Ayudaestado < ActiveRecord::Base
  extend Basica

	has_many :ayudaestado_respuesta, class_name: 'DerechoRespuesta',
    foreign_key: "id_ayudaestado", validate: true, dependent: :destroy
  has_many :respuesta, :through => :ayudaestado_respuesta

  validates :nombre, presence: true, allow_blank: false
  validates :fechacreacion, presence: true, allow_blank: false
end
