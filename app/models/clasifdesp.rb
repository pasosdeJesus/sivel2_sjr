# encoding: UTF-8
class Clasifdesp < ActiveRecord::Base
  include Basica

	has_many :desplazamiento, foreign_key: "id_clasifdesp", validate: true
end
