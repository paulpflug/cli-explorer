
hookUp = chalk = readline = null
_plugins = [
  "InlineList"
  "Input"
  "Print"
  "List"
  "Action"
  "Output"
]

module.exports = (ceInst) =>
  error = ceInst.error = (desc) => new Error "Cli-explorer: #{desc}"

  if not ceInst.onSelect? or typeof ceInst.onSelect != "function"
    throw error "no onSelect function provided"

  hookUp ?= require "hook-up"
  ceInst.chalk = chalk ?= require "chalk"
  ceInst.readline = readline ?= require "readline"

  hookUp ceInst,
    actions: ["start", "_stop", "print", "clear", "input", "action", "select"]
    catch: start: (e, ceInst) =>
      delete ceInst._done
      try
        await ceInst._stop()
      throw e
    state:
      start: "starting"
      stop: "stopping"
  
  ceInst.stdin ?= process.stdin
  ceInst.stdout ?= process.stdout

  ceInst.actions = ["select", "back", "quit"]

  ceInst.keyMap =
    select: ["return", "space"]
    back: ["backspace"]
    right: ["d", "right"]
    left: ["a", "left"]
    up: ["w", "up"]
    down: ["s", "down"]
    quit: ["q", "escape"]

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
    if ceInst.done?
      throw error "Unable to start: Instance already started"
    ceInst.done = new Promise (resolve, reject) => ceInst._done = resolve
    ceInst.state = {selection: []}

  _stop.hookIn position.end, (ceInst) =>
    if ceInst._done?
      {state} = ceInst
      ceInst._done(selection: state.selection, cursor: state.cursor)
      delete ceInst._done
      delete ceInst.done
      
  ceInst.stop = ((ceInst, ignore) => 
    {done, _stop} = ceInst
    if done?
      _stop().then => return done
    else
      unless ignore
        return Promise.reject error "Unable to stop: Instance not started."
      return Promise.resolve()
    ).bind(null, ceInst)
  
  await start(selection: ceInst.selection, cursor: ceInst.cursor)
  
  delete ceInst.selection
  delete ceInst.cursor

  return ceInst