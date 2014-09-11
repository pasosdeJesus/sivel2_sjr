# encoding: UTF-8
class Aslegal < ActiveRecord::Base
	has_many :aslegal_respuesta, class_name: 'AslegalRespuesta', 
    foreign_key: "id_aslegal", validate: true, dependent: :destroy
  has_many :respuesta, :through => :aslegal_respuesta

  validates :nombre, presence: true, allow_blank: false
  validates :fechacreacion, presence: true, allow_blank: false
end
