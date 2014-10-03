# encoding: UTF-8
class Progestado < ActiveRecord::Base
  extend Basica

	has_many :progestado_respuesta, class_name: 'DerechoRespuesta',
    foreign_key: "id_progestado", validate: true, dependent: :destroy
  has_many :respuesta, :through => :progestado_respuesta

  validates :nombre, presence: true, allow_blank: false
  validates :fechacreacion, presence: true, allow_blank: false
end
