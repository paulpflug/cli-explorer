module.exports = ({action, print, select, position, chalk}) =>

  _prefix = ["   ", chalk.cyan("-> ")]

  print.hookIn (pState, {state}) =>
    {state} = pState
    if state.type == "list"
      pState.addKeys(
        back: ["A","←"]
        select: ["D","→"]
        next: ["S","↓"]
        prev: ["W","↑"]
      )
      if (opts = state.options)?
        prefix = pState.prefix or _prefix
        {lines} = pState
        for k,v of opts
          lines.push prefix[+(state.cursor==k)]+v

  action.hookIn position.before, (aState) =>
    if aState.state.type == "list"
      if aState.right
        aState.select = true
      else if aState.left
        aState.back = true
      else if aState.up
        aState.prev = true
      else if aState.down
        aState.next = true

  select.hookIn position.after, (state) =>
    if state.type == "list"
      state.addAction("prev")
      state.addAction("next")