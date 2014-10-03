# encoding: UTF-8
class Declaroante < ActiveRecord::Base
  extend Basica

	has_many :desplazamiento, foreign_key: "id_declaroante", validate: true
end
