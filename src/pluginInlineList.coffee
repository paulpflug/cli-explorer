module.exports = ({action, print, select, position, chalk}) =>

  _prefix = [" ", chalk.underline(">")]
  _postfix = [" ",chalk.underline("<")]

  print.hookIn (pState, {chalk}) =>
    {state} = pState
    if state.type == "inlineList"
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

  action.hookIn position.before, (aState) =>
    if aState.state.type == "inlineList"
      if aState.right
        aState.next = true
      else if aState.left
        aState.prev = true

  select.hookIn position.after, (state) =>
    if state.type == "inlineList"
      state.addAction("prev")
      state.addAction("next")