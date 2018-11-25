
isValid = (state) => state.type == "output"

module.exports = ({action, print, select, position}) =>
  identity = (key) => key

  select.hookIn position.after, (state) =>
    if isValid(state) and 
        (oldOpts = state.oldOptions) and 
        (len = Object.keys(oldOpts).length) > 1
      state.blockAction("select")
      if len == 2
        state.addAction("nextSib")
      else
        state.addAction("prevSib")
        state.addAction("nextSib")

  action.hookIn position.before, (aState) =>
    if isValid(aState.state)
      switch aState.input
        when "left" then aState.go "back"
        when "up" then aState.go "prevSib"
        when "down" then aState.go "nextSib"

  print.hookIn (pState, {error}) =>
    {state} = pState
    if isValid(state)
      pState.addKeys(back: ["←","A"])
      if (selection = state.selection).length > 0 and 
          (oldOpts = state.oldOptions) and 
          (len = (keys = Object.keys(oldOpts)).length) > 1
        i = keys.indexOf(selection[selection.length-1])
        sib = pState.sibling or identity
        pState.keysLong = {}
        if len == 2
          pState.addKeys(nextSib: ["↓","↑","S","W"])
          pState.keysLong.nextSib = sib(keys[(i-1)%%keys.length])
        else
          pState.addKeys(
            nextSib: ["↓","S"]
            prevSib: ["↑","W"]
          )
          pState.keysLong.prevSib = sib(keys[(i-1)%%keys.length])
          pState.keysLong.nextSib = sib(keys[(i+1)%%keys.length])

  
  