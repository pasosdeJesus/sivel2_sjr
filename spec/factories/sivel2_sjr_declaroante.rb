# encoding: UTF-8

FactoryGirl.define do
  factory :sivel2_sjr_declaroante, class: 'Sivel2Sjr::Declaroante' do
    id 1000 # Buscamos que no intefiera con existentes
    nombre "Declaroante"
    fechacreacion "2014-09-11"
    created_at "2014-09-11"
  end
end
