isValid = (state) => state.type == "inlineList"

module.exports = ({action, print, select, position, chalk}) =>

  _prefix = [" ", chalk.underline(">")]
  _postfix = [" ",chalk.underline("<")]

  select.hookIn position.after, (state) =>
    if isValid(state)
      state.addAction("prev")
      state.addAction("next")

  action.hookIn position.before, (aState) =>
    if isValid(aState.state)
      switch aState.input
        when "right" then aState.go "next"
        when "left" then aState.go "prev"

  print.hookIn (pState, {chalk}) =>
    {state} = pState
    if isValid(state = pState.state)
      pState.addKeys(
        prev: ["A","←"]
        next: ["D","→"]
      )
      if (opts = state.options)?
        prefix = pState.prefix or _prefix
        postfix =  pState.postfix or _postfix
        maxLength = pState.maxLength or 80
        string = ""
        {lines} = pState
        for k,v of opts
          if state.cursor == k
            tmp = prefix[1]+chalk.underline(v)+postfix[1]
          else
            tmp = prefix[0]+v+postfix[0]
          if (tmp2 = string+tmp).length < maxLength
            string = tmp2
          else
            if string
              lines.push string
              tmp = "⤷ "+tmp
            string = tmp
        lines.push string