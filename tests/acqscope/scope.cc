#include "scope.h"
#include <iostream>

#include <sys/socket.h>
#include <sys/types.h>
#include <sys/un.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <vector>
#include <string>


Scope::Scope()
  : area_(640, 240), 
    mainbox_(), 
    button_exit_("Exit"), 
    box_chansel_(),
    chanlbl_("Channel Selected:"),
    tholdadjust_(0.0, -32768.0, 32767, 1000.0, 5000.0),  
    tholdsel_(tholdadjust_)
{
  set_title("SOMA Acquisition Board Scope"); 
  

  // establish network connectivity
  int listenfd, connfd;
  struct sockaddr_un cliaddr;
  area_.datafd_ = socket(AF_LOCAL, SOCK_STREAM, 0);

  bzero(&cliaddr, sizeof(cliaddr));
  cliaddr.sun_family = AF_LOCAL;
  
  strncpy(cliaddr.sun_path, "/tmp/acqboard.out", 18); 
  connect(area_.datafd_, (sockaddr *) &cliaddr, sizeof(cliaddr));
  
  
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
    chanbuttons_[i]->signal_clicked().connect(slot(*this, &Scope::on_chansel)); 
    chanbox_.pack_start(*chanbuttons_[i]); 
  }
  chanbox_.show();
  tholdareabox_.pack_start(tholdsel_); 
  tholdsel_.set_draw_value(false);
  tholdsel_.set_update_policy(Gtk::UPDATE_DELAYED   );

  
  tholdareabox_.pack_start(area_); 
  
  tholdadjust_.signal_value_changed().connect( SigC::slot(*this, &Scope::on_tholdchange) );

  mainbox_.pack_start(chanbox_); 
  mainbox_.pack_start(tholdareabox_);
  
  area_.set_size_request(640, 240); 
  
  

  mainbox_.pack_start(button_exit_); 
  button_exit_.show(); 
  mainbox_.show(); 
  
  resize(640, 240); 
  
   
  cout << "Connecting signal ..." ;
  Glib::signal_io().connect(slot(area_, &ScopeArea::newdata),
                           area_.datafd_, Glib::IO_IN);
  cout << "connected!" << endl; 
  
  
  show_all_children();
}


void Scope::on_chansel() 
{
  // handler for every time one of the radio button thingies is clicked


  for (int i = 0; i < 10; i++) 
    if (chanbuttons_[i]->get_active()) 
      area_.channel_ = i; 

}

void Scope::on_tholdchange()
{
  area_.thold_ = short(-tholdadjust_.get_value()); 
}
