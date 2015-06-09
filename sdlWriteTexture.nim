## More-bones SDL2 example
import sdl2, sdl2/gfx

var sdlReturn : SdlReturn = init(INIT_EVERYTHING)
assert sdlReturn == SdlSuccess

const
  h = 80
  w = 60
  sz = h*w

type pixArray = ptr array[sz*4,uint8]


block outerloop:
  let
    window: WindowPtr = createWindow("SDL streaming texture", 100, 100, h*6, w*6, SDL_WINDOW_SHOWN )
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
    tpitch : cint
    pnts : pointer
    fpsman: FpsManager
    evt : Event = sdl2.defaultEvent

  fpsman.init
  fpsman.setFramerate(30)

  while true:
    while pollEvent(evt):
      if evt.kind == QuitEvent:
        break outerLoop
      if evt.kind == KeyDown:
        break outerLoop

    render.setDrawColor 125,0,0,255
    render.clear
    render.setDrawColor 0,255,0,255

    const lineLen : int = 150

   # var ptsList  = [ sdl2.point(50,51), sdl2.point(50,52) , sdl2.point(50,52)]
    var ptsList : array[lineLen,sdl2.Point]
    for i in 0..lineLen-1:
      ptsList[i] = sdl2.point(50+i,50+i)
    var serror : SdlReturn = render.drawPoints(ptsList[0].addr,cint(lineLen))
    render.present
    let dt = fpsman.delay
    echo( "Dt " , dt)

