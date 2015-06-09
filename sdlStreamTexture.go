package main

import (
	"fmt"
	"github.com/srwiley/go-sdl2/sdl"
	//"reflect"
	"unsafe"
)

const (
	h  = 160
	w  = 120
	sz = h * w
)

func main() {
	err := sdl.Init(sdl.INIT_EVERYTHING)
	if err != nil {
		panic(err)
	}

	window, err := sdl.CreateWindow("stream test", sdl.WINDOWPOS_UNDEFINED, sdl.WINDOWPOS_UNDEFINED,
		h*4, w*4, sdl.WINDOW_SHOWN)

	if err != nil {
		panic(err)
	}

	defer window.Destroy()
	//renderer, err := window.GetRenderer()
	//renderer.
	renderer, err := sdl.CreateRenderer(window, -1, sdl.RENDERER_ACCELERATED|sdl.RENDERER_PRESENTVSYNC)
	//sdl.Cr
	if err != nil {
		panic(err)
	}
	defer renderer.Destroy()

	texture, err := renderer.CreateTexture(sdl.PIXELFORMAT_ABGR8888, sdl.TEXTUREACCESS_STREAMING, h, w)
	if err != nil {
		panic(err)
	}
	defer texture.Destroy()

	cntr := 0

	renderer.SetDrawColor(uint8(0), uint8(255), uint8(255), uint8(255))
	renderer.Clear()

	var pPix unsafe.Pointer
	var pitch int
outerloop:
	for true {

		//d := fpsman.delay()
		for evt := sdl.PollEvent(); evt != nil; evt = sdl.PollEvent() {
			//fmt.Println("vt ", reflect.TypeOf(evt))
			//switch evt.(type) {
			switch evt := evt.(type) {
			case *sdl.QuitEvent:
				break outerloop
			case *sdl.KeyDownEvent:
				fmt.Println("kd ", evt.Keysym.Sym, " type ", evt.Type)
			}
		}
		err = texture.Lock(nil, &pPix, &pitch)
		if err != nil {
			panic(err)
		}
		cntr++
		drawPixels(pPix, cntr*5)
		texture.Unlock()
		//r := sdl.Rect{0, 0, h, w}
		err = renderer.Copy(texture, nil, nil)
		if err != nil {
			panic(err)
		}
		renderer.Present()
		//window.UpdateSurface
		//sdl.Delay(1000 / 60)
		//fmt.Println("cycles ", cntr)
	}
}

func colorVal(i, cntr int) uint8 {
	return uint8((i*256/(h+w-2) + cntr) % 256)
}
func offset(i, j, k int) int {
	return (i*h+j)*4 + k
}
func drawPixels(pPix unsafe.Pointer, cntr int) {
	//colorVal := func(i int) uint8 {
	//	return uint8((i*256/(h+w-2) + cntr) % 256)
	//}
	//offset := func(i, j, k int) int {
	//	return (i*h+j)*4 + k
	//}
	p := (*[h * w * 4]uint8)(pPix)
	for i := 0; i < h; i++ {
		for j := 0; j < w; j++ {
			p[offset(j, i, 0)] = colorVal(j+h-i, cntr)
			p[offset(j, i, 1)] = colorVal(i+j, cntr)
			p[offset(j, i, 2)] = colorVal(w-j+i, cntr)
		}
	}
}
