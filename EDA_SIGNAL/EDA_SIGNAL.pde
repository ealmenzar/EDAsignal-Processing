// rogzam@gmail.com //Roger//                                                                                           // LIBRARIES                                                                                          
import grafica.*;                                                                          // Import grafica library for.. GUI. 
import processing.serial.*;                                                                // Import serial library to select the port.
import controlP5.*;                                                                        // Import controlP5 library for GUI objects.
import javax.swing.*;                                                                      // Import java swing abstract window toolkit for pop-up windows.
import java.io.FileWriter;                                                                 // Import file writer to append file.
import java.io.BufferedWriter;                                                             // Import bffered file writer.
import java.util.Date;                                                                     // Import java date utility.
import java.text.DateFormat;                                                               // Import java date format.
import java.text.SimpleDateFormat;                                                         // Import simple date format, apparently. 
import java.math.*;
import hypermedia.net.*;                                                                   // Import UDP library
import oscP5.*;
import netP5.*;

ControlP5 cp5;                                                                             // as cp5
UDP udp;                                                                                   // Define the UDP object
                                                                                           // PLOTS                                                                                           
OscP5 oscP5;
NetAddress dest;

public GPlot ecg_plot;                                                                     // Create a plot for the ECG data.
public GPlot eda_plot;                                                                     // Create a plot for the EDA data.
public GPlot combined_plot;                                                                // Create a plot for the ECG + EDA data.                                   
GPointsArray points_ecg;                                                                   // Create a new array to store the ECG data. 
GPointsArray points_eda;                                                                   // Create a new array to store the EDA data.
int pSize = 1500;                                                                          // Total Size of the buffer (ECG).
int combined_ylim;                                                                         // Variable to store the zoom limit of the combined plot on Y axis. 
int ecg_ylim;                                                                              // Variable to store the zoom limit of the ecg plot on Y axis. 
int eda_ylim;                                                                              // Variable to store the zoom limit of the ecg plot on Y axis. 
int combined_ylim_value;                                                                   // Variable to store the value of the limit slider of the combined plot on Y axis. 
int ecg_ylim_value;                                                                        // Variable to store the value of the limit slider of the ecg plot on Y axis. 
int eda_ylim_value;                                                                        // Variable to store the value of the limit slider of the eda plot on Y axis. 
int npoints_ecg = pSize;                                                                   // ECG buffer size.
int npoints_eda = pSize;                                                                   // EDA buffer size.
float combined_cleaner;                                                                    // Holds the value of the X position of the index array (swiping old data in plot).
float ecg_cleaner;                                                                         // Holds the value of the X position of the index array (swiping old data in ecg plot).
float eda_cleaner;                                                                         // Holds the value of the X position of the index array (swiping old data in eda plot).
int points = 150;                                                                          // How many points will be stored in the array (place holder for real data)
boolean start_plot = false;                                                                // Conditional Variable to start and stop the plot.

                                                                                           // PORTS/SERIAL
ScrollableList port_list;                                                                  // Create a cp5 scrollable list to show the ports.                               
Serial myPort;                                                                             // Serial port.                             
String port_name;                                                                          // String to store the port in use.
char inString = '\0';                                                                      // To receive the bytes from the packet

                                                                                           // FONTS
PFont font_list;                                                                           // For lists.
PFont font_title;                                                                          // For titles.
PFont font_subtitle;                                                                       // For subtitles.                                                                    
PFont font_text;                                                                           // For text (subject data).
PFont font_button ;                                                                        // For buttons.
PFont font_values;                                                                         // For RR & HR live values.
PFont font_text_bold;                                                                      // For text (subject data titles).

                                                                                           // SUBJECT INFO
String subject_name = "---";                                                         // Name
String subject_age = "---";                                                           // Age
String subject_gender = "---";                                                        // Gender
String subject_code = "---";                                                 // Code
String dyad_code = "---";                                                            // Dyad
String currrent_date = "---";                                                        // Date
String current_time = "---";                                                         // Start time
String session_time = "---";                                                    // Recording time
String subject_phone = "---";
String subject_email = "---";

String clock_reference;
boolean clock_reference_boolean = false;
                                                                                           // SESSION COUNTER
int counter_millis;
int counter_seconds;
int counter_minutes;
int counter_hours;
//int start_time;
boolean counter_starts;
                                                                                           // BUTTONS
Button exit_button;                                                                        // To exit the program.
Button record_button;                                                                      // To log the data.
Button stop_button;                                                                        // To stop the data.
Button info_button;

                                                                                           // LOGGING
boolean log_data = false;                                                                  // Variable to check whether to record the data or not
FileWriter output;                                                                         // In-built writer class object to write the data to file
JFileChooser jFileChooser;                                                                 // Helps to choose particular folder to save the file
Date date;                                                                                 // To record the date.                              
BufferedWriter bufferedWriter;                                                             // Writes text to a character-output system.
DateFormat dateFormat;                                                                     // To format the date related values 

                                                                                           // PACKET VALIDATION
private static final int CESState_Init = 0;                                                // State.
private static final int CESState_SOF1_Found = 1;
private static final int CESState_SOF2_Found = 2;
private static final int CESState_PktLen_Found = 3;                                        // Lenght of package.
private static final int CES_CMDIF_PKT_START_1 = 0x0A;                                     // First start signal.
private static final int CES_CMDIF_PKT_START_2 = 0xFA;                                     // Second start signal.
private static final int CES_CMDIF_PKT_STOP = 0x0B;                                        // Stop signal.
private static final int CES_CMDIF_IND_LEN = 2;                                            // Index.
private static final int CES_CMDIF_IND_LEN_MSB = 3;
private static final int CES_CMDIF_IND_PKTTYPE = 4;
private static int CES_CMDIF_PKT_OVERHEAD = 5;
                                                                                           // PACKET RELATED VARIABLES
int ecs_rx_state = 0;                                                                      // To check the state of the packet
int CES_Pkt_Len;                                                                           // To store the Packet Length Deatils
int CES_Pkt_Pos_Counter, CES_Data_Counter;                                                 // Packet and data counter
int CES_Pkt_PktType;                                                                       // To store the Packet Type

char CES_Pkt_Data_Counter[] = new char[1000];                                              // Buffer to store the data from the packet
char ces_pkt_ecg_bytes[] = new char[4];                                                    // Buffer to hold ECG data
char ces_pkt_rtor_bytes[] = new char[4];                                                   // Buffer to hold RtoR data
char ces_pkt_hr_bytes[] = new char[4];                                                     // Buffer to hold HR data
char ces_pkt_eda_bytes[] = new char[4];                                                    // Buffer to hold HR data

int arrayIndex = 0;                                                                        // Increment Variable for the buffer
float time = 0;                                                                            // X axis increment variable

float[] ecg_data = new float[pSize];                                                       // Buffers  data.
float[] eda_data = new float[pSize];

                                                                                           // PRINTABLE VARIABLES                                                                                         
double ecg_value;                                                                          // Stores the current ecg value.
double eda_value;                                                                          // Stores the current EDA value.
double rtor_value;                                                                         // Stores the current RR value.
double hr_value;                                                                           // Stores the current HR value.
String rtor_value_str;                                                                     // Stores the current RR value on a string.
String hr_value_str;                                                                       // Stores the current HR value on a string.
String ecg_value_str;                                                                     // Stores the current RR value on a string.
String eda_value_str;                                                                       // Stores the current HR value on a string.

                                                                                           // COLORS
color color_gray = color(180);
color color_white = color(255);
color color_blue_light = color(120, 160, 200);
color color_blue_dark = color(120, 160, 225);
color color_red_light = color(255, 100, 120);
color color_red_dark = color(235, 100, 120);
color color_green_light = color(160, 200, 120);
color color_green_dark = color(160, 225, 120);                                                                                         
                                                                                           // OTHER VARIABLES                                                                                         
String title = "MT_Device";                                                                   // Title variable.
//////////////////////////////////////////////////////
int t_now = 0;
int prev_t = 0;
float dif = 0.0;
float difm = 0.0;
float maxdif = 55.0;
float mindif  = 0.0;
float prev_eda_value = 0.0;
int t = 0;
float baseline = 0.0;
boolean first_t = true;
float sum = 0.0;
int siz = 0;
boolean measure_time = true;
int initial_time = 0;
//////////////////////////////////////////////////////*ç*
public void setup() {  
  oscP5 = new OscP5(this,9000);
  //dest = new NetAddress("127.0.0.1",6448);
  dest = new NetAddress("127.0.0.1",12000);
  
  udp = new UDP( this, 8888);
  udp.listen( true );

  clear();                                                                                 // Clear everything up.
  size(1220, 680);                                                                         // Set the size of the window.
  combined_ylim = 0;                                                                       // Set the default Y limit on the combined plot.
  ecg_ylim = 0;                                                                            // Set the default Y limit on the ecg plot.
  eda_ylim = 0;                                                                            // Set the default Y limit on the eda plot.

  font_title = loadFont("Verdana-Italic-26.vlw");                                          // Load font from data folder.   
  font_subtitle = loadFont("Verdana-16.vlw");    
  font_list = loadFont("Verdana-Italic-10.vlw");                                                 
  font_text = loadFont("Verdana-11.vlw");
  font_text_bold = loadFont("Verdana-Bold-11.vlw");
  font_button = loadFont("Verdana-10.vlw");   
  font_values = loadFont("Verdana-40.vlw");

  surface.setTitle(title);                                                                 // Set the window title.

  points_ecg = new GPointsArray(npoints_ecg);                                              // Fill the ecg array. 
  points_eda = new GPointsArray(npoints_eda);                                              // Fill the eda array. 

  cp5 = new ControlP5(this);           

  exit_button = cp5.addButton("   Exit   ")                                               // Create exit button. 
    .setPosition(1026, 540)
    .setSize(124, 40)
    .setFont(font_button)
    .setColorBackground(color_gray)
    .setColorForeground(color_red_light)
    .setColorActive(color_red_dark)     
    .setColorValue(color_white)
    .activateBy(ControlP5.RELEASE);
  ;

  info_button = cp5.addButton("   add/edit info   ")                                      // Create an edit info button. 
    .setPosition(900, 540)
    .setSize(124, 40)
    .setFont(font_button)
    .setColorBackground(color_gray)
    .setColorForeground(color_green_light)
    .setColorActive(color_green_dark)     
    .setColorValue(color_white)
    .activateBy(ControlP5.RELEASE);
  ;  

  record_button = cp5.addButton("   Rec   ")                                             // Create record button. 
    .setPosition(900, 122)
    .setSize(124, 40)
    .setFont(font_button)
    .setColorBackground(color_gray)
    .setColorForeground(color_green_light)
    .setColorActive(color_green_dark)     
    .setColorValue(color_white)
    .activateBy(ControlP5.RELEASE);
  ;
  stop_button = cp5.addButton("   Stop   ")                                                 // Create stop button. 
    .setPosition(1026, 122)
    .setSize(124, 40)
    .setFont(font_button)
    .setColorBackground(color_gray)
    .setColorForeground(color_red_light)
    .setColorActive(color_red_dark)     
    .setColorValue(color_white)
    .activateBy(ControlP5.RELEASE);
  ;     
  port_list = cp5.addScrollableList("com_list")                                            // Create port selection scrollable list/dropdown menu. 
    .setPosition(900, 80)
    .setSize(250, 500)
    .setItemHeight(40)
    .setBarHeight(40)
    .setFont(font_list)
    .setColorBackground(color_gray)
    .setColorForeground(color_blue_light)
    .setColorActive(color_blue_dark)
    .setColorValue(color_white)
    .setType(ScrollableList.DROPDOWN)
    .setOpen(false)
    .setCaptionLabel("   Select port:   ")
    ;

  port_name = Serial.list()[0];                                                            // Set port 0 as default.
  myPort = new Serial(this, port_name, 115200);                                            // Update port name.

  combined_plot = new GPlot(this);                                                         // Set-up combined plot.
  combined_plot.setDim(780, 300);                                                           // Set plot size.
  combined_plot.setPos(0, 40);                                                              // Set position of the plot.
  combined_plot.setPoints(points_ecg);                                                     // Indicate what's going to be plotted.
  combined_plot.setLineColor(color_green_light);                                           // Set color line.
  combined_plot.setLineWidth(2);                                                           // Set color width.
  combined_plot.addLayer("layer 1", points_eda);                                           // Add second layer to the plot.
  combined_plot.setLineWidth(2);                                                           // Set color width.  
  combined_plot.getLayer("layer 1").setLineColor(color_red_light);                         // Set color of second layer.

  eda_plot = new GPlot(this);                                                              // Set-up eda plot.
  eda_plot.setDim(352, 150);                                                                // Set plot size.
  eda_plot.setPos(426, 387);                                                                // Set position of the plot.
  eda_plot.setPoints(points_eda);                                                          // Indicate what's going to be plotted.
  eda_plot.setLineColor(color_red_light);                                                  // Set color line.
  eda_plot.setLineWidth(1);                                                                // Set color width.

  ecg_plot = new GPlot(this);                                                              // Set-up ecg plot.
  ecg_plot.setDim(352, 150);                                                                // Set plot size.
  ecg_plot.setPos(0, 387);                                                                  // Set position of the plot.
  ecg_plot.setPoints(points_ecg);                                                          // Indicate what's going to be plotted.
  ecg_plot.setLineColor(color_green_light);                                                // Set color line.
  ecg_plot.setLineWidth(1);                                                                // Set color width.

  cp5.addSlider("combined_ylim_value")                                                     // Adds a zoom slider controller to the combined plot.
    .setPosition (870, 76)
    .setSize(5, 310)
    .setRange((combined_ylim + 7500), (combined_ylim - 7500))
    .setValue(combined_ylim)
    .setNumberOfTickMarks(7)
    .setSliderMode(Slider.FLEXIBLE)
    .setColorForeground(color_gray)
    .setColorTickMark(color_gray)
    .setColorBackground(color_white)
    .setLabelVisible(false)
    ;

  for (int i=0; i<pSize; i++) {                                                             // Fill the arrays with zeros.
    ecg_data[i] = 0;
    eda_data[i] = 0;
  }
  
  time = 0;

  counter_millis = 00 ;
  counter_seconds = 00 ;
  counter_minutes = 00;
  counter_hours = 00;
  counter_starts = false;
}

public void draw() {                                                                       // DRAW

  background(255);                                                                         // Set background color.

  if (port_list.isMouseOver()) {
    port_list.clear();                                                                      // Update the port list.
    for (int i=0; i<Serial.list().length; i++) {                                              // Go through each one of the available ports.
      port_list.addItem(Serial.list()[i], i);                                               // Add the items in the list.
    }
  }

  if ( myPort.available() > 0) {                                                           // Read incoming data from serial port.
    println(myPort.readStringUntil('\n'));                                                 // Read until new input.
    delay(100);
  }
  
  points_ecg = new GPointsArray(npoints_ecg);                                              // Link the ecg data array to the new set of data points. 
  points_eda = new GPointsArray(npoints_eda);                                                 


  if (start_plot) {                                                                         // If the plot switch is on.
    for (int i=0; i<npoints_ecg; i++) {                                                      // Add the points to the ecg array.
      points_ecg.add(i, ecg_data[i]);
    }
    for (int i=0; i<npoints_eda; i++) {                                                      // Add the points to the eda array.
      points_eda.add(i, eda_data[i]);
    }
  }

  if (start_plot == false) {                                                               // If the plot switch is off.
    rtor_value_str = "----";                                                               // Printed rtor is not zero but dashes.
    hr_value_str = "----";                                                                 // Printed hr is not zero but dashes.
    ecg_value_str = "----";                                                               // Printed rtor is not zero but dashes.
    eda_value_str = "----";                                                                 // Printed hr is not zero but dashes.
    
  } else {
    rtor_value_str = str(round((float)rtor_value));                                        // Print the value.
    hr_value_str = str(round((float)hr_value));
    ecg_value_str = str(round((float)ecg_value));                                        // Print the value.
    eda_value_str = str(round((float)eda_value));
  }
  
  if (start_plot) {                                                                         // If te plot switch is on.
    combined_cleaner = map(arrayIndex, 0, 1500, 70, 850);                                      // The X position of the graph cleaner is the array index of the points.
    ecg_cleaner = map (arrayIndex, 0, 1500, 72, 425);
    eda_cleaner = map (arrayIndex, 0, 1500, 497, 850);
  } else {
    combined_cleaner = 76;                                                                 // Otherwise the X position is just on the side of the graph.
    ecg_cleaner = 74;       
    eda_cleaner = 500;
  }

  combined_plot.beginDraw();                                                               // Start drawing combined plot.
  combined_plot.drawBackground();
  combined_plot.setYLim(-12500 - combined_ylim_value, 5000 + combined_ylim_value);
  combined_plot.setXLim(1, 1499);
  combined_plot.drawBox();
  combined_plot.drawGridLines(2);
  combined_plot.drawLines();  
  combined_plot.setPoints(points_ecg);
  combined_plot.getLayer("layer 1").setPoints(points_eda);                                 // Set color of second layer.
  combined_plot.endDraw();                                                                 // End drawing.

  ecg_plot.beginDraw();                                                                    // Start drawing ecg plot.
  ecg_plot.drawBackground();
  //ecg_plot.setYLim(-12500 - ecg_ylim_value, 5000 + ecg_ylim_value);                      // Comment for auto scale
  ecg_plot.setXLim(1, 1499);
  ecg_plot.drawBox();
  ecg_plot.drawGridLines(1);
  ecg_plot.drawLines();
  ecg_plot.setPoints(points_ecg);
  ecg_plot.endDraw();                                                                      // End drawing.

  eda_plot.beginDraw();                                                                    // Start drawing eda plot.
  eda_plot.drawBackground();
  eda_plot.setXLim(1, 1499);
  eda_plot.drawBox();
  eda_plot.drawGridLines(1);  
  eda_plot.drawTitle();
  eda_plot.drawLines();
  eda_plot.setPoints(points_eda);
  eda_plot.endDraw();                                                                      // End drawing.

  fill(color_gray);                                                                        // Draw rectangle for the info area
  strokeWeight(0);
  rect (900, 205, 250, 333);

  stroke(color_gray, 50);                                                                   // Draw cleaning line for combined 
  strokeWeight(12);
  strokeCap(SQUARE);
  line(combined_cleaner, 80, combined_cleaner, 380);
  strokeWeight(6);
  line(ecg_cleaner, 427, ecg_cleaner, 577);
  line(eda_cleaner, 427, eda_cleaner, 577);

  fill(color_gray);                                                                        // Draw subtitles.
  textFont(font_subtitle);
  textAlign(LEFT);
  text("ECG + EDA", 70, 70);                                                              // Combined plot. 
  text("SET-UP", 900, 70);
  text("INFO", 900, 195); 
  text("ECG", 70, 415);                                                                   // ECG plot.
  text("EDA", 498, 415);                                                                  // EDA plot.

  fill(color_white);                                                                       // Draw values HR & RR values.
  textFont(font_values);
  textAlign(CENTER);
  text(rtor_value_str, 965, 253);                                                          // R to R interval value.
  text(hr_value_str, 1080, 253);                                                           // HR value.
  text (ecg_value_str, 965, 312);
  text (eda_value_str, 1080, 312);
  textFont(font_button);
  text("RR interval (ms)", 965, 268);                                                      // R to R legend.
  text("Heart rate (BPM)", 1080, 268);                                                     // HR legend
  text("ECG (Raw)", 965, 327);                                                      // R to R legend.
  text("EDA (Raw)", 1080, 327);                                                     // HR legend

  // Info titles
  fill(color_white);
  textFont (font_text_bold);
  textAlign(LEFT);
  text("Name: \nAge: \nGender: \nSubject Code: \nDyad code: \nDate:  \nSync signal: \nRecording time: \n\nInfo logged \nRecording data \nSync clock", 915, 351);

  // Info variables
  fill(color_white);
  textFont (font_text);
  textAlign(RIGHT);
  text(subject_name + "\n" + subject_age + "\n" + subject_gender + "\n" + subject_code + "\n" + dyad_code + "\n"
    + day() + "/" + month() + "/" + year() +  "\n" + clock_reference + "\n"
    + (nf(counter_hours, 2)) +  ":" + (nf(counter_minutes, 2)) +   ":"  + (nf(counter_seconds, 2)) + ":" + (nf(counter_millis, 1)), 1135, 351);

  fill(color_gray);                                                                        // Draw footnote.
  textFont(font_text);
  textAlign(CENTER);
  text("Physiological correlates of decision-making in social emergent behaviours,"+
    "Designing and prototyping a low-cost bio-signal monitoring tool for the "+
    "research environment.\n Universitat Pompeu Fabra, Master's degree in "+
    "Cognitive System and Interactive Media, Barcelona - 2018.", width/2, 620);

  if (counter_starts) {
    if (int(millis()/100)  % 10 != counter_millis) {
      counter_millis++;
    }
    if (counter_millis >= 10) {
      counter_millis -= 10;
      counter_seconds++;
    }
    if (counter_seconds >= 60) {
      counter_seconds -= 60;
      counter_minutes ++;
    }
    if (counter_minutes >= 60) {
      counter_minutes -= 60;
      counter_hours++;
    }
  }
  if (dyad_code != "---"){
    fill (color_green_light);
    ellipse(1128, 485, 10, 10);
  } else {
    fill (color_red_light);
    ellipse(1128, 485, 10, 10);
  }
  if (log_data == true){
    fill (color_green_light);
    ellipse(1128, 500, 10, 10);
    if (first_t) {
      t = millis();
      first_t = false;
    } 
    t_now = millis() - t;
    if (t_now <= 30000){    // Baseline
      //println("baseline");
      sum += (float)eda_value;
      siz += 1;
      baseline = sum/siz;
    }
    /*if (t_now > 10000 && t_now < 20000){    // Max y Min
      println("max min");
      dif = abs((float)eda_value - baseline);
      if (dif > maxdif) maxdif = dif;
      if (dif < mindif) mindif = dif;
    }*/
    if (t_now > 30000){    // Running *ç*
      if(measure_time){
        print("Baseline = ", baseline);
        initial_time = millis();
        measure_time = false;
      }
      //difm = abs((float)eda_value - baseline);  // measuring the max dif
      //if (difm > maxdif) maxdif = difm;
      //if (difm < mindif) mindif = difm;
      OscMessage msg = new OscMessage("/wek/outputs");
      dif = abs((float)eda_value - baseline);
      msg.add((float)dif);
      msg.add((float)maxdif);
      msg.add((float)mindif);
      msg.add((float)initial_time);
      msg.add((String)subject_name);
      oscP5.send(msg, dest);
      //sendOsc();
      /*if (abs(prev_t - t_now) > 2000) {
        println("Baseline: "+baseline);
        println("Dif: "+dif);
      }*/
      prev_t = t_now;
    }
    //println(eda_value); //////////////////////////////////////////
  } else {
    fill (color_red_light);
    ellipse(1128, 500, 10, 10);
  } 
  if (clock_reference_boolean){
    fill (color_green_light);
    ellipse(1128, 515, 10, 10);
  } else {
    fill (color_red_light);
    ellipse(1128, 515, 10, 10);
  }
}

void keyPressed(){
  if(keyCode == ENTER){
    println("maxdif = ", maxdif);
    println("minxdif = ", mindif);
  }
}

void sendOsc() {
  //OscMessage msg = new OscMessage("/wek/inputs");  // Wekinator
  OscMessage msg = new OscMessage("/wek/outputs");
  msg.add((float)dif);
  msg.add((float)maxdif);
  msg.add((float)mindif);
  //msg.add((float)by);
  oscP5.send(msg, dest);
}

public void controlEvent(ControlEvent theEvent) {                                         // EVENTS/BUTTONS

  if (theEvent.isController() && port_list.isMouseOver()) {                               // If the port button is clicked.
    myPort.clear();                                                                       // Delete the current port name
    myPort.stop();                                                                        // Stop the current port 
    try {
      port_name = Serial.list()[int(theEvent.getController().getValue())];                // Port name is set to the selected port in the dropDown
      myPort = new Serial(this, port_name, 115200);                                       // Create a new connection.
      println("Serial index set to: " + port_name + 
        "(" + theEvent.getController().getValue()+")");
      start_plot = true;
      delay(50);
    } 
    catch (Exception e) {
      JOptionPane.showMessageDialog(null, "Sorry, \nThat port seems to be unavailable.", 
        "Nope", JOptionPane.INFORMATION_MESSAGE);
    }
  }

  if (theEvent.isController() && record_button.isMouseOver()) {
    if (start_plot == false) {
      JOptionPane.showMessageDialog(null,"You need to get some incoming data first! ","Nope",JOptionPane.INFORMATION_MESSAGE);
    } else {
      int record_dialogue = JOptionPane.showConfirmDialog                                     // Prepare the pop-up dialog.
      (null, "Have you already logged the subject info?");
     
      if (record_dialogue == JOptionPane.YES_OPTION) {
        try {
          jFileChooser = new JFileChooser();                                                    // Saving window pops-up. 
          jFileChooser.setSelectedFile(new File(subject_code+".csv"));
          jFileChooser.showSaveDialog(null);
          String filePath = jFileChooser.getSelectedFile()+"";
          
          if ((filePath.equals("log.txt"))||(filePath.equals("null"))) {
            } else {
              log_data = true;
              counter_starts = true;
              date = new Date();  
              output = new FileWriter(jFileChooser.getSelectedFile(), true);
              bufferedWriter = new BufferedWriter(output);
              delay(50);
              bufferedWriter.write("clk,tst,eda,ibi,ecg,bpm,dyc,sjc,nam,gen,age,tel,mai");         // Prints the headers of the columns on the file.
              bufferedWriter.newLine();
              bufferedWriter.write( clock_reference + "," + dateFormat.format(date) + ","
              + eda_value + "," + rtor_value + "," + ecg_value + "," + hr_value + ","
              + dyad_code + "," + subject_code + "," + subject_name + "," + subject_gender + ","
              + subject_age + "," + subject_phone + "," + subject_email);                          // Prints the headers of the columns on the file.
              bufferedWriter.newLine();
            }
        } catch(Exception e){
          println("File Not Found");
        }
      }
      
      if (record_dialogue == JOptionPane.NO_OPTION){
        subject_name = JOptionPane.showInputDialog ("Please the subject's name", subject_name);                 // Ask for name 
        subject_age = (JOptionPane.showInputDialog ("Please type the subject's age", subject_age) + " y/o");    // Age
        subject_gender = JOptionPane.showInputDialog ("Please type the subject's gender", subject_gender);      // Gender
        subject_code = JOptionPane.showInputDialog ("Please type the subject's code", subject_code);            // Code
        dyad_code = JOptionPane.showInputDialog ("Please type the dyad code", dyad_code);                       // Dyad
        subject_phone = JOptionPane.showInputDialog ("Please type the subject's phone \n (Press OK if you prefer not to.)", subject_phone);                     // Phone
        subject_email = JOptionPane.showInputDialog ("Please type the subject's email \n (Press OK if you prefer not to.)", subject_email);
      }
      
      if (record_dialogue == JOptionPane.CANCEL_OPTION){
        flush();
      }
    }
  }
  
  if (theEvent.isController() && exit_button.isMouseOver()) {                                      // If the exit button is clicked.
    int exit_dialogue = JOptionPane.showConfirmDialog                                              // Prepare the pop-up dialog.
      (null, "Are you sure you want to close this?");         
    if (exit_dialogue == JOptionPane.YES_OPTION) {                                                 // If possitive, close it.
      try {
        System.exit(0);
      }
      catch (Exception e) {                                                                        // If something goes wrong. 
        exit();
        ;
      }
    } else {
    }
  }

  if (theEvent.isController() && info_button.isMouseOver()) {                                      // If the info button is clicked.
    subject_name = JOptionPane.showInputDialog ("Please the subject's name", subject_name);                 // Ask for name 
    subject_age = JOptionPane.showInputDialog ("Please type the subject's age", subject_age);    // Age
    subject_gender = JOptionPane.showInputDialog ("Please type the subject's gender", subject_gender);      // Gender
    subject_code = JOptionPane.showInputDialog ("Please type the subject's code", subject_code);            // Code
    dyad_code = JOptionPane.showInputDialog ("Please type the dyad code", dyad_code);            // Dyad
    subject_phone = JOptionPane.showInputDialog ("Please type the subject's phone \n (Press OK if you prefer not to.)", subject_phone);                     // Phone
    subject_email = JOptionPane.showInputDialog ("Please type the subject's email \n (Press OK if you prefer not to.)", subject_email);                     // Email
  }
  if (theEvent.isController() && stop_button.isMouseOver()) { 
    start_plot = false;
    log_data = false;
    counter_starts = false;
    myPort.clear();                                                                       // Delete the current port name
    myPort.stop();                                                                        // Stop the current port 
    port_list.clear();
    port_list.setCaptionLabel("   Select port again:   ");
  }
}

void serialEvent (Serial blePort) {                                                        //  Event Handler To Read the packets received from the Device
  inString = blePort.readChar();
  pc_processData(inString);
}

void pc_processData(char rxch)                                                            // Getting Packet Data Function
{
  switch(ecs_rx_state)
  {
  case CESState_Init:
    if (rxch==CES_CMDIF_PKT_START_1)
      ecs_rx_state=CESState_SOF1_Found;
    break;

  case CESState_SOF1_Found:
    if (rxch==CES_CMDIF_PKT_START_2)
      ecs_rx_state=CESState_SOF2_Found;
    else
      ecs_rx_state=CESState_Init;                                                         // Invalid Packet, reset state to init
    break;

  case CESState_SOF2_Found:
    ecs_rx_state = CESState_PktLen_Found;
    CES_Pkt_Len = (int) rxch;
    CES_Pkt_Pos_Counter = CES_CMDIF_IND_LEN;
    CES_Data_Counter = 0;
    break;

  case CESState_PktLen_Found:
    CES_Pkt_Pos_Counter++;
    if (CES_Pkt_Pos_Counter < CES_CMDIF_PKT_OVERHEAD)                                     // Reads Header
    { 
      if (CES_Pkt_Pos_Counter==CES_CMDIF_IND_LEN_MSB)
        CES_Pkt_Len = (int) ((rxch<<8)|CES_Pkt_Len);
      else if (CES_Pkt_Pos_Counter==CES_CMDIF_IND_PKTTYPE)
        CES_Pkt_PktType = (int) rxch;
    } else if ( (CES_Pkt_Pos_Counter >= CES_CMDIF_PKT_OVERHEAD) && 
      (CES_Pkt_Pos_Counter < CES_CMDIF_PKT_OVERHEAD+CES_Pkt_Len+1) )                        // Reads Data
    {
      if (CES_Pkt_PktType == 2)
      {
        CES_Pkt_Data_Counter[CES_Data_Counter++] = (char) (rxch);                         // Buffer that assigns the data separated from the packet
      }
    } else                                                                                // All data received
    {
      if (rxch==CES_CMDIF_PKT_STOP)
      { 
        ces_pkt_ecg_bytes[0] = CES_Pkt_Data_Counter[0];
        ces_pkt_ecg_bytes[1] = CES_Pkt_Data_Counter[1];
        ces_pkt_ecg_bytes[2] = CES_Pkt_Data_Counter[2];
        ces_pkt_ecg_bytes[3] = CES_Pkt_Data_Counter[3];

        ces_pkt_rtor_bytes[0] = CES_Pkt_Data_Counter[4];
        ces_pkt_rtor_bytes[1] = CES_Pkt_Data_Counter[5];
        ces_pkt_rtor_bytes[2] = CES_Pkt_Data_Counter[6];
        ces_pkt_rtor_bytes[3] = CES_Pkt_Data_Counter[7];

        ces_pkt_hr_bytes[0] = CES_Pkt_Data_Counter[8];
        ces_pkt_hr_bytes[1] = CES_Pkt_Data_Counter[9];
        ces_pkt_eda_bytes[0] = CES_Pkt_Data_Counter[10];
        ces_pkt_eda_bytes[1] = CES_Pkt_Data_Counter[11];      

        int data1 = ecsParsePacket(ces_pkt_ecg_bytes, ces_pkt_ecg_bytes.length-1);
        ecg_value = (double) data1/(Math.pow(10, 3));

        int data2 = ecsParsePacket(ces_pkt_rtor_bytes, ces_pkt_rtor_bytes.length-1);
        rtor_value = (double) data2;

        int data3 = ecsParsePacket(ces_pkt_hr_bytes, ces_pkt_hr_bytes.length-1);
        hr_value = (double) data3; 

        int data4 = ecsParsePacket(ces_pkt_eda_bytes, ces_pkt_eda_bytes.length-1);
        eda_value = (double) data4;         
                                                                                         // Assigning the values for the graph buffers
        time = time+1;

        ecg_data[arrayIndex] = (float)ecg_value;                                         // Takes the points from the incoming array and stores them into a float
        eda_data[arrayIndex] = (float)eda_value;

        arrayIndex++;                                                                    // Counts the index of the array.

        if (arrayIndex == pSize)                                                         // Once it reaches the last point it resets the counter.
        {  
          arrayIndex = 0;
          time = 0;
        }       

        if (log_data == true)                                                            // If the logging boolean is on.
        {
          try {
            date = new Date();                                                           // Updates the date.                                      
            dateFormat = new SimpleDateFormat("HH:mm:ss.SSS");                           // Formats the date. 
            bufferedWriter.write(clock_reference + "," + dateFormat.format(date) + ","
              + eda_value + "," + rtor_value + "," + ecg_value + "," + hr_value);        // Prints the headers of the columns on the file.
              bufferedWriter.newLine();                                                  // Creates a new line.
          }
          catch(IOException e) {                                                         // Prints an error message in case something goes wrong
            println("It broke!!!");
            e.printStackTrace();
          }
        }
        ecs_rx_state=CESState_Init;
      } else
      {
        ecs_rx_state=CESState_Init;
      }
    }
    break; 

  default:
    break;
  }
}

public int ecsParsePacket(char DataRcvPacket[], int n)                                   //Recursion Function To Reverse The data
{
  if (n == 0)
    return (int) DataRcvPacket[n]<<(n*8);
  else
    return (DataRcvPacket[n]<<(n*8))| ecsParsePacket(DataRcvPacket, n-1);
}

void receive( byte[] data, String ip, int port ) {  // <-- extended handler

  data = subset(data, 0, data.length);
  clock_reference = new String( data );
  if (data == null){
    clock_reference_boolean = false;
  }  else {
    clock_reference_boolean = true;
  }
//  println (clock_reference);
}
