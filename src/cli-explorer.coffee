
hookUp = chalk = readline = null
_plugins = [
  "InlineList"
  "Input"
  "Print"
  "List"
  "Action"
]

module.exports = (ceInst) =>

  if not ceInst.onSelect? or typeof ceInst.onSelect != "function"
    throw new Error "Cli-explorer: no onSelect function provided"

  hookUp ?= require "hook-up"
  ceInst.chalk = chalk ?= require "chalk"
  ceInst.readline = readline ?= require "readline"

  hookUp ceInst,
    actions: ["start", "_stop", "print", "clear", "input", "action", "cleanState", "select"]
  
  ceInst.stdin ?= process.stdin
  ceInst.stdout ?= process.stdout

  ceInst.actions = ["select", "back", "quit"]

  ceInst.keyMap =
    select: ["return", "space"]
    quit: ["esc"]
    back: ["backspace"]
    right: ["d", "right"]
    left: ["a", "left"]
    up: ["w", "up"]
    down: ["s", "down"]

  ceInst.disabled ?= []
  if not Array.isArray(ceInst.disabled)
    throw new Error "Cli-explorer: disabled option must be of type Array"

  worker = []
  for plugin in _plugins
    worker.push require("./plugin"+plugin)(ceInst)
  if (plugins = ceInst.plugins)?
    for plugin in plugins
      if typeof plugin == "function"
        worker.push plugin(ceInst)
      else
        worker.push require(plugin)(ceInst)
  await Promise.all worker

  {position, start, _stop} = ceInst
  start.hookIn position.init, (sState, ceInst) =>
    if ceInst.done
      throw new Error "Cli-explorer: Unable to start: Instance already started"
    ceInst.done = new Promise (resolve) => ceInst._done = resolve
    ceInst.state = {selection: []}

  _stop.hookIn position.end, (ceInst) =>
    if ceInst.done?
      {state} = ceInst
      ceInst._done(selection: state.selection, cursor: state.cursor)
      delete ceInst.done

  ceInst.stop = ({done, _stop}) => 
    if done?
      _stop().then => return done
    else
      Promise.reject new Error "Cli-explorer: Unable to stop: Instance not started."

  await start(selection: ceInst.selection, cursor: ceInst.cursor)
  delete ceInst.selection
  delete ceInst.cursor

  return ceInst