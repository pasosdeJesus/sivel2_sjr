class DatosintermediosSivel2sjr < ActiveRecord::Migration[6.0]

  def up
    Cor1440Gen::Datointermedioti.create(
      id: 90, tipoindicador_id: 30,
      nombre: 'Contactos'
    )
    Cor1440Gen::Datointermedioti.create(
      id: 91, tipoindicador_id: 30,
      nombre: 'Familiares'
    )
    Cor1440Gen::Datointermedioti.create(
      id: 95, tipoindicador_id: 31,
      nombre: 'Contactos'
    )
    Cor1440Gen::Datointermedioti.create(
      id: 96, tipoindicador_id: 31,
      nombre: 'Familiares'
    )
  end

  def down
    Cor1440Gen::Datointermedioti.where(id: [90, 91, 95, 96]).destroy_all
  end
end
