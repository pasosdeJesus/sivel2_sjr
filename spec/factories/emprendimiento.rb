# encoding: UTF-8

FactoryGirl.define do
  factory :emprendimiento do
		id 1000 # Buscamos que no intefiera con existentes
    nombre "Emprendimiento"
    fechacreacion "2014-09-11"
    created_at "2014-09-11"
  end
end
