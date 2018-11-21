module.exports = ({start, print, clear, position, cleanState, _stop}) =>
  
  addKeys = (keys, add) =>
    for action, arr of add
      if keys[action]?
        Array::push.apply(keys[action],arr)
      else
        keys[action] = arr.slice()

  print.hookIn position.init, (pState, ceInst) =>
    if (tmp = pState.state.print)? and Object::toString.call(tmp) == "[object Object]"
      Object.assign(pState, tmp)
    pState.lines ?= []
    pState.addKeys = addKeys.bind(null, pState.keys ?= {})
    pState.addKeys(ceInst.keyMap)
    if (onPrint = pState.state.onPrint)?
      await onPrint(pState, ceInst)
    if (onPrint = ceInst.onPrint)?
      await onPrint(pState, ceInst)


  print.hookIn position.before, (pState, ceInst) =>
    if (question = pState.question)?
      {lines} = pState
      lines.push ceInst.chalk.bold(question)
      lines.push ""

  print.hookIn position.after, (pState, ceInst) =>
    usage = ""
    {state:{actions}} = pState
    for action, keys of pState.keys
      if actions[action]
        usage += action+"["+keys.join("/")+"] "
    if (addUsage = pState.addUsage)?
      usage += addUsage 
    if usage
      {lines} = pState
      lines.push ""
      lines.push ceInst.chalk.inverse(usage)

  print.hookIn position.end, ({lines}, ceInst) =>
    if lines.length > 0
      await ceInst.clear()
      ceInst._lastLines = lines.length
      ceInst.stdout.write lines.join("\n")

  clear.hookIn (ceInst) =>
    if (lastLines = ceInst._lastLines) > 0
      {stdout, readline} = ceInst
      readline.moveCursor(stdout, 0, -lastLines)
      readline.clearScreenDown(stdout)
      ceInst._lastLines = 0

  _stop.hookIn ({clear}) => clear()

  cleanState.hookIn (state) => 
    delete state.onPrint
    delete state.print
