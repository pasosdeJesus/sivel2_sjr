# encoding: UTF-8
Sivel2Gen::Regionsjr.class_eval do
  has_many :casosjr, class_name: 'Sivel2Sjr::Casosjr',
    foreign_key: "id_regionsjr", validate: true
end
