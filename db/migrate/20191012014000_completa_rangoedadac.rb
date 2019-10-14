class CompletaRangoedadac < ActiveRecord::Migration[6.0]
  def up
    if Cor1440Gen::Rangoedadac.where(id: 7).count == 0
      r = Cor1440Gen::Rangoedadac.create({
        id: 7,
        nombre: 'SIN INFORMACIÓN',
        limiteinferior: -1,
        limitesuperior: -1,
        fechacreacion: '2019-10-13',
        created_at: '2019-10-13',
        updated_at: '2019-10-13'
      })
      r.save!
    end
  end
  def down
  end
end
