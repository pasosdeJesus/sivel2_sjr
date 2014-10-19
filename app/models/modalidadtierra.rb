# encoding: UTF-8
class Modalidadtierra < ActiveRecord::Base
  include Basica

	has_many :desplazamiento, foreign_key: "id_modalidadtierra", validate: true
end
