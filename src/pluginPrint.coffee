module.exports = ({start, print, clear, position, select, _stop}) =>
  
  getKeysString = (keysArr, join="/") => keysArr.map((k) => 
    if k.length == 1
      return k.toUpperCase()
    return k
    ).join(join)

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

  print.hookIn position.before, (pState, ceInst) =>
    if (question = pState.question)?
      {lines} = pState
      lines.push ceInst.chalk.bold(question)
      lines.push ""
    if (before = pState.before)?
      Array::push.apply(lines or pState.lines, before)

  print.hookIn position.after, (pState, ceInst) =>
    if (after = pState.after)?
      Array::push.apply((lines = pState.lines), after)
    usage = ""
    {state:{_actions}, keysLong, keys} = pState
    keysLong ?= {}
    for action, keysArr of keys
      if _actions[action] and not keysLong[action]
        usage += action+"["+getKeysString(keysArr)+"] "
    if (hasLong = Object.keys(keysLong).length > 0) or usage
      {lines} = pState unless lines?
      {chalk} = ceInst
      lines.push ""
      if hasLong
        for action,desc of keysLong
          lines.push getKeysString(keys[action])+"  "+chalk.bold(desc)
      if usage
        lines.push chalk.inverse(usage)

  print.hookIn position.end-1, ({lines}, ceInst) =>
    if lines.length > 0
      await ceInst.clear()
      ceInst._lastLines = lines.length-1
      ceInst.stdout.write lines.join("\n")+"\n"

  clear.hookIn (ceInst) =>
    if (lastLines = ceInst._lastLines) > 0
      {stdout} = ceInst
      if ceInst.debug or not stdout.isTTY
        console.log "-----------------------------"
      else
        while i++ < lastLines
          stdout.moveCursor(0, -1) if i > 1
          stdout.clearLine()
          stdout.cursorTo(0)
      ceInst._lastLines = 0

  _stop.hookIn ({clear}) => clear()

  select.hookIn (state) => 
    delete state.onPrint
    delete state.print
