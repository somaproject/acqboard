//$Id: main.cc,v 1.1.1.1 2003/01/21 13:41:31 murrayc Exp $ -*- c++ -*-

/* gtkmm example Copyright (C) 2002 gtkmm development team
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License version 2
 * as published by the Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
 */

#include "scopearea.h"
#include <gtkmm/main.h>
#include <gtkmm/window.h>
#include <gtkmm.h>


#include <sys/socket.h>
#include <sys/types.h>
#include <sys/un.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <vector>
#include <string>

using namespace std; 

using std::istream;

using namespace SigC;
using std::auto_ptr;


int main(int argc, char** argv)
{

  int listenfd, connfd;
  struct sockaddr_un cliaddr;
  
  Gtk::Main app(argc, argv);
  
  Gtk::Window win;

  ScopeArea area(640, 240);
  
  area.datafd_ = socket(AF_LOCAL, SOCK_STREAM, 0);
  
  bzero(&cliaddr, sizeof(cliaddr));
  cliaddr.sun_family = AF_LOCAL;
  
  strncpy(cliaddr.sun_path, "/tmp/acqboard.out", 18); 
  
  connect(area.datafd_, (sockaddr *) &cliaddr, sizeof(cliaddr));
  


    
  Gtk::VBox box; 
  Gtk::Button button_exit("Exit"); 
  win.add(box);

  Gtk::HBox radiobox; 
  
  vector<string> chanlist; 
  chanlist.resize(10); 
  chanlist[0] = "A0";
  chanlist[1] = "A1";
  chanlist[2] = "A2";
  chanlist[3] = "A3";
  chanlist[4] = "AC";
  chanlist[5] = "B1";
  chanlist[6] = "B2";
  chanlist[7] = "B3";
  chanlist[8] = "B4";
  chanlist[9] = "BC";

  vector<Gtk::RadioButton*> chanbuttons;
  chanbuttons.resize(10); 

  Gtk::RadioButton::Group group;
  Gtk::Label chanlbl("Channel Selected:"); 
  chanlbl.show(); 
  radiobox.pack_start(chanlbl); 
  for(int i = 0; i < 10; i++) {
    
    chanbuttons[i] = manage( new Gtk::RadioButton(group,chanlist[i]));
    chanbuttons[i]->show();
    chanbuttons[i]->signal_clicked().connect(slot(callback)); 
    radiobox.pack_start(*chanbuttons[i]); 
  }
  radiobox.show();
  box.pack_start(radiobox); 
  box.pack_start(area); 
  area.set_size_request(640, 240); 
  area.show();
  

  box.pack_start(button_exit); 
  button_exit.show(); 
  box.show(); 
  
  win.resize(640, 240); 
  
   
  cout << "Connecting signal ..." ;
  Glib::signal_io().connect(slot(area, &ScopeArea::newdata),
                           area.datafd_, Glib::IO_IN);
  cout << "connected!" << endl; 
  
  
  Gtk::Main::run(win);

  
   

   return 0;
}

