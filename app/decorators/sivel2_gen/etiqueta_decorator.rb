# encoding: UTF-8
Sivel2Gen::Etiqueta.class_eval do
  has_many :etiqueta_usuario, class_name: 'Sivel2Gen::EtiquetaUsuario',
    dependent: :delete_all
  has_many :usuario, class_name: 'Usuario', through: :etiqueta_usuario
end
