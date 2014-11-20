# encoding: UTF-8
require 'rails_helper'

module Sivel2Sjr
  RSpec.describe Aspsicosocial, :type => :model do

    it "valido" do
      aspsicosocial = FactoryGirl.build(:aspsicosocial)
      expect(aspsicosocial).to be_valid
      aspsicosocial.destroy
    end

    it "no valido" do
      aspsicosocial = FactoryGirl.build(:aspsicosocial, nombre: '')
      expect(aspsicosocial).not_to be_valid
      aspsicosocial.destroy
    end

    it "existente" do
      aspsicosocial = Aspsicosocial.where(id: 0).take
      expect(aspsicosocial.nombre).to eq("SIN INFORMACIÓN")
    end

  end
end
