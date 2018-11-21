module.exports = (ceInst) =>

  {action, position, print, onSelect, cleanState, start, select} = ceInst

  addAction = (actions, disabled, _action) =>
    actions[_action] = true unless disabled[_action]

  select.hookIn position.init, (state) =>
    ceInst.cleanState(state)

  select.hookIn (state, ceInst) =>
    ceInst.onSelect(state, ceInst)

  select.hookIn position.during+2, (state, ceInst) =>
    setDefaultCursor(state)
    disabled = 
      back: state.selection.length == 0
      select: state.options == false
    for _action in ceInst.disabled
      disabled[_action] = true
    if state.disabled?
      for _action in state.disabled
        disabled[_action] = true
    state.disabled = disabled
    actions = {}
    aa = state.addAction = addAction.bind(null, actions, disabled)
    for _action in ceInst.actions
      aa(_action)
    if state.actions?
      for _action in state.actions
        aa(_action)
    state.actions = actions

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
    {state} = aState
    if (opts = state.options)?
      if (cursor = aState.cursor)?
        return setNewCursor(cursor, state) if opts[cursor]
      else if aState.next or aState.prev
        keys = Object.keys(opts)
        i = keys.indexOf(state.cursor)
        if aState.prev
          return false unless state.actions.prev
          i--
        else
          return false unless state.actions.next
          i++
        state.cursor = keys[i%%keys.length]
        return true
      else
        return setDefaultCursor(state)
    else if (cursor = aState.cursor)?
      return setNewCursor(cursor, state)
    return false

   move = (aState, ceInst) =>
    return false if not (select = aState.select)? and not aState.back
    {state} = aState
    if select
      return false unless state.actions.select
      return false if (opts = state.options)? and not opts[select]?
      state.selection.push select
      delete state.cursor
    else
      return false unless state.actions.back
      state.cursor = state.selection.pop()
    await ceInst.select(state)
    return true

  action.hookIn (aState, ceInst) =>
    aState.changed ?= true
    aState.select = aState.state.cursor if aState.select == true
    if await move(aState, ceInst)
    else if setCursor(aState)
    else
      aState.changed = false

  action.hookIn position.end, ({changed, state}) =>
    print(state:state) if changed
      
  cleanState.hookIn (state) => 
    delete state.options
    delete state.type
    delete state.disabled
    delete state.actions

  start.hookIn ({selection, cursor}, ceInst) =>
    await ceInst.select((state = ceInst.state))
    if selection? and Array.isArray(selection)
      _selection = state.selection
      for _cursor,i in selection
        await action select: _cursor, changed: false, state: state
        return unless _selection[i] == _cursor
    if cursor?
      await action cursor: cursor, changed: false, state: state

  start.hookIn position.end, (sState, {print, state}) => print(state:state)