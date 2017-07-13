class CreateJoinTableOficinaProyectofinanciero < ActiveRecord::Migration[5.1]
  def up
    create_join_table :oficina, :proyectofinanciero, {
      table_name: 'sivel2_sjr_oficina_proyectofinanciero'
    }
    add_foreign_key :sivel2_sjr_oficina_proyectofinanciero, :sip_oficina, 
      column: :oficina_id
    add_foreign_key :sivel2_sjr_oficina_proyectofinanciero, 
      :cor1440_gen_proyectofinanciero, column: :proyectofinanciero_id
    execute <<-SQL
    INSERT INTO sivel2_sjr_oficina_proyectofinanciero 
      (oficina_id, proyectofinanciero_id) 
      (SELECT usuario.oficina_id, cor1440_gen_proyectofinanciero.id FROM
        cor1440_gen_proyectofinanciero JOIN usuario ON
        responsable_id=usuario.id WHERE usuario.oficina_id IS NOT NULL)
    SQL
  end

  def down
    drop_table :sivel2_sjr_oficina_proyectofinanciero
  end
end
