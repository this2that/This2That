class StreamHandler extends Spine.Module
  @include Ryggrad.Log
  logPrefix: "(Stream)"
  
  constructor: (@options = {}) ->
    @options.key or= $('meta[name=stream-key]').attr('content')
    
    @source = new EventSource("events?key=#{@options.key}")

    @source.addEventListener 'create', (e) =>
      data = JSON.parse(e.data)
      @processWithoutAjax('create', data)

    @source.addEventListener 'update', (e) =>
      data = JSON.parse(e.data)
      @processWithoutAjax('update', data)
    
    @source.addEventListener 'destroy', (e) =>
      data = JSON.parse(e.data)
      @processWithoutAjax('destroy', data)

  process: (type, msg) =>
    @log 'process:', type, msg
    
    klass = window[msg.class]
    throw 'unknown class' unless klass
    
    switch type
      when 'create'
        klass.create msg.record unless klass.exists(msg.record.id)
      when 'update'
        klass.update msg.id, msg.record
      when 'destroy'
        klass.destroy msg.id
      else
        throw 'Unknown type:' + type
        
  processWithoutAjax: =>
    args = arguments
    Spine.Ajax.disable =>
      @process(args...)
  
$ -> new StreamHandler
