# encoding: UTF-8
module Sivel2Gen
  class Acto < ActiveRecord::Base
    has_one :actosjr, foreign_key: "id_acto", dependent: :destroy, 
      inverse_of: :acto
    accepts_nested_attributes_for :actosjr

    belongs_to :presponsable, foreign_key: "id_presponsable"
    accepts_nested_attributes_for :presponsable
    belongs_to :persona, foreign_key: "id_persona"
    belongs_to :caso, foreign_key: "id_caso"
    belongs_to :categoria, foreign_key: "id_categoria"

    validates_presence_of :presponsable
    validates_presence_of :persona
    # Al validar caso se crea una instancia donde current_usuario de caso es nil
    validates_presence_of :caso
    validates_presence_of :categoria
  end
end
