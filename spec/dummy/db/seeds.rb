# encoding: UTF-8

connection = ActiveRecord::Base.connection();

# Básicas de motor sip
l = File.readlines(
  Gem.loaded_specs['sip'].full_gem_path + "/db/datos-basicas.sql"
)
connection.execute(l.join("\n"))

# Básicas de motor SIVeL genérico
l = File.readlines(
  Gem.loaded_specs['sivel2_gen'].full_gem_path + "/db/datos-basicas.sql"
)
connection.execute(l.join("\n"))

# Cambios a básicas anteriores
l = File.readlines("../../db/cambios-basicas.sql")
connection.execute(l.join("\n"))

# Nuevas basicas de este motor
l = File.readlines("../../db/datos-basicas.sql")
connection.execute(l.join("\n"));

# Usuario para primer ingreso
connection.execute("INSERT INTO usuario 
	(nusuario, email, encrypted_password, password, 
  fechacreacion, created_at, updated_at, rol) 
	VALUES ('sivel2', 'sivel2@localhost', 
	'$2a$10$V2zgaN1ED44UyLy0ubey/.1erdjHYJusmPZnXLyIaHUpJKIATC1nG',
	'', '2014-08-14', '2014-08-14', '2014-08-14', 1);")

