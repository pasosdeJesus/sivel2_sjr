# encoding: UTF-8
require 'rails_helper'

RSpec.describe Estadocivil, :type => :model do

  it "valido" do
		estadocivil = FactoryGirl.build(:estadocivil)
		expect(estadocivil).to be_valid
		estadocivil.destroy
	end

  it "no valido" do
		estadocivil = FactoryGirl.build(:estadocivil, nombre: '')
		expect(estadocivil).not_to be_valid
		estadocivil.destroy
	end

	it "existente" do
		estadocivil = Estadocivil.where(id: 0).take
		expect(estadocivil.nombre).to eq("SIN INFORMACIÓN")
	end

end

