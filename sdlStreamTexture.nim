## More-bones SDL2 example
import sdl2, sdl2/gfx

var sdlReturn : SdlReturn = init(INIT_EVERYTHING)
assert sdlReturn == SdlSuccess

const
  h = 160
  w = 120
  sz = h*w

type pixArray = ptr array[sz*4,uint8]

proc drawPixels(pixels : pixArray, cntr : int)= # Just draws a nice pattern into the pixArray colored by cntr

   # Two ways to do a local function, which is faster?
  let colorVal = proc (i : int): uint8 {.inline.} =
    return uint8((i*256/%(h+w-2) + cntr) mod 256)

  proc offset(i, j, k : int): int {.inline.} = return (i*h+j)*4 + k

  for i in 0..w-1:
    for j in 0..h-1:
        pixels[offset(i,j,0) ] = colorVal(i + h - j)
        pixels[offset(i,j,1)] = colorVal(i + j)
        pixels[offset(i,j,2)] = colorVal(w - i + j)

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

    sdlReturn = texture.lockTexture(nil, pnts.addr, tpitch.addr)
    assert sdlReturn == SdlSuccess

    cntr = cntr + 5
    drawPixels(cast[pixArray](pnts), cntr)

    texture.unlockTexture()

    sdlReturn = render.copy(texture,nil,nil)
    assert sdlReturn == SdlSuccess

    render.present
    let dt = fpsman.delay
    echo("cntr ", cntr,  " dt " , dt)
