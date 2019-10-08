# vim: set expandtab tabstop=2 shiftwidth=2 fileencoding=utf-8:
# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
#

#//= require sivel2_gen/motor
#//= require cor1440_gen/motor
#//= require jquery-ui/widgets/autocomplete
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
  divcp.find('input[id^=actividad_actividad_casosjr_attributes_][id$=casosjr_id]').parent().html("<a href='casos/" + pl[1] + "' target=_blank>" + pl[1] + "</a>")
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
    if (lcg.size() < 2)
      alert('Debe haber antes por lo menos dos sitios geograficos')
      e.preventDefault()
    return
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
