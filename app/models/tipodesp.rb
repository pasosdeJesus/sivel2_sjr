# encoding: UTF-8
class Tipodesp < ActiveRecord::Base
  include Basica

	has_many :desplazamiento, foreign_key: "id_tipodesp", validate: true

  validates_presence_of :nombre
  validates_presence_of :fechacreacion
end
