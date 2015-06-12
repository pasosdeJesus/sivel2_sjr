# encoding: UTF-8
require 'rails_helper'

module Sivel2Sjr
  RSpec.describe Inclusion, :type => :model do

    it "valido" do
      inclusion = FactoryGirl.build(:sivel2_sjr_inclusion)
      expect(inclusion).to be_valid
      inclusion.destroy
    end

    it "no valido" do
      inclusion = FactoryGirl.build(:sivel2_sjr_inclusion, nombre: '')
      expect(inclusion).not_to be_valid
      inclusion.destroy
    end

    it "existente" do
      inclusion = Sivel2Sjr::Inclusion.where(id: 0).take
      expect(inclusion.nombre).to eq("SIN INFORMACIÓN")
    end

  end
end
