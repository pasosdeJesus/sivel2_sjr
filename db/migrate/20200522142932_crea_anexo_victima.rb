class CreaAnexoVictima < ActiveRecord::Migration[6.0]
  def change
    create_table :sivel2_gen_anexo_victima do |t|
      t.integer :id_anexo
      t.integer :id_victima
      t.date :fecha
    end
    add_foreign_key :sivel2_gen_anexo_victima, 
      :sip_anexo, column: :id_anexo
    add_foreign_key :sivel2_gen_anexo_victima, 
      :sivel2_gen_victima, column: :id_victima
  end
end
