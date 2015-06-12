# encoding: UTF-8

FactoryGirl.define do
  factory :sivel2_sjr_personadesea, class: 'Sivel2Sjr::Personadesea' do
		id 1000 # Buscamos que no intefiera con existentes
    nombre "Personadesea"
    fechacreacion "2014-09-11"
    created_at "2014-09-11"
  end
end
