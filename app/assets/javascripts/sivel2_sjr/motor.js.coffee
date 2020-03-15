# vim: set expandtab tabstop=2 shiftwidth=2 fileencoding=utf-8:
# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
#

#//= require sivel2_gen/motor
#//= require cor1440_gen/motor
#//= require cocoon

# Regenera lista de selección de desplazamientos
# s es un select jquery
@actualiza_desplazamientos = (s) ->
    sel = s.val()
    nh = '<option value=""></option>'
    lcg = $('#desplazamiento .control-group[style!="display: none;"]')
    lcg.each((k, v) ->
      # id: fechaexpulsion
      tx = $(v).find('.caso_desplazamiento_id input').val()
      id = $(v).find('input[id^=caso_desplazamiento_attributes_][id$=_id]').val()
      nh = nh + "<option value='" + id + "'"
      if id == sel 
        nh = nh + ' selected'
      # texto: fechaexpulsion
      tx = $(v).find('.caso_desplazamiento_fechaexpulsion input').val()
      nh = nh + ">" + tx + "</option>" )
    s.html(nh)

# Regenera lista de selección de ubicaciones
# s es un select jquery
@actualiza_ubicaciones = (s) ->
    sel = s.val()
    nh = ''
    lcg = $('#ubicacion .control-group[style!="display: none;"]')
    lcg.each((k, v) ->
      # id: ubicacion
      id = $(v).find('.caso_ubicacion_id input').val()
      nh = nh + "<option value='" + id + "'"
      if id == sel 
        nh = nh + ' selected'
      idp = $(v).find('.caso_ubicacion_pais select').val()
      tx = $(v).find('.caso_ubicacion_pais select option[value=' + idp + ']').text()
      idd = $(v).find('.caso_ubicacion_departamento select').val()
      if (idd > 0)
        tx = tx + " / " + $(v).find('.caso_ubicacion_departamento select option[value=' + idd + ']').text()
        idm = $(v).find('.caso_ubicacion_municipio select').val()
        if (idm > 0)
          tx = tx + " / " + $(v).find('.caso_ubicacion_municipio select option[value=' + idm + ']').text()
          idc = $(v).find('.caso_ubicacion_clase select').val()
          if (idc > 0)
            tx = tx + " / " + $(v).find('.caso_ubicacion_clase select option[value=' + idc + ']').text()
      nh = nh + ">" + tx + "</option>" )
    s.html(nh)


# Aumenta una fila a tabla de población y completa idrf
# Será fila que tendrá rango con id idrango
@sivel2_sjr_aumenta_fila_poblacion = (idrf, idrango) ->
  # Agregar rango y actualizar idrf
  $('a[data-association-insertion-node$=actividad_rangoedadac]').click()
  uf = $('#actividad_rangoedadac').children().last()
  e = uf.find('[id^=actividad_actividad_rangoedadac_attributes][id$=_rangoedadac_id]')
  idrf[idrango] = /actividad_actividad_rangoedadac_attributes_(.*)_rangoedadac_id/.exec(e.attr('id'))[1]
  $('select[id^=actividad_actividad_rangoedadac_attributes_' + idrf[idrango] + '_rangoedadac_id]').val(idrango)


# Recibe rangos de edad y los presenta
@sivel2_sjr_completa_rangosedadac = (root, e) ->
  divcp = root.sivel2_sjr_autocompleta_contacto_actividad_divcp
  for sexo, s of e
    totsexo = 0
    for rango, re of s
      eh = divcp.find('[id^=actividad_actividad_casosjr_attributes_][id$=_rangoedad_' + sexo + '_' + rango + ']')
      eh.val(re)
      totsexo += re
    if sexo == 'F'
      cls = '.fam_mujeres'
    else if sexo == 'M'
      cls = '.fam_hombres'
    else
      cls = '.fam_sinsexo'
    et = divcp.find(cls).text(totsexo)

  if typeof jrs_recalcula_poblacion == 'function'
    jrs_recalcula_poblacion()
  return


# Modifica un enlace agregando parámetros que toma del formulario
# @elema this del enlace por modificar
# @veccv vector de elementos con valores por enviar como parámetros en enlace
# @datos otros valores por agregar como parámetros a enlace
@jrs_agrega_paramscv = (elema, veccv, datos) ->

  #root =  window;
  #sip_arregla_puntomontaje(root)
  ruta = $(elema).attr('href') 
  sep = '?'
  veccv.forEach((v) ->
    elemv = $('#' + v)
    vcv = ''
    if elemv[0].nodeName == 'INPUT' && elemv[0].type == 'checkbox'
      vcv = elemv.prop('checked')
    else if elemv[0].nodeName == 'SELECT'
      vcv = elemv.val()
    ruta += sep + v + '=' + vcv
    sep = '&' 
  )
  for l,v of datos
    ruta += sep + l + '=' + v
    sep = '&' 

  $(elema).attr('href', ruta)


# resp Objeto JSON con rangosedadac, respuesta de llamada AJAX
# rangos Por llenar con rangos de edad
# idrf Por llenar con datos de tabla población (y reordenar tabla si se requiere)
@cor1440_gen_identifica_ids_rangoedad = (resp, rangos, idrf) ->
  # idrf[i] será id que rails le asignó al generar HTML a la fila
  # del rango de edad con id i en la tabla cor1440_gen_rangoedadac
  for i, r of resp
    rangos[r.id] = [r.limiteinferior, r.limitesuperior]
    idrf[r.id] = -1

  # Llena id de elemento en formulario en idrf y borra redundantes
  # de la tabla de población.
  $('select[id^=actividad_actividad_rangoedadac_attributes_][id$=_rangoedadac_id]').each((i, v) ->
    nr = +$(this).val()
    if idrf[nr] != -1 # Repetido, unir con el inicial
      fl2 = $(this).parent().parent().find('input[id^=actividad_actividad_rangoedadac_attributes_][id$=_fl]').val()
      ml2 = $(this).parent().parent().find('input[id^=actividad_actividad_rangoedadac_attributes_][id$=_ml]').val()
      sl2 = $(this).parent().parent().find('input[id^=actividad_actividad_rangoedadac_attributes_][id$=_sl]').val()
      $(this).parent().parent().find('a.remove_fields').click()
      prl = '#actividad_actividad_rangoedadac_attributes_' + idrf[nr] 
      fl1 = $(prl + '_fl').val()
      ml1 = $(prl + '_ml').val()
      sl1 = $(prl + '_sl').val()
      $(prl + '_fl').val(fl1 + fl2)
      $(prl + '_ml').val(ml1 + ml2)
      $(prl + '_sl').val(sl1 + sl2)
    else
      idrf[nr] = /actividad_actividad_rangoedadac_attributes_(.*)_rangoedadac_id/.exec($(this).attr('id'))[1]
  )
      
 


# A partir del HTML llena rangos y objeto idrf, a su vez elimina 
# duplicados de la tabla población
# @param rangos Hash con rangos de edad en base de datos
#   cada elemento es de la forma idbase=>[inf, sup]. Para el rango 
#   SIN INFORMACIÓN se espera convención que inf y sup sean -1 en base y aquí
# @param idrf Hash con las identificaciones de los elementos
#   de rango añadidos en la tabla, cada entrada es de la forma
#   idbase => idelemento
@jrs_identifica_ids_rangoedad = (rangos, idrf) ->
  cantr = $('#rangoedadac_cant').val()
  sin = -1
  res = -1
  for i in [0..cantr-1] 
    inf = $('#rangoedadac_d_' + i).data('inf')
    if inf != ''
      inf = +inf
    sup = $('#rangoedadac_d_' + i).data('sup')
    if sup!= ''
      sup = +sup
    idran = +$('#rangoedadac_d_' + i).val()
    if (inf == -1) 
      rangos[idran] = [-1,-1]
    else 
      rangos[idran] = [inf, sup]

  for i, r of rangos
    idrf[i] = -1
  # Llena id de elemento en formulario en idrf y borra redundantes.
  $('select[id^=actividad_actividad_rangoedadac_attributes_][id$=_rangoedadac_id]').each((i, v) ->
    nr = +$(this).val()
    if idrf[nr] != -1 # Repetido, unir con el inicial
      fl2 = $(this).parent().parent().find('input[id^=actividad_actividad_rangoedadac_attributes_][id$=_fl]').val()
      ml2 = $(this).parent().parent().find('input[id^=actividad_actividad_rangoedadac_attributes_][id$=_ml]').val()
      $(this).parent().parent().find('a.remove_fields').click()
      prl = '#actividad_actividad_rangoedadac_attributes_' + idrf[nr] 
      fl1 = $(prl + '_fl').val()
      ml1 = $(prl + '_ml').val()
      $(prl + '_fl').val(fl1 + fl2)
      $(prl + '_ml').val(ml1 + ml2)
    else
      idrf[nr] = /actividad_actividad_rangoedadac_attributes_(.*)_rangoedadac_id/.exec($(this).attr('id'))[1]
  )


# Aumenta valor en tabla población para el sexo y rango de edad dado en la cantidad 
# dada
@jrs_aumenta_poblacion=(idrf, sexo, idran, cantidad) ->
  if +cantidad == 0 
    return
  if idrf[idran] == -1 
    sivel2_sjr_aumenta_fila_poblacion(idrf, idran)
  
  pref = '#actividad_actividad_rangoedadac_attributes_' + idrf[idran]
  if sexo == 'F'
    fr = +$(pref + '_fr').val()
    $(pref + '_fr').val(fr + (+cantidad))
    cor1440_gen_rangoedadac($(pref + '_fr'))
  else if sexo == 'M'    
    mr = +$(pref + '_mr').val()
    $(pref + '_mr').val(mr + (+cantidad))
    cor1440_gen_rangoedadac($(pref + '_mr'))
  else    
    sr = +$(pref + '_s').val()
    $(pref + '_s').val(sr + (+cantidad))
    cor1440_gen_rangoedadac($(pref + '_s'))
  $('#actividad_rangoedadac').find('input[id^=actividad_actividad_rangoedadac_attributes]').each () ->
    if +$(this).val() == 0
      cor1440_gen_rangoedadac($(this))



# Llamada asincronamente después de cor1440_gen_recalcula_poblacion
# con resultado de respuesta AJAX
@cor1440_gen_recalcula_poblacion2 = (root, resp, fsig) ->
  # Identifica rangos de edad en base y en tabla resumiendo tabla si hace falta
  rangos = {}
  idrf = {}
  cor1440_gen_identifica_ids_rangoedad(resp, rangos, idrf)

  # Fecha del caso
  fap = $('#actividad_fecha_localizada').val().split('-')
  anioref  = +fap[0]
  mesref  = +fap[1]
  diaref  = +fap[2]

  # Recorre listado de personas 
  $('[id^=actividad_asistencia_attributes][id$=_persona_attributes_anionac]').each((i, v) ->
    # excluye eliminadas
    if $(this).parent().parent().parent().css('display') != 'none'
      debugger
      ida = /actividad_asistencia_attributes_(.*)_persona_attributes_anionac/.exec($(this).attr('id'))[1]
      anionac = $(this).val()
      mesnac = $('[id=actividad_asistencia_attributes_' + ida + '_persona_attributes_mesnac]').val()
      dianac = $('[id=actividad_asistencia_attributes_' + ida + '_persona_attributes_dianac]').val()
  
      e = +sivel2_gen_edadDeFechaNacFechaRef(anionac, mesnac, dianac, anioref, mesref, diaref)
      idran = -1  # id del rango en el que está e
      ransin = -1 # id del rango SIN INFORMACION
      #debugger
      for i, r of rangos
        if (r[0] <= e || r[0] == '' || r[0]  == null) && (e <= r[1] || r[1] == '' || r[1] == null)
          idran = i
  #          if idrf[i] == -1
  #            sivel2_sjr_aumenta_fila_poblacion(idrf, i)
        else if r[0] == -1
          ransin = i
      if idran == -1
        idran = ransin
      sexo = $(this).parent().parent().parent().find('[id^=actividad_asistencia_attributes][id$=_persona_attributes_sexo]:visible').val()
      if idran < 0
        alert('No pudo ponerse en un rango de edad')
      else
        jrs_aumenta_poblacion(idrf, sexo, idran, 1)
  )

  if fsig != null
    fsig(rangos, idrf)



# Hace petición AJAX para recalcular tabla poblacion en actividad 
# a partir de listado de personas beneficiarias  y de casos 
# beneficiarios
# fsig es función que llamará después de completar con registro con
#   datos que ha calculado como rangos e idrf
@cor1440_gen_recalcula_poblacion = (fsig = null) ->
  if $('[id^=actividad_asistencia_attributes]:visible').length > 0  || $('#actividad_casosjr').find('tr:visible').length > 0  
    # No permitiria añadir manualmente a población 
    # $('a[data-association-insertion-node$=actividad_rangoedadac]').hide()
    # Pone en blanco las cantidades y deshabilita edición
    $('input[id^=actividad_actividad_rangoedadac_attributes_][id$=_fr]').each((i, v) ->
      $(this).val(0)
      $(this).prop('readonly', true);
     )
    $('input[id^=actividad_actividad_rangoedadac_attributes_][id$=_mr]').each((i, v) ->
      $(this).val(0)
      $(this).prop('readonly', true);
    ) 
    $('input[id^=actividad_actividad_rangoedadac_attributes_][id$=_s]').each((i, v) ->
      $(this).val(0)
      $(this).prop('readonly', true);
    ) 
  else
    $('input[id^=actividad_actividad_rangoedadac_attributes_][id$=_fr]').each((i, v) ->
      $(this).val(0)
      $(this).prop('readonly', false);
    )
    $('input[id^=actividad_actividad_rangoedadac_attributes_][id$=_mr]').each((i, v) ->
      $(this).val(0)
      $(this).prop('readonly', false);
    ) 
    $('input[id^=actividad_actividad_rangoedadac_attributes_][id$=_s]').each((i, v) ->
      $(this).val(0)
      $(this).prop('readonly', false);
    ) 

  sip_funcion_1p_tras_AJAX('admin/rangosedadac.json?filtro[bushabilitado]=Si&filtrar=Filtrar', {}, cor1440_gen_recalcula_poblacion2, fsig, 'solicitando rangos de edad a servidor')



# Elije un contacto en autocompletación
@sivel2_sjr_autocompleta_contacto_actividad = (label, id, divcp, root) ->
  sip_arregla_puntomontaje(root)
  cs = id.split(";")
  caso_id = cs[0]
  pl = []
  ini = 0
  for i in [1..cs.length] by 1
     t = parseInt(cs[i])
     pl[i] = label.substring(ini, ini + t)
     ini = ini + t + 1
  # pl[1] cnom, pl[2] es cape, pl[3] es cdoc
  divcp.find('input[id^=actividad_actividad_casosjr_attributes_][id$=casosjr_id]').val(caso_id)
  divcp.find('input[id^=actividad_actividad_casosjr_attributes_][id$=casosjr_id]').prop('readonly', true).attr('type', 'hidden')
  divcp.find('input[id^=actividad_actividad_casosjr_attributes_][id$=casosjr_id]').parent().append("<a href='/casos/" + pl[1] + "' target=_blank>" + pl[1] + "</a>")
  divcp.find('.nombres').text(pl[2])
  divcp.find('.apellidos').text(pl[3])
  divcp.find('.tipodocumento').text(pl[4])
  divcp.find('.numerodocumento').text(pl[5])
  root.sivel2_sjr_autocompleta_contacto_actividad_divcp = divcp
  ruta = root.puntomontaje +  "actividades/poblacion_sexo_rangoedadac"
  if ruta[0] == '/'
    ruta = ruta.substr(1)
  sip_ajax_recibe_json(root, ruta,
    {id_caso: pl[1], fecha: $('#actividad_fecha_localizada').val() }, 
    sivel2_sjr_completa_rangosedadac)
  return

# Completa cálculo de tabla de población 
# agregando beneficiarios de casos
@jrs_agrega_beneficiarios_casos = (rangos, idrf) ->
  # Recorre listado de casos
  $('#actividad_casosjr').children().find('[id^=actividad_actividad_casosjr_attributes_][id*=_rangoedad]').each( (i, h) -> 
    if $(this).parent().parent().css('display') != 'none'
      # No usamos $(this).parent().is(':visible') porque excluye
      # casos cuando esta contraido listaod de actividades
      pid = $(this).attr('id').match(/.*_([MSF])_([0-9]*)$/)
      if pid.length<3
        alert('Problema para extraer informacion de id=' + $(this).attr('id'))
      else
        sexo = pid[1]
        idran = pid[2]
        jrs_aumenta_poblacion(idrf, sexo, idran, $(this).val())
  )


# Recalcula tabla poblacion en actividad a partir de listado de 
# personas beneficiarias  y de casos beneficiarios (método 2 con
# llamada AJAX para recuperar información de rangos de edad)
@jrs_recalcula_poblacion = () ->
  cor1440_gen_recalcula_poblacion(jrs_agrega_beneficiarios_casos)


# Elije un contacto en autocompletación
@sivel2_sjr_autocompleta_contacto_actividad = (label, id, divcp, root) ->
  sip_arregla_puntomontaje(root)
  cs = id.split(";")
  caso_id = cs[0]
  pl = []
  ini = 0
  for i in [1..cs.length] by 1
     t = parseInt(cs[i])
     pl[i] = label.substring(ini, ini + t)
     ini = ini + t + 1
  # pl[1] cnom, pl[2] es cape, pl[3] es cdoc
  divcp.find('input[id^=actividad_actividad_casosjr_attributes_][id$=casosjr_id]').val(caso_id)
  divcp.find('input[id^=actividad_actividad_casosjr_attributes_][id$=casosjr_id]').prop('readonly', true).attr('type', 'hidden')
  divcp.find('input[id^=actividad_actividad_casosjr_attributes_][id$=casosjr_id]').parent().append("<a href='/casos/" + pl[1] + "' target=_blank>" + pl[1] + "</a>")
  divcp.find('.nombres').text(pl[2])
  divcp.find('.apellidos').text(pl[3])
  divcp.find('.tipodocumento').text(pl[4])
  divcp.find('.numerodocumento').text(pl[5])
  root.sivel2_sjr_autocompleta_contacto_actividad_divcp = divcp
  ruta = "api/sivel2sjr/poblacion_sexo_rangoedadac"
  #debugger
  sip_ajax_recibe_json(root, ruta,
    {id_caso: pl[1], fecha: $('#actividad_fecha_localizada').val() }, 
    sivel2_sjr_completa_rangosedadac)
  return

# Busca persona por nombre, apellido o identificación
# s es objeto con foco donde se busca persona
@sivel2_sjr_busca_contacto_actividad = (s) ->
  root = window
  sip_arregla_puntomontaje(root)
  cnom = s.attr('id')
  v = $("#" + cnom).data('autocompleta')
  if (v != 1 && v != "no") 
    $("#" + cnom).data('autocompleta', 1)
    divcp = s.closest('.nested-fields')
    if (typeof divcp == 'undefined')
      alert('No se ubico .nested-fields')
      return
    idac = divcp.parent().find('.actividad_actividad_casosjr_id').find('input').val()
    if (typeof idac == 'undefined')
      alert('No se ubico actividad_actividad_casosjr_id')
      return
    $("#" + cnom).autocomplete({
      source: root.puntomontaje + "casos/busca.json",
      minLength: 2,
      select: ( event, ui ) -> 
        if (ui.item) 
          sivel2_sjr_autocompleta_contacto_actividad(ui.item.value, ui.item.id, divcp, root)
          event.stopPropagation()
          event.preventDefault()
    })
  return

@sivel2_sjr_prepara_eventos_comunes = (root) ->
  # En actos, lista de desplazamientos se cálcula
  $(document).on('focusin', 'select[id^=caso_acto_][id$=desplazamiento_id]', (e) ->
    actualiza_desplazamientos($(this))
  )

  # En desplazamientos, lista de sitios de expulsión se cálcula
  $(document).on('focusin', 'select[id^=caso_desplazamiento_attributes_][id$=id_expulsion]', (e) ->
    actualiza_ubicaciones($(this))
  )

  # En desplazamientos, lista de sitios de llegada se cálcula
  $(document).on('focusin', 'select[id^=caso_desplazamiento_attributes_][id$=id_llegada]', (e) ->
    actualiza_ubicaciones($(this))
  )

  # En refugios, lista de sitios de salida se cálcula
  $(document).on('focusin', 'select[id^=caso_casosjr_attributes_][id$=id_salida]', (e) ->
    actualiza_ubicaciones($(this))
  )

  # En refugio, lista de sitios de llegada se cálcula
  $(document).on('focusin', 'select[id^=caso_casosjr_attributes_][id$=id_llegada]', (e) ->
    actualiza_ubicaciones($(this))
  )

  # Antes de eliminar ubicacion confirmar si se eliminan dependientes
  $('#ubicacion').on('cocoon:before-remove', (e, papa) ->
    # Si ingresa más de una vez se evita duplicar
    if (root.elempe && root.elempe.length>0) 
      return
    root.elempe = []
    root.elimrefugiosalida = false
    root.elimrefugiollegada = false
    usel=papa.find('.caso_ubicacion_id input')
    if (usel.length>0)
      id = usel.val()
      nomelempe = "desplazamientos"
      nomesteelem = "este sitio geográfico"
      $('#desplazamiento .control-group[style!="display: none;"] .caso_desplazamiento_expulsion select').each((v, e) ->
        if ($(e).val() == id) 
          root.elempe.push($(e).parent().parent());
      )
      $('#desplazamiento .control-group[style!="display: none;"] .caso_desplazamiento_llegada select').each((v, e) ->
        if ($(e).val() == id) 
          root.elempe.push($(e).parent().parent());
      )
    msg=""
    msgsep="Junto con " + nomesteelem + " por eliminar: "   
    if (root.elempe.length>0)
      msg+=msgsep + root.elempe.length + " " + nomelempe
      msgsep=" y "
    if ($('#caso_casosjr_attributes_id_salida').val() == id) 
      msg+=msgsep + "Sitio de Salida del Refugio"; 
      root.elimrefugiosalida = true;
      msgsep=" y "
    if ($('#caso_casosjr_attributes_id_llegada').val() == id) 
      msg+=msgsep + "Sitio de Llegada del Refugio"; 
      root.elimrefugiollegada = true;
      msgsep=" y "

    if (msg != "")
      msg+=", ¿Continuar?"
      r = confirm(msg)
      if (r==false)
       papa.data('remove-cancel', 'true')
       root.elempe = []
       root.elimrefugio = false
      else
        papa.data('remove-cancel', 'false')
  )

  # Tras eliminar ubicacion, eliminar dependientes
  $('#ubicacion').on('cocoon:after-remove', (e, papa) ->
    elimina_pendientes(root.elempe);
    root.elempe = []
    if (root.elimrefugiosalida) 
      $('#caso_casosjr_attributes_id_salida').val("")
      root.elimrefugiosalida = false
    if (root.elimrefugiollegada) 
      $('#caso_casosjr_attributes_id_llegada').val("")
      root.elimrefugiollegada = false
  )
 
  # Antes de eliminar desplazamiento confirmar si se eliminan dependientes
  $('#desplazamiento').on('cocoon:before-remove', (e, papa) ->
    # Si ingresa más de una vez se evita duplicar
    if (root.elempe && root.elempe.length>0) 
      return
    root.elempe = []
    usel=papa.find('.caso_desplazamiento_fechaexpulsion input')
    if (usel.length>0)
      id = usel.val()
      nomelempe = "causas/antecedentes"
      nomesteelem = "este desplazamiento"
      $('#antecedentes .control-group[style!="display: none;"] .caso_acto_desplazamiento select').each((v, e) ->
        if ($(e).val() == id) 
          root.elempe.push($(e).parent().parent());
      )
      if (root.elempe.length>0)
        r = confirm("Hay " + root.elempe.length + " " + nomelempe + 
          " que se eliminarán con " + nomesteelem + ", ¿Continuar?")
        if (r==false)
          papa.data('remove-cancel', 'true')
          root.elempe = []
        else
          papa.data('remove-cancel', 'false')
      lelempe = root.elempe.length
      nomelempe = "sesionesantecedentes"
      nomesteelem = "este desplazamiento"
      $('#ayudasjr .control-group[style!="display: none;"] .caso_respuesta_desplazamiento select').each((v, e) ->
        if ($(e).val() == id) 
          root.elempe.push($(e).parent().parent());
      )

    if (root.elempe.length > lelempe)
      r = confirm("Hay " + root.elempe.length + " " + nomelempe + 
        " que se eliminarán con " + nomesteelem + ", ¿Continuar?")
      if (r==false)
        papa.data('remove-cancel', 'true')
        root.elempe = []
  )

  # Tras eliminar desplazamiento, eliminar dependientes
  $('#desplazamiento').on('cocoon:after-remove', (e, papa) ->
    elimina_pendientes(root.elempe);
    root.elempe = []
  )
 
  # Antes de añadir desplazamiento verificar que haya al menos 2 ubicaciones
  $('#desplazamiento').on('click', '.add_fields', (e) ->
    lcg = $('#ubicacion .control-group[style!="display: none;"]')
    if (lcg.length < 2)
      alert('Debe haber antes por lo menos dos sitios geográficos')
      return false
  )


  # Al cambiar fecha del hecho cambiar fecha de salida si no se ha 
  # llenado refugio y cambiar fecha de antecedentes/causas
  # Método para detectar cambios en datepicker de
  # http://stackoverflow.com/questions/17009354/detect-change-to-selected-date-with-bootstrap-datepicker
  $('#caso_fecha').datepicker({
    format: 'yyyy-mm-dd'
    autoclose: true
    todayHighlight: true
    language: 'es'
  }).on('changeDate', (ev) ->
    vss=$('#caso_casosjr_attributes_id_salida').val()
    vfl=$('#caso_casosjr_attributes_fechallegada').val()
    vsl=$('#caso_casosjr_attributes_id_llegada').val()
    vcr=$('#caso_casosjr_attributes_categoriaref').val()
    vob=$('#caso_casosjr_attributes_observacionesref').val()
    if (vss == "" && vfl == "" && vsl == "" && vcr == "" && vob == "") 
      vfl=$('#caso_casosjr_attributes_fechasalida').val(this.value)
    vfa=$('#caso_acto_fecha').val(this.value)
    return
  #  $("article").css("cursor", "wait")
  #  $(this).parents("form").submit() 
  #  $("article").css("cursor", "default") 
  )

  # Al cambiar fecha de expulsión desplazamiento verificar que no esté repetida
  $(document).on('changeDate', 'input[id^=caso_desplazamiento][id$=_fechaexpulsion]', (e) ->
    idb = $(this).attr('id')
    fb = $(this).val()
    lcg = $('#desplazamiento .control-group[style!="display: none;"]')
    lcg.each((k, v) ->
      # id: fechaexpulsion
      d = $(v).find('.caso_desplazamiento_fechaexpulsion input')
      if idb != d.attr('id') && fb == d.val()
        talertan = +Date.now()
        if (typeof root.talerta == 'undefined' || talertan - root.talerta > 1000) 
          root.talerta = talertan
          alert('Fecha de expulsión repetida')
    )
    return
  )

  $(document).on('focusin', 'input[id^=actividad_actividad_casosjr_attributes][id$=_casosjr_id]', (e) ->
    sivel2_sjr_busca_contacto_actividad($(this))
  )

  # En actividad si se cambia sexo de un asistente
  # recalcula tabla de población
  $(document).on('change', '[id^=actividad_asistencia_attributes][id$=_persona_attributes_sexo]:visible', (e) ->
    if typeof jrs_recalcula_poblacion == 'function'
      jrs_recalcula_poblacion()
  )

  # En actividad si se cambia anio de nacimiento de un asistente
  # recalcula tabla de población
  $(document).on('change', '[id^=actividad_asistencia_attributes][id$=_persona_attributes_anionac]:visible', (e) ->
    if typeof jrs_recalcula_poblacion == 'function'
      jrs_recalcula_poblacion()
  )

  # En actividad si se cambia mes de nacimiento de un asistente
  # recalcula tabla de población
  $(document).on('change', '[id^=actividad_asistencia_attributes][id$=_persona_attributes_mesnac]:visible', (e) ->
    if typeof jrs_recalcula_poblacion == 'function'
      jrs_recalcula_poblacion()
  )

  # En actividad si se cambia dia de nacimiento de un asistente
  # recalcula tabla de población
  $(document).on('change', '[id^=actividad_asistencia_attributes][id$=_persona_attributes_dianac]:visible', (e) ->
    if typeof jrs_recalcula_poblacion == 'function'
      jrs_recalcula_poblacion()
  )

  # En actividad tras eliminar caso beneficiario recalcular población
  $('#actividad_casosjr').on('cocoon:after-remove', (e, papa) ->
    if typeof jrs_recalcula_poblacion == 'function'
      jrs_recalcula_poblacion()
  )
 
  # En actividad tras eliminar asistencia recalcular población
  $('#asistencia').on('cocoon:after-remove', (e, papa) ->
    if typeof jrs_recalcula_poblacion == 'function'
      jrs_recalcula_poblacion()
  )

  # Tras autocompletar asistente
  $(document).on('cor1440gen:autocompletado-asistente', (e, papa) ->
    if typeof jrs_recalcula_poblacion == 'function'
      jrs_recalcula_poblacion()
  )


  return


@sivel2_sjr_prepara_eventos_unicos = (root) ->
  # Envia formulario al presionar enlaces con clase fichacambia 
  # con más de 5 segundos de diferencia entre un click y el siguiente
  $(document).on('click', 'a.fichacambia[href^="#"]', (e) ->
    e.preventDefault()
    tn = Date.now()
    d = -1
    if (root.tfichacambia) 
      d = (tn - root.tfichacambia)/1000
    if (d == -1 || d>5) 
      sip_enviarautomatico_formulario($('form'), 'POST', 'json', false)
      elimina_destruidos()
      actualiza_presponsables($('#caso_acto_id_presponsable'))
      actualiza_victimas($('#caso_acto_id_persona'))
      actualiza_desplazamientos($('#caso_acto_desplazamiento_id'))
      root.tfichacambia = Date.now()
    return
  )

  return
