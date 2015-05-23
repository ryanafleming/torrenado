#!/usr/bin/python

from deluge.ui.client import client
from twisted.internet import reactor
import argparse
import sys
import os.path
import base64

#The priority for files in torrent, range is [0..7] however only [0, 1, 5, 7] are normally used and correspond to [Do Not Download, Normal, High, Highest]
filepath = ""

def get_torrent_data(torrent_id):
    print torrent_id
    client.disconnect()
    reactor.stop()

def on_connect_success(result):
    global filepath
    print "Connection was successful!"
    #check torrent file exists from argument
    if os.path.isfile(filepath) and filepath.endswith(".torrent"):
        with open (filepath, "rb") as myfile:
            data=myfile.read()
        #add_torrent_file(filename, filedump, options)
        print "adding torrent to core"
        print filepath
        client.core.add_torrent_file(
            unicode(filepath, 'utf-8'),
            data,
            options={'add_paused': True}
        ).addCallback(get_torrent_data)
    else:
        print "Check your file name or location. Is it a torrent file?"
        sys.exit()

def on_connect_fail(result):
    print "Connection failed!"
    print "result:", result
    
#parse arguments to application
parser = argparse.ArgumentParser(
    description = 'Import torrents from uTorrent into Deluge.',
    formatter_class = argparse.ArgumentDefaultsHelpFormatter)

parser.add_argument('--filepath', help="torrent file exact location using '/' forward slashes")
args = parser.parse_args()

filepath = args.filepath
#ensure that all arguments are correct
if args.filepath is None:
    print('please fill in args correctly...')
    sys.exit()


#connect to daemon
d = client.connect('127.0.0.1',58846,'','')
d.addCallback(on_connect_success)
d.addErrback(on_connect_fail)

reactor.run()
