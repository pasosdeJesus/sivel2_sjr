# encoding: UTF-8
require 'rails_helper'

RSpec.describe Emprendimiento, :type => :model do

  it "valido" do
		emprendimiento = FactoryGirl.build(:emprendimiento)
		expect(emprendimiento).to be_valid
		emprendimiento.destroy
	end

  it "no valido" do
		emprendimiento = FactoryGirl.build(:emprendimiento, nombre: '')
		expect(emprendimiento).not_to be_valid
		emprendimiento.destroy
	end

	it "existente" do
		emprendimiento = Emprendimiento.where(id: 0).take
		expect(emprendimiento.nombre).to eq("SIN INFORMACIÓN")
	end

end

