# encoding: UTF-8
class Acreditacion < ActiveRecord::Base
  include Basica

  has_many :desplazamiento, foreign_key: "id_acreditacion", validate: true
end
