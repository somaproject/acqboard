//$Id: myarea.h,v 1.1.1.1 2003/01/21 13:41:31 murrayc Exp $ -*- c++ -*-

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

#ifndef SCOPEAREA_H
#define SCOPEAREA_H

#include <gtkmm/drawingarea.h>
#include <gtkmm/main.h>

#include <gdkmm/colormap.h>
#include <gdkmm/window.h>
#include <vector>
#include <stdlib.h>
#include <iostream> 




class ScopeArea : public Gtk::DrawingArea
{
public:
  ScopeArea(int, int);
  virtual ~ScopeArea();
  bool newdata(Glib::IOCondition); 
  int datafd_;
  int channel_; 
  short thold_; 
  

protected:
  //Overridden default signal handlers:
  virtual void on_realize();
  virtual bool on_expose_event(GdkEventExpose* e);

  std::vector<short> winbuffer_; 
  int bufpos_; // position in circular buffer
  int pos_;    // window position, sorta
  float offset_; 
  float scale_; 

  int mode_; // 0 == RAW, 1 == normal

  std::vector<short> databuffer_; 
  
  void add_data(short); 
  short get_data(int); 

  void redraw(void); 

  Glib::RefPtr<Gdk::GC> gc_;
  Gdk::Color blue_, red_, white_, black_;

  int convsample(short); 

  int WINSIZE; 
  int BUFSIZE; 

  void change_mode(int); 

};

#endif // SCOPEAREA_H

