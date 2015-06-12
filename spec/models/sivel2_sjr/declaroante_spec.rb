# encoding: UTF-8
require 'rails_helper'

module Sivel2Sjr
  RSpec.describe Declaroante, :type => :model do

    it "valido" do
      declaroante = FactoryGirl.build(:sivel2_sjr_declaroante)
      expect(declaroante).to be_valid
      declaroante.destroy
    end

    it "no valido" do
      declaroante = FactoryGirl.build(:sivel2_sjr_declaroante, nombre: '')
      expect(declaroante).not_to be_valid
      declaroante.destroy
    end

    it "existente" do
      declaroante = Sivel2Sjr::Declaroante.where(id: 0).take
      expect(declaroante.nombre).to eq("SIN INFORMACIÓN")
    end

  end
end
