# encoding: UTF-8
class AyudaestadoRespuesta < ActiveRecord::Base
  belongs_to :ayudaestado, foreign_key: "id_ayudaestado", validate: true
  belongs_to :respuesta, foreign_key: "id_respuesta", validate: true
end
