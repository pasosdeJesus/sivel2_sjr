# encoding: UTF-8
class Actosjr < ActiveRecord::Base
  belongs_to :acto, foreign_key: "id_acto", inverse_of: :actosjr, validate: true
  belongs_to :desplazamiento, foreign_key: "fechaexpulsion"
end
