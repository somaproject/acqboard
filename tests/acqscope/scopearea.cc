//$Id: myarea.cc,v 1.1.1.1 2003/01/21 13:41:31 murrayc Exp $ -*- c++ -*-

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

using namespace std; 
ScopeArea::ScopeArea(int width, int height)
{


  // get_window() would return 0 because the Gdk::Window has not yet been realized
  // So we can only allocate the colors here - the rest will happen in on_realize().
  Glib::RefPtr<Gdk::Colormap> colormap = get_default_colormap ();

  blue_ = Gdk::Color("blue");
  red_ = Gdk::Color("red");
  white_ = Gdk::Color("white"); 
  black_ = Gdk::Color("black"); 
  colormap->alloc_color(blue_);
  colormap->alloc_color(red_);
  colormap->alloc_color(white_); 
  colormap->alloc_color(black_); 


  WINSIZE = width; 
  BUFSIZE = 2048; 

  // scale
  offset_ = height/2;
  scale_ = (double)(height/2)/32768.0;
  thold_ = 1000; 
  
// set up buffers
  
  winbuffer_.resize(WINSIZE); 
  databuffer_.resize(BUFSIZE); 

  for (int i = 0; i < WINSIZE; i++) {
    winbuffer_[i] = convsample(0); 

  }

  
  bufpos_ = 0;
  pos_ = -1; 

  mode_ = 0; 

}


ScopeArea::~ScopeArea()
{
}

void ScopeArea::add_data(short x) {
  // stores data at the current pos, and increments it or resets to zero
  databuffer_[bufpos_] = x; 
  if (bufpos_ + 1 == BUFSIZE) {
    bufpos_ = 0;
  } else { 
    bufpos_++;
  }
  

  if (pos_ < 0) { 
    if ((x > thold_) and (get_data(-1) <= thold_)) {
      pos_ = 0;
    }
  } else {
    pos_++; 
    if (pos_ == WINSIZE) {
      // we've reached a full window
      
      for (int j = 0; j < WINSIZE; j++) { 
	winbuffer_[j] = convsample(get_data(-(WINSIZE-j)));
	
      }
      pos_ = -1;
      redraw(); 
      
    }
    
  }
  
}

short ScopeArea::get_data(int pos) {
  // pos == 0 gets the most recently written sample, 
  // pos == -n gets the previous nth sample
  //   we need to check for wrap-around
  int newpos = bufpos_ - 1 + pos; 
  
  while (newpos < 0) { 
    newpos += BUFSIZE;
  }
  return databuffer_[newpos];
  
}


void ScopeArea::on_realize()
{
  // We need to call the base on_realize()
  Gtk::DrawingArea::on_realize();

  // Now we can allocate any additional resources we need
  Glib::RefPtr<Gdk::Window> window = get_window();
  gc_ = Gdk::GC::create(window);
  window->set_background(white_);
  window->clear();
  gc_->set_foreground(blue_);
}


int ScopeArea::convsample(short x) {  
  int y; 

  y = (short)( -(x * scale_) + offset_); 
  
  return y; 
}
  
  
bool ScopeArea::on_expose_event(GdkEventExpose*)
{
  // This is where we draw on the window
  Glib::RefPtr<Gdk::Window> window = get_window();
  window->clear();

  // draw grid
  gc_->set_foreground(black_);
  window->draw_line(gc_, 0, offset_, WINSIZE, offset_); 

  // draw threshold
  gc_->set_foreground(red_); 
  window->draw_line(gc_, 0, convsample(thold_), WINSIZE, convsample(thold_)); 


  
  // render plot
  gc_->set_foreground(blue_);
  for(int i = 0; i < WINSIZE-1; i++) {
    window->draw_line(gc_, i, winbuffer_[i], (i+1) , winbuffer_[i+1]);
    
  }

  // text to be rendered
  
  if (mode_ == 0){
    Glib::RefPtr<Pango::Layout> pangolayout = create_pango_layout("Mode: RAW");
    Pango::FontDescription foo; 
    foo.set_size(10000); 
    pangolayout->set_font_description(foo); 
    window->draw_layout(gc_, 5, 220, pangolayout);
  } else {
    Glib::RefPtr<Pango::Layout> pangolayout = create_pango_layout("Mode: Normal");
    Pango::FontDescription foo; 
    foo.set_size(10000); 
    pangolayout->set_font_description(foo); 
    window->draw_layout(gc_, 5, 220, pangolayout);
  }    

  return true;
}


void ScopeArea::redraw(void)
{

  queue_draw();
}

void ScopeArea::change_mode(int newmode) 
{
  if (newmode == 3) {
    mode_ = 0;
  } else {
    mode_ = 1;
  }
  
}
