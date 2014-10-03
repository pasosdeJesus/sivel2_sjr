# encoding: UTF-8
class Proteccion < ActiveRecord::Base
  extend Basica

	has_many :casosjr, foreign_key: "id_proteccion", validate: true

  validates :nombre, presence: true, allow_blank: false
  validates :fechacreacion, presence: true, allow_blank: false
end
