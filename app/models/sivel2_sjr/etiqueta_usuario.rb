# encoding: UTF-8
module Sivel2Sjr
  class EtiquetaUsuario < ActiveRecord::Base

    belongs_to :etiqueta, class_name: "Sivel2Gen::Etiqueta",
      foreign_key: "etiqueta_id", validate: true
    belongs_to :usuario, class_name: "Usuario", 
      foreign_key: "usuario_id", validate: true
  end
end
