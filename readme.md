
js-ko-class [![LICENSE](https://img.shields.io/github/license/tsu-complete/js-ko-class.svg)](https://github.com/tsu-complete/js-ko-class/blob/master/LICENSE)
===
[![Dependencies](https://david-dm.org/tsu-complete/js-ko-class.svg)](https://david-dm.org/tsu-complete/js-ko-class)
[![Dev Dependencies](https://david-dm.org/tsu-complete/js-ko-class/dev-status.svg)](https://david-dm.org/tsu-complete/js-ko-class#info=devDependencies)

> class binding provider for knockout

Initial concept by
[rniemeyer](https://github.com/rniemeyer)
at
[knockout-classBindingProvider](https://github.com/rniemeyer/knockout-classBindingProvider "repository")

Install
---

```sh
$ npm i --save tsu-complete/js-ko-class

# --or--

$ bower i --save tsu-complete/js-ko-class
```

Usage
---

### To extend

```coffee
ClassBindingProvider = require "ko-class"

class MyClassBindingProvider extends ClassBindingProvider

  constructor: ->
    super

    # code ...
```

### To use

#### Option 1

```coffee
ClassBindingProvider = require "ko-class"

ko.bindingProvider.instance = new ClassBindingProvider options
```

#### Option 2

```coffee
ko.bindingProvider.instance = new ko.ClassBindingProvider options
```

#### Option 3

```coffee
ko.ClassBindingProvider.use options
```

### Options

```coffee
bindings:  { }          # {Object} default bindings (see Bindings)
attribute: "data-class" # {String} default attribute name
virtual:   "class"      # {String} default virtual attribute name
fallback:  true         # {Boolean} if data-bind should be allowed
router: null            # {Function(classname,bindings)} returns binding
```

### Bindings

> object (possibly nested) of objects and functions

Function parameters

- context {Object} knockout context for the current element
- classes {Array<String>} list of classes on the current element
- bindings {Object} all bindings registered to the current provider

```coffee
bindings =
  astext: -> text: @
  title: ( context, classes, bindings ) ->
    value: @title
    enable: context.$parent.editable
  input: valueUpdate: "afterkeydown"
  list:
    items: ( context, classes, bindings ) ->
      foreach: @items
```

```jade
input(data-class="title input")

// ko class: list.items
div(data-class="astext")
// /ko
```

### API

Access the api from the created class, either store it when created
or access from `ko.bindingProvider.instance`

#### Register

> register new bindings

```coffee
provider.register(newBindings)
```

#### Bindings

> access all bindings

```coffee
provider.bindings() #= extend _bindings, newBindings
```

