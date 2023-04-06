# vim: set expandtab tabstop=2 shiftwidth=2 fileencoding=utf-8:
# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
#

#//= require sivel2_gen/motor
#//= require cor1440_gen/motor
#//= require cocoon
#//= require sivel2_sjr/AutocompletaAjaxListadocasos

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
    lcg = $('#ubicaciones .control-group[style!="display: none;"]')
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

# Recibe rangos de edad y los presenta
@sivel2_sjr_completa_rangosedadac = (root, e) ->
  divcp = root.sivel2_sjr_autocompleta_contacto_actividad_divcp
  for sexo, s of e
    totsexo = 0
    for rango, re of s
      eh = divcp.querySelector('[id^=actividad_actividad_casosjr_attributes_][id$=_rangoedad_' + sexo + '_' + rango + ']')
      eh.value = re
      totsexo += re
    if sexo == 'F'
      cls = '.fam_mujeres'
    else if sexo == 'M'
      cls = '.fam_hombres'
    else
      cls = '.fam_sinsexo'
    et = divcp.querySelector(cls).innerText = totsexo
  $(document).trigger('sivel2sjr:autocompletado-contactoactividad')
  return


# Modifica un enlace agregando parámetros que toma del formulario
# @elema this del enlace por modificar
# @veccv vector de ids de elementos con valores por enviar como 
#   parámetros en enlace
# @datos hash con otro atributos=>valores por agregar como parámetros a enlace
@jrs_agrega_paramscv = (elema, veccv, datos) ->

  #root =  window;
  #msip_arregla_puntomontaje(root)
  ruta = $(elema).attr('href') 
  sep = '?'
  veccv.forEach((v) ->
    elemv = $('#' + v)
    vcv = ''
    if (typeof elemv[0] == 'object') && elemv[0].nodeName == 'INPUT' && elemv[0].type == 'checkbox'
      vcv = elemv.prop('checked')
    else if typeof elemv[0] == 'object' && elemv[0].nodeName == 'SELECT'
      vcv = elemv.val()
    ruta += sep + v + '=' + vcv
    sep = '&' 
  )
  for l,v of datos
    ruta += sep + l + '=' + v
    sep = '&' 

  $(elema).attr('href', ruta)


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


# Completa cálculo de tabla de población 
# agregando beneficiarios de casos
@jrs_agrega_beneficiarios_casos = (rangos, idrf) ->
  # Recorre listado de casos
  $('#actividad_casosjr').children().find('[id^=actividad_actividad_casosjr_attributes_][id*=_rangoedad]').each( (i, h) -> 
    if $(this).parent().parent().css('display') != 'none'
      # No usamos $(this).parent().is(':visible') porque excluye
      # casos cuando esta contraido listado de actividades
      pid = $(this).attr('id').match(/.*_([MSF])_([0-9]*)$/)
      if pid.length<3
        alert('Problema para extraer informacion de id=' + $(this).attr('id'))
      else
        sexo = pid[1]
        idran = pid[2]
        cor1440_gen_aumenta_poblacion(idrf, sexo, idran, $(this).val())
  )
  if typeof jrs_refresca_posibles_beneficiarios_casos == 'function'
    jrs_refresca_posibles_beneficiarios_casos



# Recalcula tabla poblacion en actividad a partir de listado de 
# personas beneficiarias  y de casos beneficiarios (método 2 con
# llamada AJAX para recuperar información de rangos de edad)
@jrs_recalcula_poblacion = () ->
  cor1440_gen_recalcula_poblacion(jrs_agrega_beneficiarios_casos)


# Elije un contacto en autocompletación
@sivel2_sjr_autocompleta_contacto_actividad = (label, id, divcp, root) ->
  msip_arregla_puntomontaje(root)
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
  msip_ajax_recibe_json(root, ruta,
    {caso_id: pl[1], fecha: $('#actividad_fecha_localizada').val() }, 
    sivel2_sjr_completa_rangosedadac)
  return

# Busca persona por nombre, apellido o identificación
# s es objeto con foco donde se busca persona
@sivel2_sjr_busca_contacto_actividad = (s) ->
  root = window
  msip_arregla_puntomontaje(root)
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
  $(document).on('focusin', 'select[id^=caso_desplazamiento_attributes_][id$=expulsion_id]', (e) ->
    actualiza_ubicaciones($(this))
  )

  # En desplazamientos, lista de sitios de llegada se cálcula
  $(document).on('focusin', 'select[id^=caso_desplazamiento_attributes_][id$=llegada_id]', (e) ->
    actualiza_ubicaciones($(this))
  )

  # En refugios, lista de sitios de salida se cálcula
  $(document).on('focusin', 'select[id^=caso_casosjr_attributes_][id$=salida_id]', (e) ->
    actualiza_ubicaciones($(this))
  )

  # En refugio, lista de sitios de llegada se cálcula
  $(document).on('focusin', 'select[id^=caso_casosjr_attributes_][id$=llegada_id]', (e) ->
    actualiza_ubicaciones($(this))
  )

  # Antes de eliminar ubicacion confirmar si se eliminan dependientes
  $('#ubicaciones').on('cocoon:before-remove', (e, papa) ->
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
    if ($('#caso_casosjr_attributes_salida_id').val() == id) 
      msg+=msgsep + "Sitio de Salida del Refugio"; 
      root.elimrefugiosalida = true;
      msgsep=" y "
    if ($('#caso_casosjr_attributes_llegada_id').val() == id) 
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
  $('#ubicaciones').on('cocoon:after-remove', (e, papa) ->
    elimina_pendientes(root.elempe);
    root.elempe = []
    if (root.elimrefugiosalida) 
      $('#caso_casosjr_attributes_salida_id').val("")
      root.elimrefugiosalida = false
    if (root.elimrefugiollegada) 
      $('#caso_casosjr_attributes_llegada_id').val("")
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
  #$('#desplazamiento').on('click', '.add_fields', (e) ->
  #  lcg = $('#ubicaciones .control-group[style!="display: none;"]')
  #  if (lcg.length < 2)
  #    alert('Debe haber antes por lo menos dos sitios geográficos')
  #    return false
  #)


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
    vss=$('#caso_casosjr_attributes_salida_id').val()
    vfl=$('#caso_casosjr_attributes_fechallegada').val()
    vsl=$('#caso_casosjr_attributes_llegada_id').val()
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

  #$(document).on('focusin', 'input[id^=actividad_actividad_casosjr_attributes][id$=_casosjr_id]', (e) ->
  #  sivel2_sjr_busca_contacto_actividad($(this))
  #)

  # En listado de casos permite autocompletar caso
  Sivel2SjrAutocompletaAjaxListadocasos.iniciar()

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

  

  # Tras autocompletar contacto de un caso beneficiario
  $(document).on('sivel2sjr:autocompletado-contactoactividad', (e, papa) ->
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
      msip_enviarautomatico_formulario($('form'), 'POST', 'json', false)
      elimina_destruidos()
      actualiza_presponsables($('#caso_acto_presponsable_id'))
      actualiza_victimas($('#caso_acto_persona_id'))
      actualiza_desplazamientos($('#caso_acto_desplazamiento_id'))
      root.tfichacambia = Date.now()
    return
  )

  return
