# encoding: UTF-8
require 'rails_helper'

RSpec.describe Statusmigratorio, :type => :model do

  it "valido" do
		statusmigratorio = FactoryGirl.build(:statusmigratorio)
		expect(statusmigratorio).to be_valid
		statusmigratorio.destroy
	end

  it "no valido" do
		statusmigratorio = FactoryGirl.build(:statusmigratorio, nombre: '')
		expect(statusmigratorio).not_to be_valid
		statusmigratorio.destroy
	end

	it "existente" do
		statusmigratorio = Statusmigratorio.where(id: 0).take
		expect(statusmigratorio.nombre).to eq("SIN INFORMACIÓN")
	end

end

