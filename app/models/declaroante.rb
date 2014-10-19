# encoding: UTF-8
class Declaroante < ActiveRecord::Base
  include Basica

	has_many :desplazamiento, foreign_key: "id_declaroante", validate: true
end
