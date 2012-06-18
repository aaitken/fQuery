#aliases/dependencies
_RWB = window._RWBOOKMARK
qwery = _RWB._utils.qwery

#helper namespacing
# _RWB._utils.namespace('$')
# _RWB._utils.namespace('_utils.fQuery')


((scope)->


  fQuery = (selector)->
    return new fQuery::init(selector)

  #---------------------------------------------------------------- static

  fQuery.ajax = (options={})->

    contentType = options.contentType || 'application/x-www-form-urlencoded' #not acknowledged by XDomainRequest Objs
    cors = options.cors || false
    data = options.data || ''
    success = options.success || (responseText, statusText)->
      #alert("responseText: #{responseText}; statusText: #{statusText}")
    type = options.type || 'GET'
    url = options.url
    xhr = new XMLHttpRequest()

    #use IE's XDomainRequest for options.cors == true
    if options.cors
      if ! ('withCredentials' of xhr) #feature detection for targeting ie
        if typeof XDomainRequest != 'undefined'
          xhr = new XDomainRequest()
        else
          xhr = null #opera < 12

    xhr.onload = ->
      success(@responseText, @statusText)

    xhr.onerror = ->
      alert('error')

    xhr.open(type, url)
    xhr.send(data)

  #------------------------------------------------------------- prototype

  fQuery:: =


    attr: ->

      #single attribute/value pairing
      if typeof arguments[0] == 'string'

        [attr, val] = arguments

        @els[0].setAttribute(attr, val)
        return @els[0]

      #object map
      else if typeof arguments[0] == 'object'
        for prop, val of arguments[0]
          @els[0].setAttribute(prop, val)
        return @els[0]

      else
        throw new Error('attr method expects two string-type arguments, or one map-type object to mimic jQuery\'s attr.')


    init: (selector)->

      #DOM Element or object literal
      if typeof selector == 'object'
        @els = [selector]
      #css selector string
      else if typeof selector == 'string'
        @els = qwery(selector)

      #immitate array access with numeric keys
      for el, i in @els
        @[i] = el

      return this


    #TODO - memoize/redefine after first feature detection
    on: (e, fn)->

      el = @els[0]

      if el.addEventListener
        el.addEventListener(e, fn, false)
      else if el.attachEvent
        el.attachEvent('on' + e, fn)
      # else
        # el['on' + e] =  fn

      return el


    off: (e, fn)->

      el = @els[0]

      if el.removeEventListener
        el.removeEventListener(e, fn, false)
      else if el.detachEvent
        el.detachEvent('on' + e, fn)

      return el


    #wrapped object calling serialize can be of two types:
    #form element ...in which case serialization is of form.elements name -> value
    #object map ...in which case serialization is of pairs key -> value
    serialize: ()->

      s = []

      #serialize form element arrays
      #or object maps
      if @els[0].nodeType
        for el in @els[0].elements
          s.push encodeURIComponent(el.name) + "=" + encodeURIComponent(el.value)
      else
        for key, val of @els[0]
          s.push key + "=" + encodeURIComponent(val)

      return s.join('&')


  fQuery::init:: = fQuery::
  scope._utils.fQuery = scope.$ = fQuery

)(_RWB)
