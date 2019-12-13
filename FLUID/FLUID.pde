/**
 * 
 * PixelFlow | Copyright (C) 2016 Thomas Diewald - http://thomasdiewald.com
 * 
 * A Processing/Java library for high performance GPU-Computing (GLSL).
 * MIT License: https://opensource.org/licenses/MIT
 * 
 */



import com.thomasdiewald.pixelflow.java.DwPixelFlow;
import com.thomasdiewald.pixelflow.java.fluid.DwFluid2D;

import controlP5.Accordion;
import controlP5.ControlP5;
import controlP5.Group;
import controlP5.RadioButton;
import controlP5.Toggle;
import processing.core.*;
import processing.opengl.PGraphics2D;
import processing.opengl.PJOGL;

import oscP5.*;
import netP5.*;
OscP5 oscP5;
NetAddress dest;
float myVelocity = 0.9;
FloatList prev_edavalues = new FloatList();
float suma;
float mean;


  // Fluid_CustomParticles show how to setup a completely customized particle
  // system that is interacting with the fluid simulation.
  // The particle data (positions) is stored in an OpenGL texture (GL_RGBA32F) 
  // and gets updated each frame using GLSL shaders.
  // No Data transfer (application <-> device), is required.
  //
  //
  // controls:
  //
  // LMB: add Particles + Velocity
  // MMB: add Particles
  // RMB: add Particles
  
  
  
  private class MyFluidData implements DwFluid2D.FluidData{
    
    // update() is called during the fluid-simulation update step.
    @Override
    public void update(DwFluid2D fluid) {
    
      float px, py, vx, vy, radius, vscale, temperature;
 
      radius = 15;
      vscale = 10;
      px     = width/2;
      py     = 50;
      vx     = 1 * +vscale;
      vy     = 1 *  vscale;
      radius = 40;
      temperature = 1f;
      fluid.addDensity(px, py, radius, 0.2f, 0.3f, 0.5f, 1.0f);
      fluid.addTemperature(px, py, radius, temperature);
      particles.spawn(fluid, px, py, radius, 100);
    }
  }
  
  
  int viewport_w = 1280;
  int viewport_h = 720;
  int viewport_x = 230;
  int viewport_y = 0;
  
  int gui_w = 200;
  int gui_x = 20;
  int gui_y = 20;
  
  int fluidgrid_scale = 3;
  
  DwFluid2D fluid;

  // render targets
  PGraphics2D pg_fluid;
  //texture-buffer, for adding obstacles
  //PGraphics2D pg_obstacles;
  
  // custom particle system
  MyParticleSystem particles;
  
  // some state variables for the GUI/display
  int     BACKGROUND_COLOR           = 0;
  boolean UPDATE_FLUID               = true;
  boolean DISPLAY_FLUID_TEXTURES     = false;
  boolean DISPLAY_FLUID_VECTORS      = false;
  int     DISPLAY_fluid_texture_mode = 3;
  boolean DISPLAY_PARTICLES          = true;
  
  
  public void settings() {
    size(viewport_w, viewport_h, P2D);
    smooth(4);
    PJOGL.profile = 3;
  }
  

  
  public void setup() {
    //fullScreen(2);    // If more than one screen is attached to the computer, run the 
                        // code at the full dimensions on the screen defined by the 
                        // parameter to fullScreen()
    oscP5 = new OscP5(this,12000); //listen for OSC messages on port 12000 (Wekinator default)
    dest = new NetAddress("127.0.0.1",6448); //send messages back to Wekinator on port 6448, localhost (this machine) (default)
  
    surface.setLocation(viewport_x, viewport_y);
    
    for(int i = 0; i < 10; i++){
      prev_edavalues.append(100.0);
    }
    
    // main library context
    DwPixelFlow context = new DwPixelFlow(this);
    context.print();
    context.printGL();

    // fluid simulation
    fluid = new DwFluid2D(context, viewport_w, viewport_h, fluidgrid_scale);
  
    // set some simulation parameters
    fluid.param.dissipation_density     = 0.999f;
    fluid.param.dissipation_velocity    = 0.1f;
    fluid.param.dissipation_temperature = 0.80f;
    fluid.param.vorticity               = 0.10f;
    
    // interface for adding data to the fluid simulation
    MyFluidData cb_fluid_data = new MyFluidData();
    fluid.addCallback_FluiData(cb_fluid_data);
   
    // pgraphics for fluid
    pg_fluid = (PGraphics2D) createGraphics(viewport_w, viewport_h, P2D);
    pg_fluid.smooth(4);
    pg_fluid.beginDraw();
    pg_fluid.background(BACKGROUND_COLOR);
    pg_fluid.endDraw();
    
    // custom particle object
    particles = new MyParticleSystem(context, 500 * 500);

    //createGUI();
    
    background(0);
    frameRate(60);
    
    myVelocity = 0.9;
    sendOscNames();
  }
  int j = 0;
  boolean compara = false;
  boolean sube;
  float c;
  float aux;
  int v = 0;
  boolean time_over = false;
  float final_time;
  boolean allow_osc = true;
  float initial_time = 0.0;
  String subject_name;
  boolean first_time_surpass = true;
  //This is called automatically when OSC message is received
  void oscEvent(OscMessage theOscMessage) {
   if (theOscMessage.checkAddrPattern("/wek/outputs")==true & allow_osc) {
       //if(true) { // looking for 1 control value
      float edavalue = theOscMessage.get(0).floatValue();
      prev_edavalues.remove(0);
      prev_edavalues.append(edavalue);
      j++;
      if (j > 10) {
        float s =  0;
        float r;
        for(int i = 0; i < 10; i++){
          s += prev_edavalues.get(i);
        }
        r = s/10.0;
        if (compara) {
          c = r - aux;
          if (c > 5){
            sube = true;
            v = 3;
          }
          else{
            if (c < -5){
              sube  =  false;
              v = 1;
            }
          }
        }
        aux = r;
        j = 0;
        compara = true;
      }
      float maxdif = theOscMessage.get(1).floatValue();
      float mindif = theOscMessage.get(2).floatValue();
      //initial_time = theOscMessage.get(3).floatValue();
      subject_name = theOscMessage.get(4).stringValue();
      for(int i = 0; i < 10; i++){
        suma += prev_edavalues.get(i);
      }
      mean =  suma / 10.0;
      if (mean > maxdif){
        mean = maxdif;
        fluid_displayMode(2);
        if (first_time_surpass){
          first_time_surpass = false;
          initial_time = millis();
        }
      } else {
        fluid_displayMode(v);
      } 
     
      suma = 0.0;
      if(!time_over){
        myVelocity = map(mean, mindif, maxdif, 0.0, 1.0);
        fluid.param.dissipation_velocity = myVelocity;
      }
      println("OSC message received by Processing: ");
      println("dif = ", edavalue);
      println("####################################");
   }
  }
  
  void sendOscNames() {
    OscMessage msg = new OscMessage("/wekinator/control/setOutputNames");
    msg.add("velocity");
    oscP5.send(msg, dest);
  }
  

  public void draw() {    
 
    // update simulation
    if(UPDATE_FLUID){
      fluid.update();
      particles.update(fluid);
    }
    
    // clear render target
    pg_fluid.beginDraw();
    pg_fluid.background(BACKGROUND_COLOR);
    pg_fluid.endDraw();
    
    
    // render fluid stuff
    if(DISPLAY_FLUID_TEXTURES){
      // render: density (0), temperature (1), pressure (2), velocity (3)
      fluid.renderFluidTextures(pg_fluid, DISPLAY_fluid_texture_mode);
    }
    
    if(DISPLAY_FLUID_VECTORS){
      // render: velocity vector field
      fluid.renderFluidVectors(pg_fluid, 10);
    }
    
    if( DISPLAY_PARTICLES){
      // render: particles; 0 ... points, 1 ...sprite texture, 2 ... dynamic points
      particles.render(pg_fluid, BACKGROUND_COLOR);
    }
    

    // display
    image(pg_fluid    , 0, 0);
 
    // info
    //String txt_fps = String.format(getClass().getName()+ "   [size %d/%d]   [frame %d]   [fps %6.2f]", fluid.fluid_w, fluid.fluid_h, fluid.simulation_step, frameRate);
    //surface.setTitle(txt_fps);
    
    if( time_over ) {
      // display final time as text
      textSize(18); 
      String txt_subject_name = "Well done, "+subject_name+"!";
      String txt_final_time = "Total time: "+final_time/1000+" seconds";
      //fill(0, 0, 0, 220);
      noStroke();
      //rect(10, height-50, 160, -80);
      fill(0,255,255);
      text(txt_final_time, 20, height-60);
      text(txt_subject_name, 20, height-100);
    }
  }
  
  public void fluid_resizeUp(){
    fluid.resize(width, height, fluidgrid_scale = max(1, --fluidgrid_scale));
  }
  public void fluid_resizeDown(){
    fluid.resize(width, height, ++fluidgrid_scale);
  }
  public void fluid_reset(){
    fluid.reset();
  }
  public void fluid_togglePause(){
    UPDATE_FLUID = !UPDATE_FLUID;
  }
  public void fluid_displayMode(int val){
    DISPLAY_fluid_texture_mode = val;
    DISPLAY_FLUID_TEXTURES = DISPLAY_fluid_texture_mode != -1;
  }
  public void fluid_displayVelocityVectors(int val){
    DISPLAY_FLUID_VECTORS = val != -1;
  }

  public void fluid_displayParticles(int val){
    DISPLAY_PARTICLES = val != -1;
  }

  public void keyPressed(){
    if(keyCode == ENTER){
      print("TIME OVER");
      time_over = true;
      final_time = abs(initial_time - millis());
      allow_osc = false;
      fluid.param.dissipation_velocity = 0.1f;
      fluid_displayMode(0);
    }
  }
