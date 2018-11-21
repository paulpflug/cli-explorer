# cli-explorer

State-driven explorer for command line interfaces.

Features:
  - makes nearly no assumptions about your interface
    (only basic input ESC/RETURN/BACKSPACE/ARROWS, but can be disabled)
  - easily pluggable

### Install

```sh
npm install --save cli-explorer
```

### Usage

```js
cliExplorer = require("cli-explorer")

// cliExplorer(options:Object)
cliExplorer({
  onSelect: (state, ceInst) => {
    if (state.selection.length === 0) { // initial
      state.options = {
        true: "Yes",
        false: "No"
      }
      state.type = "inlineList"
      state.print = {question: "Is everything alright?"}
    } else {
      state.selection // ["true"] or ["false"] depending on the selection
    }
  },
}).then(async (ceInst) =>
  // started
  
  // to wait for stop
  ceInst.done.then(({selection, cursor}) => {
    // stopped
  })

  // to stop
  {selection, cursor} = await ceInst.stop()
  
  // restart
  await ceInst.start(selection: selection, cursor: cursor)
)
```

#### Options
Name | type | default | description
---:| --- | ---| ---
onSelect | Function | - | (required) cb for building the explorer
selection | Array | - | Selection for initialization
cursor | String | - | Cursor for initialization
stdin | Stream | process.stdin | Stream to listen for input
stdout | Stream | process.stdout | Stream for output
onInput | Function(key, ceInst) | - | Global input cb
onPrint | Function(printState, ceInst) | - | Global print cb
disabled | Array | [] | Globally disabled actions
plugins | Array | - | Plugins to load, absolute Path or js functions allowed

#### state
In `onSelect` you get access to `state` which you can manipulate to change the output.
```js
cliExplorer({
  onSelect: (state, ceInst) => {
    state.type // the plugin to select, see below under Plugins
    // available options
    // set to false if there are none
    state.options 
    state.print // printState, see below
    state.onInput // onInput cb only for current selection
    state.onPrint // onPrint cb only for current selection
    state.actions // Array of additional actions
    state.disabled // Array of disabled actions
  }
})
```

#### printState
Always available options. Plugins may have additional options.
```js
cliExplorer({
  onSelect: (state, ceInst) => {
    state.print = {
      lines: ["first line"], // set array of printed lines
      question: "Question?", // print a question above options
      // append additional usage
      addUsage: "someAction[z]",
      // to merge with default keymap:
      keys:
        exit: ["q"] // will result in exit[esc/q]
    }
  }
})
```

### Plugins

#### list
```js
cliExplorer({
  onSelect: (state, ceInst) => {
    state.type = "list"
    state.options = {
      first: "First",
      second: "Second"
    }
    state.print = {
      prefix: [" ",">"]
    }
  }
})
```

#### inlineList
```js
cliExplorer({
  onSelect: (state, ceInst) => {
    state.type = "inlineList"
    state.options = {
      first: "First",
      second: "Second"
    }
    state.print = {
      prefix: [" ",">"],
      postfix: [" ",">"]
      maxLength: 80 // line length
    }
  }
})
```

#### Write your own Plugins

Have a look at the source of the list / inlineList plugin, it is very easy.

## License
Copyright (c) 2018 Paul Pflugradt
Licensed under the MIT license.
