# encoding: UTF-8
require 'rails_helper'

RSpec.describe Proteccion, :type => :model do

  it "valido" do
		proteccion = FactoryGirl.build(:proteccion)
		expect(proteccion).to be_valid
		proteccion.destroy
	end

  it "no valido" do
		proteccion = FactoryGirl.build(:proteccion, nombre: '')
		expect(proteccion).not_to be_valid
		proteccion.destroy
	end

	it "existente" do
		proteccion = Proteccion.where(id: 0).take
		expect(proteccion.nombre).to eq("SIN INFORMACIÓN")
	end

end

