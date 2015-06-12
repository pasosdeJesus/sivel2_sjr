# encoding: UTF-8
require 'rails_helper'

module Sivel2Sjr
  RSpec.describe Personadesea, :type => :model do

    it "valido" do
      personadesea = FactoryGirl.build(:sivel2_sjr_personadesea)
      expect(personadesea).to be_valid
      personadesea.destroy
    end

    it "no valido" do
      personadesea = FactoryGirl.build(:sivel2_sjr_personadesea, nombre: '')
      expect(personadesea).not_to be_valid
      personadesea.destroy
    end

    it "existente" do
      personadesea = Sivel2Sjr::Personadesea.where(id: 0).take
      expect(personadesea.nombre).to eq("SIN INFORMACIÓN")
    end

  end
end
