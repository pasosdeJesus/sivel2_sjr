# encoding: UTF-8
class MotivosjrRespuesta < ActiveRecord::Base
  belongs_to :motivosjr, foreign_key: "id_motivosjr", validate: true
  belongs_to :respuesta, foreign_key: "id_respuesta", validate: true
end
