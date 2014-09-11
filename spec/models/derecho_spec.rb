# encoding: UTF-8
require 'rails_helper'

RSpec.describe Derecho, :type => :model do

  it "valido" do
		derecho = FactoryGirl.build(:derecho)
		expect(derecho).to be_valid
		derecho.destroy
	end

  it "no valido" do
		derecho = FactoryGirl.build(:derecho, nombre: '')
		expect(derecho).not_to be_valid
		derecho.destroy
	end

	it "existente" do
		derecho = Derecho.where(id: 1).take
		expect(derecho.nombre).to eq("DERECHO A LA INTEGRIDAD PERSONAL")
	end

end

