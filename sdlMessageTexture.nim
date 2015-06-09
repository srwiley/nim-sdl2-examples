## More-bones SDL2 example
import sdl2, sdl2/gfx

var sdlReturn : SdlReturn = init(INIT_EVERYTHING)
assert sdlReturn == SdlSuccess

const
  h = 160
  w = 120
  sz = h*w

type pixArray = ptr array[sz*4,uint8]

proc showSimpleMessage(pwindow: WindowPtr, message : cstring) : cint =
  return showSimpleMessageBox(SDL_MESSAGEBOX_INFORMATION,"Thanks for playing",message, pwindow)

proc showMessage(pwindow: WindowPtr, message : cstring): cint =
  var
    buttons = [ MessageBoxButtonData(flags : 0, buttonid  :0, text : "no" ),
                MessageBoxButtonData(flags : SDL_MESSAGEBOX_BUTTON_RETURNKEY_DEFAULT, buttonid  :1, text : "yes"),
                MessageBoxButtonData(flags : SDL_MESSAGEBOX_BUTTON_ESCAPEKEY_DEFAULT, buttonid  :2, text : "cancel")]
    colorScheme = MessageBoxColorScheme( colors : [
      MessageBoxColor( r: 180, g : 255, b : 180),
      MessageBoxColor( r:   0, g :   0, b :   0),
      MessageBoxColor( r:   0, g : 255, b : 255),
      MessageBoxColor( r:   0, g : 130, b : 255),
      MessageBoxColor( r: 255, g :   0, b :   0),
      MessageBoxColor( r:   0, g : 125, b : 125)] )
    messageBoxData = MessageBoxData( flags : SDL_MESSAGEBOX_INFORMATION, window: pwindow, title: "Alert", message: message,
      numButtons : cint(buttons.len), buttons: buttons[0].addr, colorScheme: colorScheme.addr)
    hitButton: cint
  let answer = showMessageBox(messageBoxData.addr, hitButton)
  if answer < 0 :
    return answer
  return hitButton


proc offset(i, j, k : int): int {.inline.} = return (i*h+j)*4 + k

proc colorVal(i, cntr : int): uint8 {.inline.} = return uint8((i*256/%(h+w-2) + cntr) mod 256)

proc drawPixels(pixels : pixArray, cntr : int)= # Just draws a nice pattern into the pixArray colored by cntr

   # Two ways to do a local function; is one faster?
  #let colorVal = proc (i : int): uint8 {.inline.} =
  #let colorVal = proc (i : int): uint8 {.inline.} =
  #  return uint8((i*256/%(h+w-2) + cntr) mod 256)

 # let offset = proc (i, j, k : int): int {.inline.} = return (i*h+j)*4 + k

  for i in 0..<w:
    for j in 0..<h:
        pixels[offset(i,j,0) ] = colorVal(i + h - j,cntr)
        pixels[offset(i,j,1)] = colorVal(i + j,cntr)
        pixels[offset(i,j,2)] = colorVal(w - i + j,cntr)

block outerloop:

  let
    window: WindowPtr = createWindow("SDL streaming texture", 100, 100, h*4, w*4, SDL_WINDOW_SHOWN )
    render: RendererPtr = createRenderer(window, -1, Renderer_Accelerated or Renderer_PresentVsync )
    texture: TexturePtr = createTexture(render, SDL_PIXELFORMAT_ARGB8888, SDL_TEXTUREACCESS_STREAMING, h, w)
  defer:
    destroy texture
    destroy render
    destroy window

  assert window != nil
  assert render != nil
  assert texture != nil

  var
    cntr: int
    delay : int
    tpitch : cint
    pnts : pointer
    evt : Event = sdl2.defaultEvent

  while true:
    while pollEvent(evt):
      if evt.kind == QuitEvent:
        break outerLoop
      if evt.kind == KeyDown:
        var cycleStr = "Cycles:" & $cntr & "\nDelay:" & $delay & "\nStop?"
        let result = showMessage(window, cycleStr)
        if result == 1 :
          discard showSimpleMessage(window, "Final cycles:" & $cntr)
          break outerLoop

    sdlReturn = texture.lockTexture(nil, pnts.addr, tpitch.addr)
    assert sdlReturn == SdlSuccess

    inc(cntr)
    drawPixels(cast[pixArray](pnts), cntr*5)

    texture.unlockTexture()

    sdlReturn = render.copy(texture,nil,nil)
    assert sdlReturn == SdlSuccess

    render.present
    # delay(1000/%60)
   # echo "cntr:",  cntr
