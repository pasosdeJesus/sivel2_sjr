# encoding: UTF-8
require 'rails_helper'

module Sivel2Gen
  RSpec.describe Ubicacion, :type => :model do
    context "valido" do
      let(:caso) { FactoryGirl.build(:caso) }
      let(:pais) { pais = Pais.find(862) }
      let(:ubicacion) { FactoryGirl.build(:ubicacion, pais: pais, caso: caso) }
      after(:each) do
        ubicacion.destroy
        caso.destroy
      end

      it "simple" do
        expect(ubicacion).to be_valid
      end

      it "nombre con sólo país" do
        expect(ubicacion.muestra).to eq("VENEZUELA")
      end

      context "con departamento" do
        let(:d) { Departamento.where(id_pais: 862, id: 1).take }
        before(:each) do
          ubicacion.departamento = d
        end
        it "nombre" do
          expect(ubicacion.muestra).to eq("VENEZUELA / DISTRITO CAPITAL")
        end

        context "con municipio" do
          let (:m) { Municipio.where(id_pais: 862, 
                                     id_departamento: 1, id: 1).take
          }
          before(:each) do
            ubicacion.municipio = m
          end
          it "nombre" do
            expect(ubicacion.muestra).to eq(
              "VENEZUELA / DISTRITO CAPITAL / BOLIVARIANO LIBERTADOR"
            )
          end

          context "con clase" do
            let (:c) { Clase.where(id_pais: 862, 
                                   id_departamento: 1, id_municipio: 1).take
            }
            before(:each) do
              ubicacion.clase = c
            end
            it "no incluye clase" do
              expect(ubicacion.muestra).to eq(
                "VENEZUELA / DISTRITO CAPITAL / BOLIVARIANO LIBERTADOR"
              )
            end
            it "incluye clase" do
              expect(ubicacion.muestra(conclase: true)).to eq(
                "VENEZUELA / DISTRITO CAPITAL / BOLIVARIANO LIBERTADOR / CARACAS"
              )
            end
          end
        end
      end
    end

    it "no valido 1" do
      ubicacion = FactoryGirl.build(:ubicacion)
      expect(ubicacion).not_to be_valid
      ubicacion.destroy
    end

    it "no valido 2" do
      caso = FactoryGirl.build(:caso)
      ubicacion = FactoryGirl.build(:ubicacion, id_caso: caso.id, id_tsitio: nil) 
      expect(ubicacion).not_to be_valid
      ubicacion.destroy
      caso.destroy
    end


  end
end
