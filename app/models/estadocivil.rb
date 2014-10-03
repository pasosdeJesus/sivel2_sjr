# encoding: UTF-8
class Estadocivil < ActiveRecord::Base
  extend Basica

	has_many :victimasjr, foreign_key: "id_estadocivil", validate: true

  validates :nombre, presence: true, allow_blank: false
  validates :fechacreacion, presence: true, allow_blank: false
end
