# encoding: UTF-8
class Statusmigratorio < ActiveRecord::Base
  include Basica

	has_many :casosjr, foreign_key: "id_statusmigratorio", validate: true

  validates :nombre, presence: true, allow_blank: false
  validates :fechacreacion, presence: true, allow_blank: false
end
