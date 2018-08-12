import
  sdl2

type
  MouseButton* = enum
    mbLeft   = BUTTON_LEFT,
    mbMiddle = BUTTON_MIDDLE,
    mbRight  = BUTTON_RIGHT,
    mbX1     = BUTTON_X1,
    mbX2     = BUTTON_X2,
  
  InputEventKind* = enum
    evKeyDown,
    evKeyUp,
    evMouseMotion,
    evMouseDown,
    evMouseUp,
  InputEvent* = object
    case kind*: InputEventKind
      of evKeyDown, evKeyUp:
        keysym*: KeySym
      of evMouseMotion:
        mouseMotion*: Point
      of evMouseDown, evMouseUp:
        mouseButton*: MouseButton
        mousePosition*: Point

export
  Point,
  KeySym,
  Scancode,
  Keymod,
  KMOD_CTRL,
  KMOD_SHIFT,
  KMOD_ALT,
  KMOD_GUI

var
  mousePosition: Point
  mouseButtonDown: uint32

proc handleInputEvent*(event: Event) =
  case event.kind:
    of KeyDown:
      yield InputEvent(kind: evKeyDown, keysym: event.evKeyboard.keysym)
    of KeyUp:
      yield InputEvent(kind: evKeyUp, keysym: event.evKeyboard.keysym)
    
    of MouseMotion:
      let ev = event.evMouseMotion
      let m  = (ev.xrel, ev.yrel).Point
      mousePosition = (ev.x, ev.y).Point
      yield InputEvent(kind: evMouseMotion, mouseMotion: m)
    
    of MouseButtonDown:
      let ev = event.evMouseButton
      let mb = MouseButton(ev.button)
      let p  = (ev.x, ev.y).Point
      mouseButtonDown = mouseButtonDown or (1'u32 shl mb.int)
      yield InputEvent(kind: evMouseDown, mouseButton: mb, mousePosition: p)
    of MouseButtonUp:
      let ev = event.evMouseButton
      let mb = MouseButton(ev.button)
      let p  = (ev.x, ev.y).Point
      mouseButtonDown = mouseButtonDown and not (1'u32 shl mb.int)
      yield InputEvent(kind: evMouseUp, mouseButton: mb, mousePosition: p)
    
    else: discard
