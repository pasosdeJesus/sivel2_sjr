# encoding: UTF-8
module Sivel2Gen
  class Regionsjr < ActiveRecord::Base
    include Sivel2Gen::Basica

    has_many :casosjr, foreign_key: "id_regionsjr", validate: true
    has_many :usuario

    validates_presence_of :nombre
    validates_presence_of :fechacreacion
  end
end
