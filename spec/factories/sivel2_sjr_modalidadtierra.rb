# encoding: UTF-8

FactoryGirl.define do
  factory :sivel2_sjr_modalidadtierra, class: 'Sivel2Sjr::Modalidadtierra' do
		id 1000 # Buscamos que no intefiera con existentes
    nombre "Modalidadtierra"
    fechacreacion "2014-09-11"
    created_at "2014-09-11"
  end
end
