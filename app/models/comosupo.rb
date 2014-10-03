# encoding: UTF-8
class Comosupo < ActiveRecord::Base
  extend Basica

	has_many :casosjr

  validates :nombre, presence: true, allow_blank: false
  validates :fechacreacion, presence: true, allow_blank: false
end
