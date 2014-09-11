# encoding: UTF-8
require 'rails_helper'

RSpec.describe Progestado, :type => :model do

  it "valido" do
		progestado = FactoryGirl.build(:progestado)
		expect(progestado).to be_valid
		progestado.destroy
	end

  it "no valido" do
		progestado = FactoryGirl.build(:progestado, nombre: '')
		expect(progestado).not_to be_valid
		progestado.destroy
	end

	it "existente" do
		progestado = Progestado.where(id: 0).take
		expect(progestado.nombre).to eq("SIN INFORMACIÓN")
	end

end

