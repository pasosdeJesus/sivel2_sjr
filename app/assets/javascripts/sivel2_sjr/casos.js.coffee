# vim: set expandtab tabstop=2 shiftwidth=2 fileencoding=utf-8:
# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
#

#//= require jquery-ui/autocomplete
#//= require cocoon
#//= require sivel2_gen/geo
#//= require sivel2_gen/libcasos

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

  
$(document).on 'ready page:load',  -> 
  root = exports ? this
  prepara_eventos_comunes(root, 'antecedentes/causas')

  # En actos, lista de desplazamientos se cálcula
  $(document).on('focusin', 'select[id^=caso_acto_attributes_][id$=desplazamiento_id]', (e) ->
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
  # llenado refugio
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

  return
