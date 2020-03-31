class AgregaTipoIndicadorGensjr1 < ActiveRecord::Migration[6.0]
  def up
    Cor1440Gen::Tipoindicador.create!(
      id: 30,
      nombre: 'CUENTA CONT. Y FAM.',
      espfuncionmedir: 'Las personas de un caso que esté en el listado de casos de dos actividades cuentan duplicadas',
      medircon: 1,
      descd1: 'Contactos',
      descd2: 'Familiares',
      descd3: '',
      descd4: '',
      fechacreacion: '2020-03-30',
      created_at: '2020-03-30',
      updated_at: '2020-03-30'
    )
    Cor1440Gen::Tipoindicador.create!(
      id: 31,
      nombre: 'CUENTA CONT. Y FAM. ÚNICOS',
      espfuncionmedir: 'Las personas de un caso que esté en el listado de casos de dos actividades cuentan una vez',
      medircon: 1,
      descd1: 'Contactos',
      descd2: 'Familiares',
      descd3: '',
      descd4: '',
      fechacreacion: '2020-03-30',
      created_at: '2020-03-30',
      updated_at: '2020-03-30'
    )

  end

  def down
    execute <<-SQL
      DELETE FROM cor1440_gen_tipoindicador WHERE id IN (30,31);
    SQL
  end
end

