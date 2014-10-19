# encoding: UTF-8
class Maternidad < ActiveRecord::Base
  include Basica

	has_many :victimasjr, foreign_key: "id_maternidad", validate: true
  
  validates :nombre, presence: true, allow_blank: false
  validates :fechacreacion, presence: true, allow_blank: false
end
