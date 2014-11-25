# encoding: UTF-8
Sivel2Gen::Estadocivil.class_eval do
  has_many :victimasjr, class_name: 'Sivel2Sjr::Victimasjr',
    foreign_key: "id_estadocivil", validate: true
end
