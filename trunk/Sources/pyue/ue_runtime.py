#    NTFS Undelete
#    Copyright (C) 2008 Atola Technology.
#    http://ntfsundelete.com
#
#    Authors:
#      Alexander Malashonok
#      Fedir Nepyivoda <fednep@gmail.com>
#
#    This program is free software; you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation; either version 2 of the License, or
#    (at your option) any later version.
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#    You should have received a copy of the GNU General Public License
#    along with this program; if not, write to the Free Software
#    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

import sys
import traceback
import thread
import os
import os.path
import app
import time
import locale
from fstools import *
from ntfs import *
from ue_con import *

print "Application initialized."

def p_unicode(s):
    return unicode(s, locale.getpreferredencoding())    
    

"""
class GUILogger:

    def __init__(self):
        self.__last_line = u""

    def write(self, data):
        line = self.__last_line
        commit = False
        for c in data:
            if c == '\n':
                line = u""
                app.AppendLogMsg(line)
                commit = True
            elif c == '\r':
                app.SetLastLogMsg(line)
                line = u""
                commit = True
            else:
                line += c
                commit = False
        if not commit:
            app.SetLastLogMsg(line)
        self.__last_line = line

    def writelines(self, lines):
        for line in lines:
            self.write(line)


if not app.HasConsole():
    logger = GUILogger()
    sys.stdout = logger
    sys.stderr = logger
"""

class CScanMgr:

    def __init__(self):
        self.__active_scanners = {}
        self.__mgr_lock = threading.Lock()

    def add_scanner(self, scanner):
        self.__mgr_lock.acquire()
        self.__active_scanners[scanner] = scanner
        self.__mgr_lock.release()

    def finish_scanner(self, scanner):
        self.__mgr_lock.acquire()
        if self.__active_scanners.has_key(scanner):
            del self.__active_scanners[scanner]
        self.__mgr_lock.release()

    def _lock_all(self):
        for scanner in self.__active_scanners.values():
            scanner.lock()

    def _unlock_all(self):
        for scanner in self.__active_scanners.values():
            scanner.unlock()

    def interlocked_call(self, callable, *args, **kwargs):
        """
            Blocks all scanners, execute callable
            and unlocks scanners
        """
        self.__mgr_lock.acquire()
        self._lock_all()
        try:
            callable(*args, **kwargs)
        finally:
            self._unlock_all()
            self.__mgr_lock.release()


    def find_scanner_for_drive(self, drive_name):
        """
            search scanner for drive, pause it,
            and return result
        """
        result = None
        self.__mgr_lock.acquire()
        self._lock_all()
        for scanner in self.__active_scanners.values():
            if scanner.drive_name == drive_name:
                result = scanner
                break        
        for scanner in self.__active_scanners.values():
            if scanner != result:
                scanner.unlock()
        self.__mgr_lock.release()
        return result



    active_scanners = property (lambda self: self.__active_scanners.copy())
      


ScanMgr = CScanMgr()


def update_quickview():        
    app.SetQVCaption(STR_NOT_AVAIL)
    FF = app.GetFocusedFile()
    if FF:            
        try:        
            mft_ref = app.EntryGetMFTRef(FF);
            Volume = app.VolumeForEntry(FF)
            CurrentQVFile = Volume.open_file(mft_ref)
        except Exception, Value:
            traceback.print_exc()
            CurrentQVFile = None
        if CurrentQVFile:
            RC = CurrentQVFile.default_data_stream_size >> 4
            if CurrentQVFile.default_data_stream_size & 3:
                RC += 1
            if RC > 4096:
                RC = 4095
            app.SetQVCaption(CurrentQVFile.win32_file_names.keys()[0])
            C = RC * 16;
            if C > CurrentQVFile.default_data_stream_size:
                C = CurrentQVFile.default_data_stream_size
            if C > 0:
                try:
                    data = CurrentQVFile.data_streams[""].read_data(0, C)
                    app.SetQVData(data)
                    app.SetQVRowCount(RC)
                except Exception, Value:
                    traceback.print_exc()
            else:
                app.SetQVRowCount(0)
            return 


class CNTFSBaseScanner:

    def __init__(self, drive_name, device_name = None):
        self.__drive_name = drive_name
        self.__device_name = device_name
        self.__finish_event = threading.Event()
        self.__scanner_lock = threading.Lock()
        self.__finished = False
        self.__locked = False;

    drive_name = property (lambda self: self.__drive_name)
    finish_event = property (lambda self: self.__finish_event)
    finished = property (lambda self: self.__finished)
    locked = property (lambda self: self.__locked)

    def lock(self):        
        self.__scanner_lock.acquire()
        self.__locked = True


    def unlock(self):
        assert self.__locked
        self.__locked = False
        self.__scanner_lock.release()

    def run(self):
        ScanMgr.add_scanner(self)
        thread.start_new_thread(self.__run, ())

    def on_drive_open_error(self, ExceptionValue):
        pass

    def on_volume_open_error(self, ExceptionValue):
        pass

    def on_open_volume(self, VolumeObject):
        pass

    def on_open_entry_error(self, mft_ref, ExceptionValue):
        pass

    def on_open_entry_ok(self, mft_ref, file_object):
        pass

    def on_scan_finish(self):
        pass

    def __run(self):                
        print "Base scanner: start scanning device ", self.__device_name
        drive_name = self.__device_name
        if not drive_name:
            drive_name = self.__drive_name
        try:
            drive = CreateCCachedDisk(CreateCOSDisk(drive_name), 7, 64)
        except Exception, Value:
            print "Base scanner: drive opening error: ", Value
            traceback.print_exc()
            self.on_drive_open_error(Value)
            ScanMgr.finish_scanner(self)
            return
        try:
            volume = CNTFSVolume(drive, 0, drive.sector_count)
            volume.initialize()
        except Exception, Value:
            print "Base scanner: volume opening error: ", Value
            traceback.print_exc()
            self.on_volume_open_error(Value)
            ScanMgr.finish_scanner(self)
            return
        print "Base scanner: volume opened successfully"
        self.on_open_volume(volume)
        RC = volume.MFT.mft_record_count
        print "Base scanner: start scanning for %s $MFT records" % RC
        i = 0L
        acq = self.__scanner_lock.acquire
        rel = self.__scanner_lock.release
        while i < RC:
            acq()                        
            try:
                file = volume.open_file_if_base(i)
            except Exception, Value:                
                self.on_open_entry_error(i, Value)
                i += 1
                rel()
                continue
            else:
                try:
                    self.on_open_entry_ok(i, file)
                finally:
                    rel()
            i += 1
        print "Base scanner: scanning process complete"
        self.on_scan_finish()
        self.finish_event.set()
        ScanMgr.finish_scanner(self)



class CNTFSVisualScanner(CNTFSBaseScanner):

    def __init__(self, volume_entry):
        self.__volume_entry = volume_entry
        drive_name = app.EntryGetName(volume_entry)
        device_name = u"\\\\.\\%s" % drive_name
        self.__unk_folder = None
        CNTFSBaseScanner.__init__(self, drive_name, device_name)

    unk_folder = property (lambda self: self.__unk_folder)
    volume_entry = property (lambda self: self.__volume_entry)

    def on_open_volume(self, VolumeObject):
        app.EntrySetUserFlag(self.__volume_entry, 0, 1) # disable on-click scanning
        app.SetupVolumeObject(self.__volume_entry, VolumeObject)
        app.SetScanPercent(self.__volume_entry, 0)        
        self.__unk_folder = app.AddDirectoryEntry(self.__volume_entry, -7L, 0, u"Lost Files and Folders", 1, 0, 0)
        self.__folders = [None for i in xrange(VolumeObject.MFT.mft_record_count)]
        self.__volume = VolumeObject
        self.__tmp_old_oade = self.on_add_directory_entry
        self.on_add_directory_entry = self.__on_first_dir_entry
        app.ShowScanDlg(self.__volume_entry)

    def on_drive_open_error(self, ExceptionValue):
        app.ShowMessageModal(STR_DRV_ACCES_ERROR % str(ExceptionValue))

    def on_volume_open_error(self, ExceptionValue):
        app.ShowMessageModal(STR_CANNOT_OPEN_NTFS_VOLUME)
        print ExceptionValue
        traceback.print_exc()

    def on_open_entry_error(self, mft_ref, ExceptionValue):
        pass #print "Entry skipped: ", mft_ref, str(ExceptionValue)

    on_add_file_entry       = lambda self, entry, entry_to: None
    on_move_entry           = lambda self, entry, entry_to: None
    on_add_directory_entry  = lambda self, entry, entry_to: None

    def __on_first_dir_entry(self, entry, entry_to):
        app.ExpandEntryEx(self.__volume_entry)
        self.on_add_directory_entry = self.__tmp_old_oade
        return self.__tmp_old_oade(entry, entry_to)

    def on_open_entry_ok(self, mft_ref, file):
        if mft_ref == 5:
            return
        folders = self.__folders
        creation_time, last_data_change_time, last_access_time, last_mft_change_time, file_attributes = file.get_standard_info()
        CD = app.NTFSDate2DateTime(creation_time)
        MD = app.NTFSDate2DateTime(last_data_change_time)
        for file_name, file_name_attr in file.win32_file_names.items():
            parent_ref = file_name_attr.get_parent_directory() & 0xffffffffffff
            if parent_ref >= len(folders):
                continue
            if parent_ref != 5:
                parent_folder = folders[parent_ref]
            else:
                parent_folder = self.__volume_entry
            if parent_folder is None:
                parent_folder = app.AddDirectoryEntry(self.__unk_folder, parent_ref, 0, u"", 1, 0, 0)
                folders[parent_ref] = parent_folder
                self.on_add_directory_entry(parent_folder, self.__unk_folder)
            if file.is_directory:
                fld = folders[mft_ref]
                if fld: 
                    app.NotifyChangeEntry(fld, file_name, CD, MD, file.is_deleted)
                    app.MoveEntry(fld, parent_folder)
                    self.on_move_entry(fld, parent_folder)
                else:                  
                    folders[mft_ref] = entry = app.AddDirectoryEntry(parent_folder, mft_ref, file.data_stream_count, file_name, file.is_deleted, CD, MD)
                    self.on_add_directory_entry(entry, parent_folder)
            else:
                entry = app.AddFileEntry(parent_folder, mft_ref, 
                                 file.default_data_stream_size, 
                                 file.data_stream_count, 
                                 file_name, 
                                 file.is_deleted, 
                                 CD, 
                                 MD)
                self.on_add_file_entry(entry, parent_folder)

        if mft_ref % 0x100 == 0:
            percent = int(mft_ref*100.0/self.__volume.MFT.mft_record_count)
            app.SetScanPercent(self.__volume_entry, percent)
            print "SCAN: ", self.drive_name, mft_ref, " entries processed\r",

    def on_scan_finish(self):
        app.SetScanPercent(self.__volume_entry, 100)
        app.HideScanDlg()


def scan_drive():
    print "Starting scan."
    CNTFSVisualScanner(app.GetCWD()).run()    



def internal_object_report():
    report = u"""
    <html>
    <head>
        <link rel=stylesheet href="file://%s//reports-style.css" type="text/css">
    </head>
    <body>
        <p>Internal object. No properties available.</p>    
    </body>
    </html>
    """
    return report % p_unicode(os.getcwd())

def make_properties_report(volume, mft_ref):
    if mft_ref < 0:
        return internal_object_report()
    general_info_template = STR_GENERAL_INFO_TEMPLATE

    file = CNTFSFile(volume, mft_ref)
    file.open()
    is_deleted = "No"
    if file.is_deleted:
        is_deleted = "Yes"

    MFTRecords = ""
    j = 1
    for i in file.mft_refs:
        MFTRecords = MFTRecords + "<tr><td>MFT#%i</td><td>%s</td></tr>" % (j, i)
        j += 1
                   
    general_info = general_info_template % (
        p_unicode(os.getcwd()),
        mft_ref,
        volume.path_for_mft_ref(mft_ref)[:-1],
        file.data_stream_count,
        is_deleted,
        len(file.mft_records),
        MFTRecords        
    )
    return general_info



SearchActive = False
search_lock = threading.Lock()


class CSearchScanMixin:

    def __init__(self, scanner, validation_cb, finish_evt, recurse_search_cb):
        self.__scanner = scanner
        self.__validation_cb = validation_cb
        self.__recurse_search_cb = recurse_search_cb
        self.__finish_evt = finish_evt

    scanner = property (lambda self: self.__scanner)

    def __check_activity(self):
        if not SearchActive:
            self.detach_mixin()
            self.__finish_evt.set()
            return False
        return True

    def __on_add_file_entry(self, entry, entry_to):
        self._old_on_add_file_entry(entry, entry_to)
        if self.__check_activity():
            if not app.EntryHasUnkEntryParent(entry):
                self.__validation_cb(entry)

    def __on_drive_open_error(self, ExceptionValue):
        self.__finish_evt.set()

    def __on_volume_open_error(self, ExceptionValue):
        self.__finish_evt.set()

    def __on_add_directory_entry(self, entry, entry_to):
        self._old_on_add_directory_entry(entry, entry_to)
        if self.__check_activity():
            if not app.EntryHasUnkEntryParent(entry):
                self.__validation_cb(entry)

    def __on_move_entry(self, entry, entry_to):
        self._old_on_move_entry(entry, entry_to)
        if self.__check_activity():
            if not app.EntryHasUnkEntryParent(entry):
                self.__recurse_search_cb(entry)                        

    def __on_scan_finish(self):
        self._old_on_scan_finish()
        self.__finish_evt.set()
        
    @classmethod
    def attach_mixin(self, scanner, *args):        
        mixin = self(scanner, *args)
        mixin._old_on_add_file_entry        = scanner.on_add_file_entry
        mixin._old_on_add_directory_entry   = scanner.on_add_directory_entry 
        mixin._old_on_move_entry            = scanner.on_move_entry 
        mixin._old_on_scan_finish           = scanner.on_scan_finish
        mixin._old_on_drive_open_error      = scanner.on_drive_open_error
        mixin._old_on_volume_open_error     = scanner.on_volume_open_error
        scanner.on_add_file_entry       = mixin.__on_add_file_entry
        scanner.on_add_directory_entry  = mixin.__on_add_directory_entry
        scanner.on_move_entry           = mixin.__on_move_entry
        scanner.on_scan_finish          = mixin.__on_scan_finish
        scanner.on_drive_open_error     = mixin.__on_drive_open_error
        scanner.on_volume_open_error    = mixin.__on_volume_open_error
        return mixin

    def detach_mixin(self):
        scanner = self.scanner
        scanner.on_add_file_entry       = self._old_on_add_file_entry
        scanner.on_add_directory_entry  = self._old_on_add_directory_entry
        scanner.on_move_entry           = self._old_on_move_entry
        scanner.on_drive_open_error     = self._old_on_drive_open_error
        scanner.on_volume_open_error    = self._old_on_volume_open_error

def search_files():

    FoundResults = 0L


    def do_search():
        global FoundResults
        app.InitSearch()
        FoundResults = 0L
        search_params = app.GetSearchParams()
        look_in = search_params['look_in']
        if type(look_in) != type(1):
            _do_search(look_in)
        else:
            root = app.GetRootEntry()
            entry = app.EntryGetFirstChild(root)
            while entry:
                if app.EntryIsDrive(entry):
                    _do_search(entry)
                entry = app.EntryGetNext(entry)
        app.DoneSearch()
        app.ShowMessageModal(STR_SEARCH_COMPLETE % FoundResults)

    def _do_search(search_start_entry):        
        global SearchActive, FoundResults
        print "Search start..."
        SearchActive = True
        search_params = app.GetSearchParams()
        masks = map(lambda x: x.strip(), search_params["masks"].split(","))
        case_sensitive = search_params['case_sensitive']
        search_folders = search_params['search_folders']
        search_files = search_params['search_files']
        search_deleted = search_params['deleted_entries']
        search_non_deleted = search_params['non_deleted_entries']
        use_modify_filter = search_params['use_modify_filter']
        modify_from = None
        modify_to = None
        if use_modify_filter:
            modify_from = search_params['modify_from']
            modify_to = search_params['modify_to']
        use_create_filter = search_params['use_create_filter']
        created_from = None
        created_to = None
        if use_create_filter:
            created_from = search_params['created_from']
            created_to = search_params['created_to']
        if not case_sensitive:
            masks = map(lambda mask: mask.upper(), masks)
        size_from = search_params.get("size_from", None)
        if size_from:
            a, b = tuple(filter(lambda x: x!='', size_from.split(" ")))
            size_from = long(a)
            if b == "KB":
                size_from *= 1024L
            elif b == "MB":
                size_from *= 1024L*1024L
            elif b == "GB":
                size_from *= 1024L*1024L*1024L
        size_to = search_params.get("size_to", None)
        if size_to:
            a, b = tuple(filter(lambda x: x!='', size_to.split(" ")))
            size_to = long(a)
            if b == "KB":
                size_to *= 1024L
            elif b == "MB":
                size_to *= 1024L*1024L
            elif b == "GB":
                size_to *= 1024L*1024L*1024L

        _entries = {}


        def _validate_entry(entry):
            name = app.EntryGetName(entry)
            if not case_sensitive:
                name = name.upper()
            for mask in masks:
                if mask == "*.*":
                    mask = "*"
                if not app.FileNameMatches(name, unicode(mask)):
                    continue
                if not ((search_files and app.EntryIsFile(entry)) or (search_folders and app.EntryIsDirectory(entry))):
                    continue
                if not ((search_deleted and app.EntryIsDeleted(entry)) or (search_non_deleted and not app.EntryIsDeleted(entry))):
                    continue
                if use_modify_filter:
                    MD = app.EntryGetModifyDate(entry)
                    if not ((MD >= modify_from) and (MD < modify_to + 1)):
                        continue
                if use_create_filter:
                    CD = app.EntryGetCreateDate(entry)
                    if not ((CD >= created_from) and (CD < created_to + 1)):
                        continue
                if size_from is not None and app.EntryIsFile(entry):
                    if not (app.EntryGetDataSize(entry) >= size_from):
                        continue
                if size_to is not None and app.EntryIsFile(entry):
                    if not (app.EntryGetDataSize(entry) <= size_to):
                        continue
                mft_ref = app.EntryGetMFTRef(entry)
                if not _entries.has_key(mft_ref):
                    app.AddSearchResult(entry)
                    _entries[mft_ref] = entry
                break

        def _caption_thread(evt):
            while True:
                for i in xrange(6):
                    evt.wait(0.5)
                    if evt.isSet():
                        return
                    app.SetSearchCaption(u"Searching "+u"."*i)

        skip_unk_entry = False

        def _search_from(entry):
            while entry and SearchActive:
                _validate_entry(entry)                
                if app.EntryIsContainer(entry):
                    if skip_unk_entry and app.EntryIsDirectory(entry) and app.EntryGetMFTRef(entry) == -7:
                        entry = app.EntryGetNext(entry)
                        continue
                    _search_from(app.EntryGetFirstChild(entry))
                entry = app.EntryGetNext(entry)

        def _recurse_search(entry):
            if entry:
                _validate_entry(entry)                
                _search_from(app.EntryGetFirstChild(entry))

        search_finished = threading.Event()

        def __on_search_init_error(ExceptionValue):
            search_finished.set()
            app.ShowMessageModal(STR_NON_NTFS_DRIVE % (app.EntryGetName(search_start_entry),))

        entry_name = app.EntryGetName(search_start_entry)
        search_lock.acquire()
        if app.EntryIsDriveNotScanned(search_start_entry): # start scan if needed
            scanner = CNTFSVisualScanner(search_start_entry)
            scanner.on_drive_open_error = __on_search_init_error
            scanner.on_volume_open_error = __on_search_init_error
            scanner.run()            
        search_lock.release()
        scanner = ScanMgr.find_scanner_for_drive(entry_name)
        thread.start_new_thread(_caption_thread, (search_finished, ))
        if scanner is None:          # this drive is not scanned now
            _recurse_search(search_start_entry)
            search_finished.set()
        else:
            skip_unk_entry = True
            _recurse_search(search_start_entry)
            skip_unk_entry = False
            CSearchScanMixin.attach_mixin(scanner, _validate_entry, search_finished, _search_from)
            scanner.unlock()
            search_finished.wait()
            _recurse_search(scanner.unk_folder)

        print "\n\nFOUND: ", app.GetSearchResultCount()
        FoundResults += app.GetSearchResultCount()

    thread.start_new_thread(do_search, ())


def cancel_search():
    global SearchActive
    SearchActive = False



def get_checked_entries():
    result = []
    def recurse_process(entry):
        if app.EntryIsChecked(entry):
            result.append(entry)
            if app.EntryIsContainer(entry):
                entry = app.EntryGetFirstChild(entry)
                while entry:
                    recurse_process(entry)
                    entry = app.EntryGetNext(entry)
    recurse_process(app.GetRootEntry())
    return result

def local_path_for_entry(entry):
    if app.EntryIsDrive(entry):
        return app.EntryGetName(entry)[0]
    parent = app.EntryGetParent(entry)
    if parent:
        return local_path_for_entry(parent) + u"\\" + app.EntryGetName(entry)
    else:
        return u""

def real_path_for_entry(entry):
    parent = app.EntryGetParent(entry)
    if parent:
        return real_path_for_entry(parent) + u"\\" + app.EntryGetName(entry)
    else:
        return u""


def get_entry_parents(entry):
    R = []
    p = app.EntryGetParent(entry)
    while p:
        R.append(p)
        p = app.EntryGetParent(p)
    return R


def get_minimal_common_parent_id(file_entries):
    c = {}
    d = {}
    for e in file_entries:
        parents = get_entry_parents(e)
        dpt = len(parents)
        for parent in parents:
            pid = app.EntryGetID(parent)
            d[pid] = dpt
            dpt -= 1
            if c.has_key(pid):
                c[pid] += 1
            else:
                c[pid] = 1
    items = [(b, d[a], a) for a, b in c.items()]
    items.sort()
    mpid = -1L
    if len(items) > 0:
        c0 = None
        mpid = items[-1][2]
    return mpid


def path_upto_parent(entry, parent_id):
    parent = app.EntryGetParent(entry)
    if parent and app.EntryGetID(parent) != parent_id:
        pp = path_upto_parent(parent, parent_id)
        if pp:
            return pp + u"\\" + app.EntryGetName(entry)
        else:
            return app.EntryGetName(entry)
    elif parent:
        if not app.EntryIsDrive(entry):
            return app.EntryGetName(entry)
        else:
            return app.EntryGetName(entry)[0]
    else:
        return u""
                                

RecoveryRunning = False
RecoverySkip = False

rmtMessage = 1
rmtError = 2
rmtWarning = 3
rmtSuccess = 4

def start_recovery():

    class RecoveryContext:

        def __init__(self):
            self.total_files = 0
            self.total_size = 0L
            self.processed_files = 0
            self.processed_size = 0L
            self.current_file_name = u""    
            self.current_file_progress = 0


    def emit(cls, s):
        app.EmitRecoveryMessage(cls, s)

    def generate_autoname(path):
        for i in xrange(1000):
            fname = path+u"#"+str(i)
            if not os.path.exists(fname):
                return fname
        raise Exception("Unable to generate file name for " + path)

    def uprecurse_uncheck(entry):
        app.UnmarkEntry(entry)
        parent = app.EntryGetParent(entry)
        if parent and not app.EntryHasMarkedChildren(parent):
            app.UnmarkEntry(parent)
            uprecurse_uncheck(parent)


    def copy_file(entry, target_path, context, rparams):
        global RecoverySkip
        recover_all_data_strems = rparams['recover_all_data_strems']
        delete_unsuccessful= rparams['delete_unsuccessful']
        naming = rparams['naming']
        unchecking = rparams['unchecking']
        context.current_file_progress = 0
        RecoverySkip = False
        BULK = 256*1024
        processed_size = 0L
        total_size = 0L
        file_name = None
        has_errors = False
        f = None
        try:
            volume = app.VolumeForEntry(entry)
            mft_ref = app.EntryGetMFTRef(entry)
            if volume and mft_ref >= 0:
                file = volume.open_file(mft_ref)
                if len(file.data_streams) > 1:
                    emit(rmtMessage, STR_KNOWN_DATA_STREAMS+unicode(str(file.data_streams.keys())))
                total_size = reduce(lambda x,y: y.size+x, file.data_streams.values(), 0L)
                for data_stream_name, data_stream in file.data_streams.items():
                    is_alter_stream = len(data_stream_name) > 0
                    if is_alter_stream and not recover_all_data_strems:
                        continue
                    if data_stream_name:
                        context.current_file_name = app.EntryGetName(entry) + u" stream: " + data_stream_name
                    else:
                        context.current_file_name = app.EntryGetName(entry)
                    file_name = target_path
                    if data_stream_name:
                        file_name += u"_"+data_stream_name
                    if os.path.exists(file_name):
                        if naming == 0:
                            file_name = generate_autoname(file_name)
                        elif naming == 1:
                            file_name = app.SaveDlgQuery(file_name)
                            if not file_name:
                                raise Exception(STR_USER_SKIPPED)
                        elif naming == 2:
                            continue
                    f = open(file_name, "wb")
                    pos = 0L
                    count = data_stream.size
                    while count > 0:
                        if not RecoveryRunning:                            
                            raise Exception(STR_USER_CANCELLED)
                        if RecoverySkip:
                            if not is_alter_stream:
                                context.processed_size += count
                            raise Exception(STR_USER_SKIPPED)
                        C = BULK
                        if C > count:
                            C = count
                        try:
                            data = data_stream.read_data(pos, C)
                            pos += C
                            count -= C
                            processed_size += C
                            context.current_file_progress = int(processed_size*100.0/total_size)
                            f.write(data)
                        finally:
                            if not is_alter_stream:
                                context.processed_size += C
                    f.close()
                    f = None
                    if is_alter_stream:
                        emit(rmtSuccess, u"Recovered ok - "+app.EntryGetPath(entry)+ u" stream "+data_stream_name)
                    else:
                        emit(rmtSuccess, u"Recovered ok - "+app.EntryGetPath(entry))
            else:
                raise Exception(STR_CANNOT_OPEN_FILE % (mft_ref, str(volume)))
        except Exception, Value:
            has_errors = True
            emit(rmtError, STR_ERROR_ON % (target_path , str(Value)))
            if f:
                f.close()
            if file_name and delete_unsuccessful:
                try:                    
                    os.remove(file_name)
                except Exception, Value:
                    pass
        context.processed_files += 1
        if (unchecking == 0 and not has_errors) or (unchecking == 1):
            uprecurse_uncheck(entry)                    

    def report_thread(context):
        while RecoveryRunning:
            if context.total_size:
                total_progress = int(context.processed_size*100.0/context.total_size)
                if total_progress > 100:
                    total_progress = 100
                app.NotifyRecoveryProgress(
                    context.current_file_name, 
                    context.current_file_progress, 
                    total_progress, 
                    context.total_files, 
                    context.processed_files, 
                    context.total_files - context.processed_files, 
                    u"unknown", u"unknown", u"unknown")                        
            time.sleep(0.1)
        app.NotifyRecoveryProgress(
            context.current_file_name, 
            context.current_file_progress, 
            100, 
            context.total_files, 
            context.processed_files, 
            context.total_files - context.processed_files, 
            u"unknown", u"unknown", u"unknown")                        
        app.RecoveryPanelDone()


    def recovery():
        global RecoveryRunning, total_files, processed_files
        RecoveryRunning = True
        try:
            app.RecoveryPanelInit()
            rparams = app.GetRecoveryParams()
            recover_folder_structure = rparams['recover_folder_structure']
            dst_folder = rparams["recovery_folder"]
            if not os.path.exists(dst_folder):
                try:
                    os.makedirs(dst_folder)
                except:
                    S = STR_CANNOT_CREATE_FOLDER+dst_folder                    
                    app.ShowMessageModal(S)
                    raise Exception(S)
            c = dst_folder[-1]
            if c != "\\" and c != "/":
                dst_folder += "\\"

            _drv = os.path.abspath(dst_folder)[:2]


            emit(rmtMessage, STR_START_RECOVERY_TO + dst_folder)
            emit(rmtMessage, STR_GEN_FILE_LIST)
            entries = get_checked_entries()
            files = filter(lambda entry: app.EntryIsFile(entry), entries)
            mcpid = get_minimal_common_parent_id(files)

            total_files = len(files)
            total_size = reduce(lambda x, y: app.EntryGetDataSize(y) + x, files, 0L)
            emit(rmtMessage, STR_FILE_LIST_GENERATED % (len(entries), total_files, total_size))
            context = RecoveryContext()
            context.total_files = total_files
            context.total_size = total_size
            thread.start_new_thread(report_thread, (context, ))

            for fe in entries:
                if app.EntryGetPath(fe)[:2].upper() == _drv.upper():
                    if app.ShowYesNoDlg(u"It is not safe to recover some files into the folder you specified, recovered files can be corrupted. Do you want to proceed anyway?") == 7:
                        raise Exception(STR_USER_CANCELLED)
                    else:
                        break

            if len(entries) > 0:
                del entries[0]  # remove .root. node from top
                for entry in files:
                    if not RecoveryRunning:
                        break
                    full_path = None
                    if recover_folder_structure:
                        full_path = dst_folder + path_upto_parent(entry, mcpid)
                    else:
                        full_path = dst_folder + app.EntryGetName(entry)
                    print "UPTO PATH: ", path_upto_parent(entry, mcpid)
                    dirs = u"\\".join(full_path.split(u"\\")[:-1])
                    if not os.path.exists(dirs):
                        print "Create dirs: ", dirs
                        os.makedirs(dirs)
                    copy_file(entry, full_path, context, rparams)
        finally:
            RecoveryRunning = False

    thread.start_new_thread(recovery, ())
    

def recovery_stop():
    global RecoveryRunning
    RecoveryRunning = False    


def recovery_pause():
    app.ShowMessageModal(STR_RECOVERY_PAUSED)


def recovery_skip_current_file():
    global RecoverySkip
    RecoverySkip = True


def execute_script(script_path):
    def _doexec():
        execfile(script_path)
    thread.start_new_thread(_doexec, ())

progress_dlg_cancel = False

def save_as():
    def _do_save_as():
        global progress_dlg_cancel
        progress_dlg_cancel = False
        ff = app.GetFocusedFile()
        if ff:
            file_name = app.SaveDlgQuery(app.EntryGetName(ff))
            if not file_name:
                return
            file_name = os.path.abspath(file_name)
            if file_name[:2].upper() == app.EntryGetPath(ff)[:2].upper():
                if app.ShowYesNoDlg(u"It is not safe to recover the file to destination you specified, recovered files can be corrupted. Do you want to proceed anyway?") == 7:
                    return
            if file_name:
                BULK = 256*1024
                app.ShowProgressDlg(u"Copy...", u"Copy file "+app.EntryGetName(ff)+u" to " + file_name)
                entry = ff
                target_path = file_name
                try:
                    volume = app.VolumeForEntry(entry)
                    mft_ref = app.EntryGetMFTRef(entry)
                    if volume and mft_ref >= 0:
                        file = volume.open_file(mft_ref)
                        total_size = reduce(lambda x,y: y.size+x, file.data_streams.values(), 0L)
                        processed_size = 0L
                        for data_stream_name, data_stream in file.data_streams.items():
                            is_alter_stream = len(data_stream_name) > 0
                            file_name = target_path
                            if data_stream_name:
                                file_name += u"_"+data_stream_name
                            f = open(file_name, "wb")
                            pos = 0L
                            count = data_stream.size
                            while count > 0:
                                if progress_dlg_cancel:                            
                                    raise Exception(STR_USER_CANCELLED)
                                C = BULK
                                if C > count:
                                    C = count
                                data = data_stream.read_data(pos, C)
                                pos += C
                                count -= C
                                processed_size += C
                                f.write(data)
                                perc = int(pos*100.0/data_stream.size)
                                app.NotifyProgressDlg(perc)
                            f.close()
                except:                
                    traceback.print_exc()
                app.HideProgressDlg()
    thread.start_new_thread(_do_save_as, ())

def on_progress_dlg_cancel():
    global progress_dlg_cancel
    progress_dlg_cancel = True

    
def on_application_close():
    global RecoveryRunning, SearchActive, ScannerActive
    RecoveryRunning = False
    SearchActive = False
    ScannerActive = False
