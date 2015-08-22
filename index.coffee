
(( factory ) ->
  if "function" is typeof define and define.amd
    define ["knockout"], factory
  else if "undefined" isnt typeof module
    factory require "knockout"
  else
    factory window.ko
) ( ko ) ->

  ##
  # knockout base object
  # @namespace ko

  ##
  # class storage in ko object
  # @memberof ko
  # @class ClassBindingProvider
  class ko.ClassBindingProvider extends ko.bindingProvider

    ##
    # mapped object generator
    # @private
    # @memberof ko.ClassBindingProvider
    # @method _object_map
    # @param {Object} source what to map from
    # @param {Function} mapper what to map with
    # @param mapper.value item at some property in source
    # @param {String} mapper.property what is being mapped
    # @param {Object} mapper.source original source object
    # @return {Object} mapped object
    _object_map = ( source, mapper ) ->
      return source unless source

      target = { }
      for own property, value of source
        target[property] = mapper value, property, source
      return target

    ##
    # value accessor generator
    # @private
    # @memberof ko.ClassBindingProvider
    # @method _make_value_accessor
    # @param value what to make accessible
    # @return {Function} function returning value
    _make_value_accessor = ( value ) -> -> value

    # force knockut to observe members in getBindingAccessors
    if ko.version >= "3.0.0"
      do ->
        dummy = document.createElement "div"
        ko.applyBindings null, dummy
        context = ko.contextFor dummy

        minified = not ko.storedBindingContextForNode
        subscribable = (->)
        context.constructor::[if minified then "A" else "_subscribable"] =
        subscribable[if minified then "wb" else "_addNode"] = subscribable

        ko.cleanNode dummy

    ##
    # convenience wrapper for setting binding provider in ko
    # @param {Object} options what to pass the constructor
    # @return {Object} constructed binding provider
    @use: ( options ) ->
      ko.bindingProvider.instance = new ko.ClassBindingProvider options

    ##
    # setup provider settings
    # @param {Object} [options={}] fine tune controls
    # @param {Object} [options.bindings={}] default bindings
    # @param {String} [options.attribute="data-class"]
    # default attribute to look for
    # @param {String} [options.virtual="class"]
    # default virtual attribute to look for
    # @param {Boolean} [options.fallback=true] if data-bind should be allowed
    # @param {Function} [options.router] returns correct binding for class name
    # @param {String} [options.router.classname] name of class to resolve
    # @param {Object} [options.router.bindings] current object of all bindings
    constructor: ( options = {  } ) ->
      super undefined

      @_bindings = options.bindings or { }
      @_attribute = options.attribute or "data-class"
      @_virtual = new RegExp "#{options.virtual or "class"}:(.*)(?:,|$)"
      @_fallback = if options.fallback? then options.fallback else true
      @_router = options.router or ( classname, bindings ) ->
        return bindings[classname] if bindings[classname]

        for property in classname.split "."
          bindings = bindings[property]
          break unless bindings

        return bindings

      @getBindings = @getBindingsFunction false
      @getBindingAccessors = @getBindingsFunction true

    ##
    # register new bindings
    # @param {Object} bindings what to register
    register: ( bindings ) ->
      ko.utils.extend @_bindings, bindings
      undefined

    ##
    # access current bindings
    # @return {Object} bindings object
    bindings: -> @_bindings

    ##
    # find classes given some element
    # @private
    # @param {Element} what to get classes of
    # @return {String} list of classes on this node
    _classes: ( node ) ->
      if 1 is node.nodeType
        node.getAttribute @_attribute
      else if 8 is node.nodeType
        text = "#{node.nodeValue or node.text}"
        text.match(@_virtual)?[1] or ""

    ##
    # determine if an element has bindings
    # @param {Element} node what to look at
    # @return {Boolean} if node has bindings
    nodeHasBindings: ( node ) ->
      result = @_classes node
      if @_fallback
        result or= super
      return result

    ##
    # return the bindings given a node and context
    # @param accessors knockout internal syntax
    # @return {Function} bindings accessor function
    getBindingsFunction: ( accessors ) ->
      ( node, context ) ->

        result = if @_fallback then (ClassBindingProvider.__super__[\
        if accessors then "getBindingAccessors" else "getBindings"
        ] node, context) else { }

        classes = @_classes node

        if classes
          classes.replace /^(\s|\u00A0)+|(\s|\u00A0)+$/g, ""
          .replace /(\s|\u00A0)+/g, ""
          .split " "

          for classname in classes
            accessor = @_router classname, @_bindings
            if accessor
              binding = if accessor instanceof Function
              then accessor.call context.$data, context, classes, bindings
              else accessor
              if accessors
                binding = _object_map binding, _make_value_accessor
              ko.utils.extend result, binding

        return result

