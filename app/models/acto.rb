# encoding: UTF-8
class Acto < ActiveRecord::Base
  has_one :actosjr, foreign_key: "id_acto", inverse_of: acto, 
    validate: true, dependent: :destroy

  belongs_to :presponsable, foreign_key: "id_presponsable", validate: true
  accepts_nested_attributes_for :presponsable
  belongs_to :persona, foreign_key: "id_persona", validate: true
  belongs_to :caso, foreign_key: "id_caso", validate: true
  belongs_to :categoria, foreign_key: "id_categoria", validate: true
end
