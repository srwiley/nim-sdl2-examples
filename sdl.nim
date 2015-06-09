## More-bones SDL2 example
import sdl2, sdl2/gfx

var sdlReturn : SdlReturn = init(INIT_EVERYTHING)
assert sdlReturn == SdlSuccess

const
  h = 160
  w = 120
  sz = h*w

type pixArray = ptr array[sz*4,uint8]

proc drawPixels(pixles : pixArray, cntr : int)=
  # Two ways to do a local function, which is faster?
  let colorVal = proc (i : int): uint8 {.inline.} =
    return uint8((i*256/%(h+w-2) + cntr) mod 256)

  proc offset(i, j, k : int): int {.inline.} = return (i*h+j)*4 + k

  for i in 0..w-1:
    for j in 0..h-1:
        pixles[offset(i,j,0) ] = colorVal(i + h - j)
        pixles[offset(i,j,1)] = colorVal(i + j)
        pixles[offset(i,j,2)] = colorVal(w - i + j)

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

    sdlReturn = texture.lockTexture(nil, pnts.addr,tpitch.addr)
    assert sdlReturn == SdlSuccess

    let ppt = cast[pixArray](pnts) # This took me a while to figure out the syntax, but I am a noob.

    cntr = cntr + 5
    drawPixels(ppt, cntr)

    texture.unlockTexture()

    sdlReturn = render.copy(texture,nil,nil)
    assert sdlReturn == SdlSuccess

   # render.setDrawColor 125,0,0,255
   # var point = sdl2.point(50,50)

    #let points = point.addr
   # render.drawPoints(point.addr,1)

   #var ptsList = [point(51,51), sdl2.point(52,52), sdl2.point(53,53)]

   # serror = render.drawPoints(ptsList[0].addr,3)
   # assert serror == SdlSuccess

    render.present
    let dt = fpsman.delay
    echo("cntr ", cntr,  " dt " , dt)

