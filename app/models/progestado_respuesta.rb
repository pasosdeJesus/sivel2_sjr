# encoding: UTF-8
class ProgestadoRespuesta < ActiveRecord::Base
  belongs_to :progestado, foreign_key: "id_progestado", validate: true
  belongs_to :respuesta, foreign_key: "id_respuesta", validate: true
end
