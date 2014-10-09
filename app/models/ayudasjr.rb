# encoding: UTF-8
class Ayudasjr < ActiveRecord::Base
  extend Basica

  belongs_to :derecho
	has_many :ayudasjr_respuesta, class_name: 'AyudasjrRespuesta',  
    foreign_key: "id_ayudasjr", 
    validate: true, dependent: :destroy
  has_many :respuesta, :through => :ayudasjr_respuesta

  validates :nombre, presence: true, allow_blank: false
  validates :fechacreacion, presence: true, allow_blank: false
end
