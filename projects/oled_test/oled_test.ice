// SL 2020-07

$$ -- SSD1351=1
$$ ST7789=1
$include('../common/oled.ice')

$$if not ULX3S and not ICARUS then
$$error('only tested on ULX3S and ICARUS, small changes likely required to main input/outputs for other boards')
$$end

// ------------------------- 

algorithm main(
  output! uint8 led,
  input   uint7 btn,
  output! uint1 oled_clk,
  output! uint1 oled_mosi,
  output! uint1 oled_dc,
  output! uint1 oled_resn,
  output! uint1 oled_csn,  
) {

  oledio io;
  oled   display(
    oled_clk  :> oled_clk,
    oled_mosi :> oled_mosi,
    oled_dc   :> oled_dc,
    oled_resn :> oled_resn,
    oled_csn  :> oled_csn,
    io       <:> io
  );

  uint16 frame = 0;

  led := frame[0,8];

  // maintain low (pulses high when sending)
  io.start_rect := 0;
  io.next_pixel := 0;
 
  // wait for controller to be ready  
  while (io.ready == 0) { }

$$if not SIMULATION then
  while (1) {
  
    uint16 u     = uninitialized;
    uint16 v     = uninitialized;

    io.x_start = 0;
    io.x_end   = $oled_width-1$;
    io.y_start = 0;
    io.y_end   = $oled_height-1$;
    io.start_rect = 1;
    while (io.ready == 0) { }

    v = 0;
    while (v < $oled_height$) {
      u = 0;
      while (u < $oled_width$) {
        io.color      = u[0,6] | (v[0,6]<<6) | (frame[0,6]<<12);
        io.next_pixel = 1;
        while (io.ready == 0) { } // wait ack
        u = u + 1;
      }
      v = v + 1;
    }
    
    frame = frame + 1;
   
  }
$$end

}

// ------------------------- 