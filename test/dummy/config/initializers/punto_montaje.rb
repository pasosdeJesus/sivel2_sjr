Dummy::Application.config.relative_url_root = ENV.fetch(
  'RUTA_RELATIVA', '/sivel2sjr')
Dummy::Application.config.assets.prefix = ENV.fetch(
  'RUTA_RELATIVA', '/sivel2sjr') + '/assets'

