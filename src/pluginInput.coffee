module.exports = ({start, stop, clear, print, input, position, stdin, select, keyMap}) =>
  if stdin
    keypress = require "keypress"

    keypress(stdin)

    actionLookup = {}

    for action, keys of keyMap
      for key in keys
        actionLookup[key] = action

    start.hookIn position.init, (sState, {input, stdout}) =>
      stdout.write('\u001b[?25l')

      stdin.on "keypress", (ch, key) =>
        input key if key?
      stdin.setRawMode?(true)
      stdin.resume()
    
    clear.hookIn =>  stdin.pause()

    print.hookIn position.end, => stdin.resume()

    input.hookIn (key, ceInst) =>
      if key.ctrl && key.name == "c"
        await ceInst._stop()
        process.emit "SIGINT"
      else 
        if (onInput = ceInst.state.onInput)?
          return unless (key = await onInput key, ceInst)
        {name, ctrl} = key
        action = actionLookup[name]
        if action?
          if action == "quit"
            ceInst._stop()
          else
            aState = state: ceInst.state
            aState.input = action
            ceInst.action(aState)
    
    select.hookIn (state) => 
      delete state.onInput