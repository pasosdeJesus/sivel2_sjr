# encoding: UTF-8
class Motivosjr < ActiveRecord::Base
  include Basica

  belongs_to :derecho
  has_many :motivosjr_respuesta, class_name: 'MotivosjrRespuesta',  
    foreign_key: "id_motivosjr", validate: true, dependent: :destroy
  has_many :respuesta, through: :motivosjr_respuesta

  validates :nombre, presence: true, allow_blank: false
  validates :fechacreacion, presence: true, allow_blank: false
end
