class CreateActividadtipos < ActiveRecord::Migration[4.2]
  def change
    create_table :actividadtipos do |t|
      t.string :nombre, limit: 500, null: false
      t.string :observaciones, limit: 5000
      t.date :fechacreacion, null: false
      t.date :fechadeshabilitacion

      t.timestamps null: false
    end
  end
end
