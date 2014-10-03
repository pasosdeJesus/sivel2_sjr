# encoding: UTF-8
class Aspsicosocial < ActiveRecord::Base
  extend Basica

	has_many :aspsicosocial_respuesta, class_name: 'DerechoRespuesta',
    foreign_key: "id_aspsicosocial", validate: true, dependent: :destroy
  has_many :respuesta, :through => :aspsicosocial_respuesta

  validates :nombre, presence: true, allow_blank: false
  validates :fechacreacion, presence: true, allow_blank: false
end
