class RemoveExpulsionFromRespuesta < ActiveRecord::Migration[4.2]
  def change
		remove_column :respuesta, :fechaexpulsion
  end
end
