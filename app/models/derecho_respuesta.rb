# encoding: UTF-8
class DerechoRespuesta < ActiveRecord::Base
  belongs_to :derecho, foreign_key: "id_derecho", validate: true
  belongs_to :respuesta, foreign_key: "id_respuesta", validate: true
end
