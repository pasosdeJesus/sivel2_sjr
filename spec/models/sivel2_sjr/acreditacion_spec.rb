# encoding: UTF-8
require 'rails_helper'

module Sivel2Sjr
  RSpec.describe Acreditacion, :type => :model do

    it "valido" do
      acreditacion = FactoryGirl.build(:sivel2_sjr_acreditacion)
      expect(acreditacion).to be_valid
      acreditacion.destroy
    end

    it "no valido" do
      acreditacion = FactoryGirl.build(:sivel2_sjr_acreditacion, nombre: '')
      expect(acreditacion).not_to be_valid
      acreditacion.destroy
    end

    it "existente" do
      acreditacion = Sivel2Sjr::Acreditacion.where(id: 0).take
      expect(acreditacion.nombre).to eq("SIN INFORMACIÓN")
    end

  end
end
