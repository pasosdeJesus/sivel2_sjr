conexion = ActiveRecord::Base.connection();

# De motores
Msip::carga_semillas_sql(conexion, 'msip', :datos)
motor = ['sivel2_gen', '../..', 'cor1440_gen']
motor.each do |m|
    Msip::carga_semillas_sql(conexion, m, :cambios)
    Msip::carga_semillas_sql(conexion, m, :datos)
end


# Usuario para primer ingreso sivel2, sivel2
conexion.execute("INSERT INTO public.usuario 
	(nusuario, email, encrypted_password, password, 
  fechacreacion, created_at, updated_at, rol) 
	VALUES ('sivel2', 'sivel2@localhost', 
	'$2a$10$V2zgaN1ED44UyLy0ubey/.1erdjHYJusmPZnXLyIaHUpJKIATC1nG',
	'', '2014-08-14', '2014-08-14', '2014-08-14', 1);")

