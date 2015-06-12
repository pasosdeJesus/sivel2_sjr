# encoding: UTF-8
require 'rails_helper'

module Sivel2Sjr
  RSpec.describe Clasifdesp, :type => :model do

    it "valido" do
      clasifdesp = FactoryGirl.build(:sivel2_sjr_clasifdesp)
      expect(clasifdesp).to be_valid
      clasifdesp.destroy
    end

    it "no valido" do
      clasifdesp = FactoryGirl.build(:sivel2_sjr_clasifdesp, nombre: '')
      expect(clasifdesp).not_to be_valid
      clasifdesp.destroy
    end

    it "existente" do
      clasifdesp = Sivel2Sjr::Clasifdesp.where(id: 0).take
      expect(clasifdesp.nombre).to eq("SIN INFORMACIÓN")
    end

  end
end
