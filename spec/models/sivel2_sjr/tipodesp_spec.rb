# encoding: UTF-8
require 'rails_helper'

module Sivel2Sjr
  RSpec.describe Tipodesp, :type => :model do

    it "valido" do
      tipodesp = FactoryGirl.build(:sivel2_sjr_tipodesp)
      expect(tipodesp).to be_valid
      tipodesp.destroy
    end

    it "no valido" do
      tipodesp = FactoryGirl.build(:sivel2_sjr_tipodesp, nombre: '')
      expect(tipodesp).not_to be_valid
      tipodesp.destroy
    end

    it "existente" do
      tipodesp = Sivel2Sjr::Tipodesp.where(id: 0).take
      expect(tipodesp.nombre).to eq("SIN INFORMACIÓN")
    end

  end
end
