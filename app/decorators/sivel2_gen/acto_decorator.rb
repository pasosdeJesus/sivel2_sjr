# encoding: UTF-8
Sivel2Gen::Acto.class_eval do
  has_one :actosjr, class_name: 'Sivel2Sjr::Actosjr',
    foreign_key: "id_acto", dependent: :destroy, inverse_of: :acto
  accepts_nested_attributes_for :actosjr

  # Al validar caso se crea una instancia donde current_usuario de caso es nil
end
