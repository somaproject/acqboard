#ifndef SCOPE_H
#define SCOPE_H

#include <gtkmm.h>
#include <gtkmm/button.h>
#include <gtkmm/window.h>
#include "scopearea.h"
#include <string>
#include <vector>

using namespace std;

class Scope : public Gtk::Window
{

public:
  Scope();
  //virtual ~Scope();

protected:
  //Signal handlers:
  void on_chansel();
  void on_tholdchange(); 
  //Member widgets:
  
  ScopeArea area_;
  Gtk::VBox mainbox_; 
  Gtk::HBox chanbox_; 
  Gtk::HBox tholdareabox_; 
  Gtk::Button button_exit_;
  

  Gtk::HBox box_chansel_;
  Gtk::Adjustment tholdadjust_; 
  Gtk::VScale tholdsel_; 

  
  vector<string> chanlist_; 

  vector<Gtk::RadioButton*> chanbuttons_;

  Gtk::RadioButton::Group changroup_;
  Gtk::Label chanlbl_;

};

#endif //SCOPE_H

