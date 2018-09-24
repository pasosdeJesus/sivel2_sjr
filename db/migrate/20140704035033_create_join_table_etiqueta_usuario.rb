class CreateJoinTableEtiquetaUsuario < ActiveRecord::Migration[4.2]
  def change
    create_table :etiqueta_usuario do |t|
      t.references :etiqueta
      t.references :usuario
      t.timestamps
    end
  end
end
