module.exports = (ceInst) =>

  {action, position, print, onSelect, start, select} = ceInst

  addAction = (actions, blocked, _action) =>
    actions[_action] = true unless blocked[_action]

  blockAction = (actions, blocked, _action) =>
    blocked[_action] = true
    actions[_action] = false

  activate = (aState, _action, arg) =>
    {state} = aState
    if state._actions[_action] and not state._blocked[_action]
      aState.action = _action
      aState.actionArg = arg

  select.hookIn position.init, (state) => 
    delete state.oldOptions
    if state.options?
      state.oldOptions = state.options
      delete state.options
    delete state.type
    delete state.actions

  select.hookIn (state, ceInst) =>
    ceInst.onSelect(state, ceInst)

  select.hookIn position.during+2, (state, ceInst) =>
    setDefaultCursor(state)
    
    disableNext = not state.options or Object.keys(state.options).length < 2
    disableBack = state.selection.length == 0
    disableSib = disableBack or not state.oldOptions or Object.keys(state.oldOptions) < 2
    state._blocked = _blocked = 
      back: disableBack
      select: state.options == false
      next: disableNext
      prev: disableNext
      nextSib: disableSib
      prevSib: disableSib

    state._actions = _actions = {}

    aa = state.addAction = addAction.bind(null, _actions, _blocked)
    ba = state.blockAction = blockAction.bind(null, _actions, _blocked)

  select.hookIn position.after+2, ({addAction}, ceInst) =>
    for _action in ceInst.actions
      addAction(_action)


  setNewCursor = (newCursor, state) =>
    if newCursor != state.cursor
      state.cursor = newCursor
      return true
    return false

  setDefaultCursor = (state) =>
    if not state.cursor and (opts = state.options)?
      return setNewCursor(Object.keys(opts)[0], state)
    return false

  setCursor = (aState) =>
    {state, action} = aState
    if (opts = state.options)?
      if (cursor = aState.cursor)?
        return setNewCursor(cursor, state) if opts[cursor]
      else if action == "next" or action == "prev"
        keys = Object.keys(opts)
        i = keys.indexOf(state.cursor)
        if aState.prev
          i--
        else
          i++
        state.cursor = keys[i%%keys.length]
        return true
      else
        return setDefaultCursor(state)
    else if (cursor = aState.cursor)?
      return setNewCursor(cursor, state)
    return false

   move = (aState, ceInst) =>
    {state, action} = aState
    if aState.action == "select"
      select = aState.actionArg or state.cursor
      return false if (opts = state.options)? and not opts[select]?
      state.selection.push select
      delete state.cursor
    else if aState.action == "back"
      state.cursor = state.selection.pop()
    else
      return false
    await ceInst.select(state)
    return true

  action.hookIn position.init, (aState) =>
    aState.go = activate.bind(null, aState)

  action.hookIn (aState, ceInst) =>
    aState.changed ?= true
    if await move(aState, ceInst)
    else if setCursor(aState)
    else
      aState.changed = false

  action.hookIn position.end, ({changed, state}) =>
    print(state:state) if changed
      
  start.hookIn ({selection, cursor}, ceInst) =>
    await ceInst.select((state = ceInst.state))
    if selection? and Array.isArray(selection)
      _selection = state.selection
      for _cursor,i in selection
        await action action: "select", actionArg: _cursor, changed: false, state: state
        return unless _selection[i] == _cursor
    if cursor?
      await action cursor: cursor, changed: false, state: state

  start.hookIn position.end, (sState, {print, state}) => print(state:state)