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
  
  strncpy(cliaddr.sun_path, "/tmp/sock", 9); 
  
  connect(area.datafd_, (sockaddr *) &cliaddr, sizeof(cliaddr));
  
    
  
  win.add(area);
  win.resize(640, 240); 
  area.show();
   
  cout << "Connecting signal ..." ;
  Glib::signal_io().connect(slot(area, &ScopeArea::newdata),
                           area.datafd_, Glib::IO_IN);
  cout << "connected!" << endl; 
  
  
  Gtk::Main::run(win);

  
   

   return 0;
}

