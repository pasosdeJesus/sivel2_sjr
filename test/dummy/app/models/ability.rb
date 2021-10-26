class Ability  < Sivel2Sjr::Ability

  def tablasbasicas
    return super()
  end

  # Autorizaciones con CanCanCan
  def initialize(usuario = nil)
    initialize_sivel2_sjr(usuario)
  end

end

