# encoding: UTF-8
class Inclusion < ActiveRecord::Base
  extend Basica

	has_many :desplazamiento, foreign_key: "id_inclusion", validate: true
end
