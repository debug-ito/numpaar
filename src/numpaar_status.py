#!/usr/bin/python

import os
import sys
import threading
import pygtk
pygtk.require('2.0')
import gtk
import gobject
import pango

BUTTON_WIDTH  = 70
BUTTON_HEIGHT = 45
SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
ICON_DIR = SCRIPT_DIR + "/../resources/"
ICON_DICT = {'normal' : "normal.icon.svg", 'busy' : "busy.icon.svg"}
WIN_X = 0
WIN_Y = 0
LABEL_FONT = "sans 12"


class ReadingThread(threading.Thread):
    def __init__(self, win, buttons_dict, status_icon):
        threading.Thread.__init__(self)
        self.setDaemon(True)
        self.main_window = win
        self.remote_buttons = buttons_dict
        self.status_icon = status_icon
        self.is_shown = False

    def setButtonLabel(self, button, label):
        button.get_child().set_label(label)

    def toggleWindowShow(self):
        if self.is_shown:
            self.is_shown = False
            self.main_window.hide()
        else:
            self.is_shown = True
            self.main_window.show_all()

    ## ** TODO: Load all icons at the init phase.
    def changeIcon(self, icon_id):
        if icon_id not in ICON_DICT:
            sys.stderr.write("STATUSPY: No such icon ID as " + icon_id)
            return
        self.status_icon.set_from_file(ICON_DIR + ICON_DICT[icon_id])

    def run(self):
        sys.stderr.write("STATUSPY: START\n")
        line = sys.stdin.readline()
        while line:
            fields = line.rstrip().split(" ")
            key = fields[0]
            explanation = ""
            for i in range(1, len(fields)):
                explanation += fields[i] + " "
            if key == "toggle":
                gobject.idle_add(self.toggleWindowShow)
            elif key == "icon" and len(fields) >= 2:
                gobject.idle_add(self.changeIcon, fields[1])
            elif key in self.remote_buttons:
                gobject.idle_add(self.setButtonLabel, self.remote_buttons[key], explanation)
            line = sys.stdin.readline()
        sys.stderr.write("STATUSPY: QUIT\n")
        gtk.main_quit()

class NumpaarStatus:
    def addButton(self, left, right, top, bottom, keystr, default_label):
        newbutton = gtk.Button()
        newlabel = gtk.Label(default_label)
        newlabel.set_line_wrap(True)
        newlabel.set_alignment(0, 0.5)
        newlabel.set_justify(gtk.JUSTIFY_LEFT)
        newlabel.modify_font(pango.FontDescription(LABEL_FONT))
        newbutton.set_alignment(0, 0.5)
        newbutton.add(newlabel)
        self.maintable.attach(newbutton, left, right, top, bottom)
        newlabel.set_size_request(BUTTON_WIDTH * (right - left),
                                  BUTTON_HEIGHT * (bottom - top))
        self.remote_buttons[keystr] = newbutton
        
    def setupButtons(self):
        self.remote_buttons = dict()
        self.addButton(0, 1, 0, 1, "numlock",  "NumLock")
        self.addButton(1, 2, 0, 1, "divide",   "/")
        self.addButton(2, 3, 0, 1, "multiply", "*")
        self.addButton(3, 4, 0, 1, "minus",    "-")
        self.addButton(0, 1, 1, 2, "home",     "7")
        self.addButton(1, 2, 1, 2, "up",       "8")
        self.addButton(2, 3, 1, 2, "page_up",  "9")
        self.addButton(3, 4, 1, 3, "plus",     "+")
        self.addButton(0, 1, 2, 3, "left",     "4")
        self.addButton(1, 2, 2, 3, "center",   "5")
        self.addButton(2, 3, 2, 3, "right",    "6")
        self.addButton(0, 1, 3, 4, "end",      "1")
        self.addButton(1, 2, 3, 4, "down",     "2")
        self.addButton(2, 3, 3, 4, "page_down","3")
        self.addButton(3, 4, 3, 5, "enter",    "Enter")
        self.addButton(0, 2, 4, 5, "insert",   "0")
        self.addButton(2, 3, 4, 5, "delete",   ".")

        

    def delete_event(self, widget, event, data=None):
        # Change FALSE to TRUE and the main window will not be destroyed
        # with a "delete_event".
        sys.stderr.write("STATUSPY: delete\n")
        return False

    def destroy(self, widget, data=None):
        sys.stderr.write("STATUSPY: destroy\n")
        gtk.main_quit()

    def __init__(self):
        # create a new window
        self.window = gtk.Window(gtk.WINDOW_TOPLEVEL)
    
        self.window.connect("delete_event", self.delete_event)
        self.window.connect("destroy", self.destroy)
    
        self.window.set_keep_above(True)
        self.window.set_property("skip-pager-hint", True)
        self.window.set_property("skip-taskbar-hint",True)
        self.window.set_property("accept-focus", False)

        self.maintable = gtk.Table(5,4,False)
        self.setupButtons()
        self.window.add(self.maintable)

        self.window.set_title("Numpaar Status")
        self.window.move(WIN_X, WIN_Y)

        self.status_icon = gtk.status_icon_new_from_file(ICON_DIR + ICON_DICT['normal'])

    def main(self):
        gobject.threads_init()
        reading = ReadingThread(self.window, self.remote_buttons, self.status_icon)
        reading.start()
        sys.stderr.write("STATUSPY: before gtk.main\n")
        gtk.main()

if __name__ == "__main__":
    status = NumpaarStatus()
    status.main()


