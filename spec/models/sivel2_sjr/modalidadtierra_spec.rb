# encoding: UTF-8
require 'rails_helper'

module Sivel2Sjr
  RSpec.describe Modalidadtierra, :type => :model do

    it "valido" do
      modalidadtierra = FactoryGirl.build(:sivel2_sjr_modalidadtierra)
      expect(modalidadtierra).to be_valid
      modalidadtierra.destroy
    end

    it "no valido" do
      modalidadtierra = FactoryGirl.build(:sivel2_sjr_modalidadtierra, nombre: '')
      expect(modalidadtierra).not_to be_valid
      modalidadtierra.destroy
    end

    it "existente" do
      modalidadtierra = Sivel2Sjr::Modalidadtierra.where(id: 0).take
      expect(modalidadtierra.nombre).to eq("SIN INFORMACIÓN")
    end

  end
end
