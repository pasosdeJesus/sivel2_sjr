#!/bin/sh
# Convierte de sivel2_sjr 2.2.0.beta1 a 2.2.0.beta2

for i in `git ls-tree -r main --name-only`; do
  excluye=0
  if (test "$i" == "-") then {
    excluye=1;
  } else {
    for j in db/migrate node_modules db/structure.sql bin/act; do 
      echo $i | grep "$j" > /dev/null 2>&1
      if (test "$?" = "0") then {
        excluye=1;
      } fi;
    done;
  } fi;
  if (test "$excluye" == "1") then {
    echo "Excluyendo de conversión $i";
  } else {
    n=$i
    antn="";

    for j in id_acreditacion:acreditacion_id \
      id_actividadoficio:actividadoficio_id id_acto:acto_id \
      id_anexo:anexo_id id_aslegal:aslegal_id \
      id_aspsicosocial:aspsicosocial_id id_ayudaestado:ayudaestado_id \
      id_ayudasjr:ayudasjr_id id_caso:caso_id id_causaref:causaref_id \
      id_clasifdesp:clasifdesp_id id_declaroante:declaroante_id \
      id_departamento:departamento_id id_derecho:derecho_id \
      id_escolaridad:escolaridad_id id_estadocivil:estadocivil_id \
      id_expulsion:expulsion_id id_idioma:idioma_id id_inclusion:inclusion_id \
      id_llegada:llegada_id id_maternidad:maternidad_id \
      id_modalidadtierra:modalidadtierra_id id_motivosjr:motivosjr_id \
      id_municipio:municipio_id id_pais:pais_id \
      id_personadesea:personadesea_id id_progestado:progestado_id \
      id_proteccion:proteccion_id id_regimensalud:regimensalud_id \
      id_respuesta:respuesta_id id_rolfamilia:rolfamilia_id \
      id_salida:salida_id id_statusmigratorio:estatusmigratorio_id \
      id_tipodesp:tipodesp_id id_victima:victima_id; do
      antes=`echo $j | sed -e 's/:.*//g'`;
      despues=`echo $j | sed -e 's/.*://g'`;
      grep "$antes" $n > /dev/null;
      if (test "$?" = "0") then {
        if (test "$antn" != "$n") then {
          echo "";
          echo -n "Remplazando en $n: ";
          antn=$n
        } fi;
        echo -n " $antes"
        sed -i -e "s/$antes/$despues/g" $n;
      } fi;
    done;
  } fi;
done;
echo "";
