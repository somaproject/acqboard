#!/usr/bin/python

import socket
from os import unlink
from struct import *
import acqboardcmd


import gtk

class AcqSocketOut:
    # actually handles the socket communication

    def __init__(self):
        self.s = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)

    def open(self):
        self.s.connect("/tmp/acqboard.in")

    def send(self, str):
        print str
        self.s.send(str + "123456789012345678901")
    def close(self):
        self.s.close()

class AcqSocketStat:
    # actually handles the socket communication

    def __init__(self):
        self.s = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)

    def open(self):
        self.s.connect("/tmp/acqboard.status")

    def read(self):
        return self.s.recv(3)
    
    def close(self):
        self.s.close()





class AcqState:
    
    def __init__(self):
        self.gain = ["x", "x", "x", "x", "x", "x", "x", "x", "x", "x"]
        self.insel = ["", "", "", "", "", "", "", "", "", ""]
        self.hpf = ["", "", "", "", "", "", "", "", "", ""]
        
        self.clist = ["A.1", "A.2", "A.3", "A.4", "A.C", "B.1", "B.2", "B.3", "B.4", "B.C"]
        self.gainlabel = []
        self.glist = ["0", "1", "2", "5", "10", "20", "50", "100"]
        self.hlist = ["DC", "100 Hz", "150 Hz", "300 Hz"] 
        self.chanlabel = []
        self.hpflabel = []
        self.insellabel = []
    




        self.table = gtk.Table(rows=11, columns=4, homogeneous=gtk.FALSE)
        self.cheader = gtk.Label("Channel")
        self.table.attach(self.cheader, 0, 1, 0, 1, xpadding=6)
        self.cheader.show()
        
        self.gheader = gtk.Label("Gain")
        self.table.attach(self.gheader, 1, 2, 0, 1, xpadding=6)
        self.gheader.show()
        
        self.hheader = gtk.Label("HPF")
        self.table.attach(self.hheader, 2, 3, 0, 1, xpadding=6)
        self.hheader.show()
        
        self.iheader = gtk.Label("C Sel")
        self.table.attach(self.iheader, 3 , 4, 0, 1, xpadding=6)
        self.iheader.show()
        
        for i in range(10):
           self.chanlabel.append(gtk.Label(self.clist[i]))
           self.table.attach(self.chanlabel[i], 0,1, i+1, i+2)
           self.chanlabel[i].show()
           
           self.gainlabel.append(gtk.Label(self.gain[i]))
           self.table.attach(self.gainlabel[i], 1, 2, i+1, i+2)
           self.gainlabel[i].show()
           
           self.hpflabel.append(gtk.Label(self.hpf[i]))
           self.table.attach(self.hpflabel[i], 2, 3, i+1, i+2)
           self.hpflabel[i].show()
           
           self.insellabel.append(gtk.Label(self.insel[i]))
           self.table.attach(self.insellabel[i], 3, 4, i+1, i+2)
           self.insellabel[i].show()

           
        self.table.show()    

        self.cmddict = {}


    def startcmdid(self, cmdid,  cmd, args):
        self.cmddict[cmdid] = (cmd, args)

    def commitcmdid(self, cmdid):
        x = self.cmddict[cmdid][0]
        y = self.cmddict[cmdid][1]
        apply(x,y)
        
        
    def update_gain(self, chan, value):
        self.gain[chan] = value
        self.gainlabel[chan].set_text(self.glist[value])

    def update_hpf(self, chan, value):
        self.hpf[chan] = value
        self.hpflabel[chan].set_text(self.hlist[value])

    def update_cchan(self, chan, value):
        if chan == 0 :
            for i in range(5):
                if value == i:
                    self.insel[i] = 'Y'
                else:
                    self.insel[i] = ''
    
        if chan == 1 :
            for i in range(5):
                if value == i:
                    self.insel[i+5] = 'Y'
                else:
                    self.insel[i+5] = ''
        for i in range(10):
            self.insellabel[i].set_text(self.insel[i])
        

class AcqBoardControl:
    clist = ["A.1", "A.2", "A.3", "A.4", "A.C", "B.1", "B.2", "B.3", "B.4", "B.C"]
    hlist = ["DC", "100 Hz", "150 Hz", "300 Hz"]
    glist = ["0", "1", "2", "5", "10", "20", "50", "100"]


    acqcmd = acqboardcmd.AcqBoardCmd()
    acqout = AcqSocketOut()
    
                
    def button_click(self, widget):
        self.label.set_text("Foo!")
   

    def button_set_gain(self, widget):
        chan = self.allchanchanopt.get_history()
        gain = self.allchangainopt.get_history()
        
        self.acqout.send(self.acqcmd.setgain(chan, gain))
        self.acqs.startcmdid(self.acqcmd.cmdid, self.acqs.update_gain, (chan, gain))
                             
    def button_set_hpf(self, widget):
        chan = self.allchanchanopt.get_history()
        filt = self.allchanhpfopt.get_history()
        
        self.acqout.send(self.acqcmd.sethpfilter(chan, filt))
        self.acqs.startcmdid(self.acqcmd.cmdid, self.acqs.update_hpf, (chan, filt))
                             
    def button_cselAset(self, widget):
        chan = self.cselAopt.get_history()
        self.acqout.send(self.acqcmd.setinputch(0, chan))
        self.acqs.startcmdid(self.acqcmd.cmdid, self.acqs.update_cchan, (0, chan))
    def button_cselBset(self, widget):
        chan = self.cselBopt.get_history()
        self.acqout.send(self.acqcmd.setinputch(1, chan))
        self.acqs.startcmdid(self.acqcmd.cmdid, self.acqs.update_cchan, (1, chan))
                             
                             
        
     
    def delete_event(self, widget, event, data=None):
        gtk.main_quit()
        return gtk.FALSE
        
    def create_everychan(self):
        #widgets that exist for each channel
        
        self.allchantable = gtk.Table(rows=3, columns=3, homogeneous=gtk.FALSE)


        self.allchanlabel = gtk.Label("Channel")
        self.allchantable.attach(self.allchanlabel, 0,1, 0, 1)

        self.allchanlabel.show()

       
        self.allchanchanopt = gtk.OptionMenu()
        self.chanmenu = gtk.Menu()
        for i in self.clist:
            item = gtk.MenuItem(i)
            self.chanmenu.append(item)
            item.show()
        self.allchanchanopt.set_menu(self.chanmenu)
        self.allchantable.attach(self.allchanchanopt, 1,2,0,1, gtk.SHRINK)
        self.allchanchanopt.show()

        self.allchangainlabel = gtk.Label("Gain")
        self.allchantable.attach(self.allchangainlabel, 0,1,1,2)
        self.allchangainlabel.show()



        self.allchangainopt = gtk.OptionMenu()
        self.gainmenu = gtk.Menu()
        for i in self.glist:
            item = gtk.MenuItem(i)
            self.gainmenu.append(item)
            item.show()
        self.allchangainopt.set_menu(self.gainmenu)
        self.allchantable.attach(self.allchangainopt, 1,2,1,2, gtk.SHRINK)
        self.allchangainopt.show()


        self.allchangset = gtk.Button("set")
        self.allchangset.connect("clicked", self.button_set_gain)
        self.allchantable.attach(self.allchangset, 2, 3, 1, 2)
        self.allchangset.show()

        self.allchanhpflabel = gtk.Label("HP Filter Cutoff")
        self.allchantable.attach(self.allchanhpflabel, 0,1,2,3)
        self.allchanhpflabel.show()




        self.allchanhpfopt = gtk.OptionMenu()
        self.hpfmenu = gtk.Menu()
        for i in self.hlist:
            print i
            item = gtk.MenuItem(i)
            self.hpfmenu.append(item)
            item.show()
        self.allchanhpfopt.set_menu(self.hpfmenu)
        self.allchantable.attach(self.allchanhpfopt, 1,2,2,3, gtk.SHRINK)
        self.allchanhpfopt.show()




        self.allchanfset = gtk.Button("set")
        self.allchanfset.connect("clicked", self.button_set_hpf)
        self.allchantable.attach(self.allchanfset, 2, 3, 2, 3)
        self.allchanfset.show()

        self.allchanframe = gtk.Frame("Channel Settings")
        self.allchanframe.add(self.allchantable)
        self.allchanframe.show()
        self.box2 = gtk.VBox(gtk.FALSE, 0)

        self.box2.pack_start(self.allchanframe, gtk.FALSE, gtk.FALSE, 0)

        self.cselframe = gtk.Frame("Continuous Chan")
        self.cselframe.show()
        self.box2.pack_start(self.cselframe, gtk.FALSE, gtk.FALSE, 0)
        self.box1.pack_start(self.box2, gtk.FALSE, gtk.FALSE, 0)
        self.box2.show()

        self.cselbox = gtk.VBox(gtk.FALSE,0)
        # continuous channel A box
        
        self.cselAbox = gtk.HBox(gtk.FALSE, 0)

        self.cselAlabel = gtk.Label("Chan A: ")
        
        self.cselAbox.pack_start(self.cselAlabel, gtk.FALSE, gtk.FALSE, 0)
        self.cselAlabel.show()


        self.cselAopt = gtk.OptionMenu()
        self.cselAmenu = gtk.Menu()
        for i in ["A.1", "A.2", "A.3", "A.4"]:
            item = gtk.MenuItem(i)
            self.cselAmenu.append(item)
            item.show()
        self.cselAopt.set_menu(self.cselAmenu)
        self.cselAopt.show()
        self.cselAbox.pack_start(self.cselAopt, gtk.FALSE, gtk.FALSE,0)
        self.cselAbox.show()

        self.cselAset = gtk.Button("set")
        self.cselAset.connect("clicked", self.button_cselAset)
        self.cselAbox.pack_start(self.cselAset, gtk.FALSE, gtk.FALSE, 0)
        self.cselAset.show()


        self.cselbox.pack_start(self.cselAbox, gtk.FALSE, gtk.FALSE, 0)
        self.cselbox.show()

        # continuous channel B box
        
        self.cselBbox = gtk.HBox(gtk.FALSE, 0)

        self.cselBlabel = gtk.Label("Chan B: ")
        
        self.cselBbox.pack_start(self.cselBlabel, gtk.FALSE, gtk.FALSE, 0)
        self.cselBlabel.show()


        self.cselBopt = gtk.OptionMenu()
        self.cselBmenu = gtk.Menu()
        for i in ["B.1", "B.2", "B.3", "B.4"]:
            item = gtk.MenuItem(i)
            self.cselBmenu.append(item)
            item.show()
        self.cselBopt.set_menu(self.cselBmenu)
        self.cselBopt.show()
        self.cselBbox.pack_start(self.cselBopt, gtk.FALSE, gtk.FALSE,0)
        self.cselBbox.show()

        self.cselBset = gtk.Button("set")
        self.cselBset.connect("clicked", self.button_cselBset)
        self.cselBbox.pack_start(self.cselBset, gtk.FALSE, gtk.FALSE, 0)
        self.cselBset.show()

        self.cselbox.pack_start(self.cselBbox, gtk.FALSE, gtk.FALSE, 0)
        
        self.cselframe.add(self.cselbox)
                
        self.allchantable.show()

        
        
    def __init__(self):

        self.acqout.open()
        
        self.window = gtk.Window(gtk.WINDOW_TOPLEVEL)

        self.window.set_title("Soma Acquisition Board Prototype Control")
        self.window.connect("delete_event", self.delete_event)

        self.window.set_border_width(10)


        self.box1 = gtk.HBox(gtk.FALSE, 0)
        self.window.add(self.box1)

    

        self.create_everychan()
        self.acqs = AcqState()
        self.box1.pack_start(self.acqs.table, gtk.FALSE, gtk.FALSE, 0)
    
        self.box1.show()
        self.window.show()

import thread

def sockstat(acqboard, foo):
    acqstat = AcqSocketStat()
    acqstat.open()
    print "Status socket opened"
    while 1:
        stat = unpack("BBB", acqstat.read())
        print "Status is %d %d %d" % stat
        acqboard.acqs.commitcmdid(stat[1]/2)
        


def main():

    gtk.main()


if __name__  == "__main__":
    testing = AcqBoardControl()
    
    thread.start_new_thread(sockstat, (testing,0))

    gtk.threads_init()
    gtk.mainloop()
