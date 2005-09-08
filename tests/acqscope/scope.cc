#include "scope.h"
#include <iostream>

#include <sys/socket.h>
#include <sys/types.h>
#include <sys/un.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <vector>
#include <string>
#include <sigc++/sigc++.h>
#include "thdn.h"


Scope::Scope()
  : area_(640, 240), 
    mainbox_(), 
    button_exit_("Exit"), 
    box_chansel_(),
    chanlbl_("Channel Selected:"),
    tholdadjust_(0.0, -32768.0, 32767, 1000.0, 5000.0),  
    tholdsel_(tholdadjust_),
    thdn_()
{
  set_title("SOMA Acquisition Board Scope"); 
  

  // establish network connectivity
  int listenfd, connfd;
  struct sockaddr_un cliaddr;
  datafd_ = socket(AF_LOCAL, SOCK_STREAM, 0);

  bzero(&cliaddr, sizeof(cliaddr));
  cliaddr.sun_family = AF_LOCAL;
  
  strncpy(cliaddr.sun_path, "/tmp/acqboard.out", 18); 
  connect(datafd_, (sockaddr *) &cliaddr, sizeof(cliaddr));
  
  // compensate for read offset?
  //char dummybuff[100];
  //int OFFSET = 0; 
  //read(area_.datafd_, dummybuff, OFFSET); 
  
  add(mainbox_);

  chanlist_.resize(10); 
  chanlist_[0] = "A0";
  chanlist_[1] = "A1";
  chanlist_[2] = "A2";
  chanlist_[3] = "A3";
  chanlist_[4] = "AC";
  chanlist_[5] = "B1";
  chanlist_[6] = "B2";
  chanlist_[7] = "B3";
  chanlist_[8] = "B4";
  chanlist_[9] = "BC";


  chanbuttons_.resize(10); 

  chanlbl_.show();
 
  chanbox_.pack_start(chanlbl_); 
  for(int i = 0; i < 10; i++) {
    
    chanbuttons_[i] = manage( new Gtk::RadioButton(changroup_,chanlist_[i]));
    chanbuttons_[i]->show();
    chanbuttons_[i]->signal_clicked().connect(sigc::mem_fun(*this, &Scope::on_chansel)); 
    chanbox_.pack_start(*chanbuttons_[i]); 
  }
  chanbox_.show();
  tholdareabox_.pack_start(tholdsel_); 
  tholdsel_.set_draw_value(false);
  tholdsel_.set_update_policy(Gtk::UPDATE_DELAYED   );

  
  tholdareabox_.pack_start(area_); 
  
  tholdadjust_.signal_value_changed().connect(sigc::mem_fun(*this, &Scope::on_tholdchange) );

  mainbox_.pack_start(chanbox_); 
  mainbox_.pack_start(tholdareabox_);
  
  area_.set_size_request(640, 240); 
  
  

  mainbox_.pack_start(button_exit_); 
  button_exit_.show(); 
  mainbox_.show(); 
  
  resize(640, 240); 
  
  mode_ = 1; 
  cout << "Connecting signal ..." ;
  Glib::signal_io().connect(sigc::mem_fun(this, &Scope::newdata),
                           datafd_, Glib::IO_IN);
  cout << "connected!" << endl; 
  
  
  show_all_children();
}


void Scope::change_mode(int newmode) 
{
  if (newmode == 3) {
    mode_ = 0;
  } else {
    mode_ = 1;
  }
  
}


void Scope::add_data(short x) 
{

  area_.add_data(x); 
  thdn_.add_data(x); 
}

bool Scope::newdata(Glib::IOCondition foo)
{

  /*
    ohh, look, the interetsing part
  */


  unsigned char buffer[24];
  int result = read(datafd_, buffer, 24); 

  if ((buffer[1] >> 1) != mode_)
    change_mode(buffer[1]>>1); 
  
  //cout << endl;
  for (int i = 0; i < 10;  i++) { 
    if ((mode_ == 0 and i < 6) or (mode_ == 1 and i == channel_)) { 
      unsigned char lowbyte = buffer[(i+1)*2 + 1];
      unsigned char highbyte = buffer[(i+1)*2];
      unsigned short usample = highbyte * 256 + lowbyte; 
      short sample(0); 
      
      if (usample < 32768) {
	sample = usample;
      } else {
	sample = usample; 
      }
      
      add_data(sample); 
    }
  } 
  return true; 


}

void Scope::on_chansel() 
{
  // handler for every time one of the radio button thingies is clicked

  for (int i = 0; i < 10; i++) 
    if (chanbuttons_[i]->get_active()) 
      channel_ = i; 

}

void Scope::on_tholdchange()
{
  area_.thold_ = short(-tholdadjust_.get_value()); 
}
