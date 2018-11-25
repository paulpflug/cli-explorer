
isValid = (state) => state.type == "list"
module.exports = ({action, print, select, position, chalk}) =>

  _prefix = ["   ", chalk.cyan("-> ")]

  select.hookIn position.after, (state) =>
    if isValid(state)
      state.addAction("prev")
      state.addAction("next")

  action.hookIn position.before, (aState) =>
    if isValid(aState.state)
      switch aState.input
        when "right" then aState.go "select"
        when "left" then aState.go "back"
        when "up" then aState.go "prev"
        when "down" then aState.go "next"

  print.hookIn (pState) =>
    if isValid(state = pState.state)
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


