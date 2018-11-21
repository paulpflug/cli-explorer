{test} = require "snapy"
cliExplorer = require "../src/cli-explorer.coffee"

class StreamMock
  write: (data) -> (@data ?= []).push data
  on: ->

options =
  first: "first"
  second: "second"
  third: "third"

test (snap) =>
  cliExplorer 
    stdout: new StreamMock
    stdin: false
    onSelect: (state, ceInst) =>
      state.type = "list"
      state.options = options
  .then ({stdout}) =>
    # list options test - should print three options and select first item
    snap obj: stdout.data.join("\n")
    return

test (snap) =>
  cliExplorer 
    stdout: new StreamMock
    stdin: false
    onSelect: (state, ceInst) =>
      state.type = "inlineList"
      state.options = options
  .then ({stdout}) =>
    # inlineList options test - should print three options and select first item
    snap obj: stdout.data.join("\n")
    return

test (snap) =>
  cliExplorer 
    stdout: new StreamMock
    stdin: false
    onSelect: (state, ceInst) =>
      state.type = "inlineList"
      state.options = options
      state.print = maxLength: 4
  .then ({stdout}) =>
    # linebreak in inlineList options test - should print three options and select first item
    snap obj: stdout.data.join("\n")
    return

test (snap) =>
  cliExplorer 
    stdout: new StreamMock
    stdin: false
    cursor: "second"
    onSelect: (state, ceInst) =>
      state.type = "list"
      state.options = options
  .then ({stdout}) =>
    # cursor test - should set cursor to second of three items
    snap obj: stdout.data.join("\n")
    return
  
test (snap) =>
  cliExplorer 
    stdout: new StreamMock
    stdin: false
    onSelect: (state, ceInst) =>
      state.print = lines: ["custom line"], question: "Question?", addUsage: "addUsage"
  .then ({stdout}) =>
    # print test - should output lines: "custom line", "Question?", "addUsage"
    snap obj: stdout.data.join("\n")
    return

test (snap) =>
  cliExplorer 
    stdout: new StreamMock
    stdin: false
    onSelect: (state, ceInst) =>
      state.disabled = ["select"]
      state.onPrint = (pState) =>
        pState.lines = ["custom lines"]
        
  .then ({stdout}) =>
    # onPrint test - should output line: "custom line"
    snap obj: stdout.data.join("\n")
    return

test (snap) =>
  cliExplorer 
    stdout: new StreamMock
    stdin: false
    selection: ["first"]
    onSelect: (state, ceInst) =>
      state.print = lines: ["["+state.selection.join(", ")+"]"]
      
  .then ({stdout}) =>
    # selection test - should output line: ["first"]
    snap obj: stdout.data.join("\n")
    return

test (snap) =>
  cliExplorer 
    stdout: new StreamMock
    stdin: false
    selection: ["first"]
    onSelect: (state, ceInst) =>
      state.options = []
      state.count ?= 0
      state.print = lines: [++state.count]
  .then ({stdout}) =>
    # invalid selection test - should output line: 1
    snap obj: stdout.data.join("\n")
    return