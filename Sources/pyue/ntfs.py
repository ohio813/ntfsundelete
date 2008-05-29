#    NTFS Undelete
#    Copyright (C) 2008 Atola Technology.
#    http://ntfsundelete.com
#
#    Authors:
#      Alexander Malashonok
#      Fedir Nepyivoda
#
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

import traceback
import threading
import struct
from fstools import *


class CNTFSError(Exception):

    def __init__(self, msg, *args, **kwargs):
        Exception.__init__(self, msg, *args, **kwargs)


class CNTFSBootSectorError(CNTFSError):
    pass


class CNTFSMFTReferenceOverflowError(CNTFSError):
    pass

class CNTFSRelatedError(CNTFSError):
    def __init__(self, msg, related_exception):
        CNTFSError.__init__(self, msg + " (Reason: %s) " % str(related_exception))
        self.related_exception = related_exception

    
def extent_map_from_ntfs_extents(e):
    """
        convert fstools ntfs extent list
        to space.ExtentMap object
    """
    try:
        R = CExtentList()
        for i in xrange(len(e)):
            item = e.get_extent(i)
            R.add_mapping(item.vcn, item.length, item.lcn)
        return R
    except Exception, Value:
        raise CNTFSRelatedError("Cannot convert NTFS extent map", Value)
        


def load_attr_list(linear_space):
    """
        read ATTRIBUTE_LIST object from
        linear space
    """
    if linear_space.size < 256*1024:
        raw_data = linear_space.read_data(0, linear_space.size)
        try:
            return new_ntfs_attrlist_object(raw_data)
        except:
            raise CNTFSError("Invalid AT_ATTRIBUTE_LIST attribute")
    else:
        raise CNTFSError("Invalid attribute list size")


class CNTFSDataStream(CLinearSpace):
    """
        Named linear space class
    """

    def __init__(self, name, linear_space):
        """
            __init__(self, name, linear_space)
        """
        self.__name = name
        self.__linear_space = linear_space

    def get_size(self):
        return self.__linear_space.get_size()

    def _read_data(self, start_pos, count, buffer_size):
        return self.__linear_space._read_data(start_pos, count, buffer_size)

    name = property (lambda self: self.__name)




class CNTFSIndex:
    """
        NTFS index container.

        Attributes:

        entries         - a list of entries in index
        type            - type of indexed entries
        collation_rule  - collation rule
        index_block_size - size of NTFS index block
    """

    def __init__(self, index_block_size=None, collation_rule=None, type=None):
        """__init__(index_block_size=None, collation_rule=None, type=None)"""
        self.__entries = []
        self.__type = type
        self.__collation_rule = collation_rule
        self.__index_block_size = index_block_size
        self.__index_blocks = []

    def __len__(self):
        return len(self.__entries)

    def __getitem__(self, index):
        return self.__entries[index]

    entries = property (lambda self: self.__entries)
    type = property (lambda self: self.__type)
    collation_rule = property (lambda self: self.__collation_rule)
    index_block_size = property (lambda self: self.__index_block_size)
    index_blocks = property (lambda self: self.__index_blocks)


class CNTFSFile:

    def __init__(self, volume, mft_ref):
        self.__volume = volume
        self.__mft_ref = mft_ref

    def open(self):
        try:
            volume = self.__volume
            self.__data_streams = {}
            self.__file_names = {}
            self.__win32_file_names = {}
            self.__ntfs_attributes = []
            self.__mft_records = []
            self.__mft_refs = [self.__mft_ref]
            self.__ntfs_attributes_by_type = {}
            self.__mft_record = mft_record = volume.MFT.load_mft_record(self.__mft_ref)
            self.__is_directory = mft_record.get_flags() & MFT_RECORD_IS_DIRECTORY
            self.__is_deleted = mft_record.get_flags() & MFT_RECORD_IN_USE == 0
            self.__index_allocations = []
            self.__index_roots = []
            self.__std_infos = []
            self.__default_data_stream_size = 0L
            self._init_with_mft_entry(mft_record)
        except CNTFSError, Value:
            raise CNTFSRelatedError("Cannot open file %s" % hex(self.__mft_ref), Value)

    def open_if_base(self):
        try:
            volume = self.__volume
            self.__data_streams = {}
            self.__file_names = {}
            self.__win32_file_names = {}
            self.__ntfs_attributes = []
            self.__mft_records = []
            self.__mft_refs = [self.__mft_ref]
            self.__ntfs_attributes_by_type = {}
            self.__mft_record = mft_record = volume.MFT.load_mft_record(self.__mft_ref)
            if not self.is_base_entry:
                raise CNTFSError("Cannot open file on non-base entry %s" % hex(self.__mft_ref))                
            self.__is_directory = mft_record.get_flags() & MFT_RECORD_IS_DIRECTORY
            self.__is_deleted = mft_record.get_flags() & MFT_RECORD_IN_USE == 0
            self.__index_allocations = []
            self.__index_roots = []
            self.__std_infos = []
            self.__default_data_stream_size = 0L
            self._init_with_mft_entry(mft_record)
        except CNTFSError, Value:
            raise CNTFSRelatedError("Cannot open file %s" % hex(self.__mft_ref), Value)

    def has_file_name(self, file_name):
        return self.__file_names.has_key(file_name)

    def read_indexes(self):
        volume = self.__volume
        indexes = {}
        for index_root in self.__index_roots:
            try:
                index_root_object   = new_ntfs_indexroot_object(index_root.get_content())
                name                = index_root.get_name()
                index_block_size    = index_root_object.get_index_block_size()
                collation_rule      = index_root_object.get_collation_rule()
                type                = index_root_object.get_type()
                index               = CNTFSIndex(index_block_size, collation_rule, type)
                trans = lambda x: (x, None)
                indexes[name] = index
                if type == AT_FILE_NAME:
                    trans = lambda x: (x, new_ntfs_filename_object(x.get_key()))
                for i in xrange(index_root_object.get_count()):
                    index.entries.append(trans(index_root_object.get_entry(i)))
            except:
                raise CNTFSError("Invalid INDEX_ROOT attribute")
        for attr in self.__index_allocations:
            index = None
            index_block_size = self.volume.index_record_size
            trans = lambda x: (x, None)
            if indexes.has_key(name):
                index = indexes[name]
                index_block_size = index.index_block_size
                if index.type != None and index.type == AT_FILE_NAME:
                    trans = lambda x: (x, new_ntfs_filename_object(x.get_key()))
            else: # error case?
                index = CNTFSIndex(None, index_block_size)
                indexes[name] = index
            pos = 0
            ls = attr.linear_space
            while pos < ls.size:
                raw_data = ls.read_data(pos, index_block_size)
                try:
                    index_allocation = new_ntfs_indexblock_object(raw_data, volume.disk.sector_size)
                    index.index_blocks.append(index_allocation)
                except Exception, Value:
                    raise CNTFSError("Invalid INDEX_BLOCK")
                try:
                    for i in xrange(index_allocation.get_count()):
                        index.entries.append(trans(index_allocation.get_entry(i)))
                except:
                    raise CNTFSError("Invalid index entry")
                pos += index_block_size
        return indexes


    def _init_with_mft_entry(self, mft_record):
        volume = self.__volume
        abt = self.__ntfs_attributes_by_type
        self.__mft_records.append(mft_record)
        for i in xrange(mft_record.get_rattr_count()):
            attr = mft_record.get_rattribute(i)
            self.__ntfs_attributes.append(attr)
            tp = attr.get_type()
            if abt.has_key(tp):
                abt[tp].append(attr)
            else:
                abt[tp] = [attr]
            if attr.get_type() == AT_FILE_NAME:
                try:
                    content = attr.get_content()
                    file_name_object = new_ntfs_filename_object(content)
                    fname = file_name_object.get_file_name()
                    self.__file_names[fname] = file_name_object
                    if file_name_object.get_file_name_type() & FILE_NAME_WIN32:
                        self.__win32_file_names[fname] = file_name_object
                except Exception, Value:
                    raise CNTFSRelatedError("Cannot obtain AT_FILE_NAME attribute", Value)
            elif attr.get_type() == AT_DATA:
                content = attr.get_content()
                name = attr.get_name()
                ls = CreateCRefBufferSpace(content)
                if name == "":
                    self.__default_data_stream_size = ls.get_size();
                self.__data_streams[name] = CNTFSDataStream(name, ls)
            elif attr.get_type() == AT_ATTRIBUTE_LIST:
                attr_list = load_attr_list(CreateCRefBufferSpace(attr.get_content()))
                for attr_e in attr_list:
                    mft_ref = attr_e.get_mft_reference() & 0x0000ffffffffffffL
                    if mft_ref != self.__mft_ref:
                        self.__mft_refs.append(mft_ref)
                        rec = volume.MFT.load_mft_record(mft_ref)
                        try:
                            self._init_with_mft_entry(rec)
                        except CNTFSError, Value:
                            raise CNTFSRelatedError("Cannot completelly initialize file, because of related MFT records contain errors", Value)
            #elif attr.get_type() == AT_INDEX_ROOT:
            #    self.__index_roots.append(attr)
            elif attr.get_type() == AT_STANDARD_INFORMATION:
                content = attr.get_content()
                if len(content) > 48:
                    self.__std_infos.append(new_ntfs_stdinfov3_object(content))
                else:
                    self.__std_infos.append(new_ntfs_stdinfo_object(content))
                
        for i in xrange(mft_record.get_nattr_count()):
            attr = mft_record.get_nattribute(i)
            self.__ntfs_attributes.append(attr)
            tp = attr.get_type()
            if abt.has_key(tp):
                abt[tp].append(attr)
            else:
                abt[tp] = [attr]
            extents = extent_map_from_ntfs_extents(attr.get_extents())
            cs = None
            if attr.get_flags() & ATTR_IS_COMPRESSED and attr.get_compression_unit():
                cs = CreateCNTFSCompressedClusterSpace(volume.cluster_space, attr.get_compression_unit())
            else:
                cs = CreateCMappedClusterSpace(volume.cluster_space)
            cs.get_extents().extend(extents)

            #TODO: there is a bug. 
            #must be CreateCClusterLinearizer(cs, attr.get_data_size(), 0)
            ls = CreateCClusterLinearizer(cs, attr.get_data_size(), 0)
            if attr.get_type() == AT_DATA:                
                name = attr.get_name()
                if self.__data_streams.has_key(name):
                    self.__data_streams[name].extents.extend(extents)
                else:
                    self.__data_streams[name] = ds = CNTFSDataStream(name, ls)
                    ds.extents = cs.get_extents()
                if name == "":
                    self.__default_data_stream_size = self.__data_streams[""].size
            elif attr.get_type() == AT_ATTRIBUTE_LIST:
                attr_list = load_attr_list(ls)
                for attr_e in attr_list:
                    mft_ref = attr_e.get_mft_reference() & 0x0000ffffffffffffL
                    self.__mft_refs.append(mft_ref)
                    if mft_ref != self.__mft_ref:
                        rec = volume.MFT.load_mft_record(mft_ref)
                        self._init_with_mft_entry(rec)
            #elif attr.get_type() == AT_INDEX_ALLOCATION:
            #    attr.linear_space = ls
            #    self.__index_allocations.append(attr)

                
    def get_standard_info(self):
        si = self.std_infos
        if len(si) > 0:
            si = si[0]
            return si.get_creation_time(), \
                   si.get_last_data_change_time(), \
                   si.get_last_access_time(), \
                   si.get_last_mft_change_time(), \
                   si.get_file_attributes()
        else:
            return 0L, 0L, 0L, 0L, 0L

    
    mft_ref = property (lambda self: self.__mft_ref)
    base_mft_ref = property (lambda self: self.__mft_record.get_base_mft_record() & 0x0000ffffffffffffL)
    is_base_entry = property (lambda self: self.base_mft_ref == 0)
    data_streams = property (lambda self: self.__data_streams)
    data_stream_list = property (lambda self: self.__data_streams.values())
    data_stream_count = property (lambda self: len(self.__data_streams))
    file_names = property (lambda self: self.__file_names)
    file_name_list = property (lambda self: self.__file_names.values())
    file_name_count = property (lambda self: len(self.__file_names))
    is_directory = property (lambda self: self.__is_directory)
    is_deleted = property (lambda self: self.__is_deleted)
    volume = property (lambda self: self.__volume)
    ntfs_atributes = property (lambda self: self.__ntfs_attributes)
    ntfs_attributes_by_type = property (lambda self: self.__ntfs_attributes_by_type)
    mft_records = property (lambda self: self.__mft_records[:])
    mft_refs = property (lambda self: self.__mft_refs)
    win32_file_names = property (lambda self: self.__win32_file_names)
    win32_file_name_list = property (lambda self: self.__win32_file_names.values())
    win32_file_name_count = property (lambda self: len(self.__win32_file_names))
    mft_record = property (lambda self: self.__mft_record)
    std_infos = property (lambda self: self.__std_infos)
    default_data_stream_size = property (lambda self: self.__default_data_stream_size)

       

class CNTFSMFT(CNTFSFile):
    """
        class for $MFT file
    """


    def __init__(self, volume):
        CNTFSFile.__init__(self, volume, 0)

    def open(self):
        CNTFSFile.open(self)
        self.__main_stream = self.data_streams[""]

    def load_mft_record(self, mft_ref):
        if mft_ref < 0:
            raise CNTFSMFTReferenceOverflowError("Invalid MFT reference access")            
        v = self.volume
        mr = v.mft_record_size
        if mft_ref < 16:
            raw_data = v.linear_space.read_data(v.mft_lcn*v.cluster_size + mr*mft_ref, mr)
            return parse_mft_record(raw_data, v.disk.sector_size)
        else:
            if mft_ref >= self.mft_record_count:
                raise CNTFSMFTReferenceOverflowError("Invalid MFT reference access")
            raw_data = self.data_streams[""].read_data(mr*mft_ref, mr)
            try:
                return parse_mft_record(raw_data, v.disk.sector_size)
            except:
                raise CNTFSError("Invalid MFT entry at %s" % hex(mft_ref))


    mft_record_size = property (lambda self: self.volume.mft_record_size)
    mft_record_count = property (lambda self: self.data_streams[""].size / self.mft_record_size)


class CNTFSVolume:

    def __init__(self, disk, start_sector, sector_count, related_partition = None):
        self.__start_sector = start_sector
        self.__sector_count = sector_count
        self.__related_partition = related_partition
        self.__disk = disk
        self.__lck = threading.Lock()
        #self.initialize()


    def open_file(self, mft_ref):
        self.__lck.acquire()
        try:
            file = CNTFSFile(self, mft_ref)
            file.open()
        finally:
            self.__lck.release()
        return file

    def open_file_if_base(self, mft_ref):
        self.__lck.acquire()
        try:
            file = CNTFSFile(self, mft_ref)
            file.open_if_base()
        finally:
            self.__lck.release()
        return file


    def initialize(self):
        """
        initialize(self)
        Just initialize CNTFSVolume object. Result is None
        or any exception, if has any errors
        """
        disk = self.disk
        self.__boot_sector = boot_sector = ntfs_bootsector_from(disk.read_sectors(self.start_sector, 1))
        if boot_sector.end_of_sector_marker != 0xaa55:
            raise CNTFSBootSectorError("Invalid boot sector marker")
        if boot_sector.oem_id != 0x202020205346544EL:
            raise CNTFSBootSectorError("Invalid OEM ID of NTFS boot sector")           
        if boot_sector.clusters_per_mft_record == 0:
            raise CNTFSBootSectorError("Invalid MFT record size")
        if boot_sector.clusters_per_index_record == 0:
            raise CNTFSBootSectorError("Invalid INDX record size")
        cluster_size = boot_sector.bpb.bytes_per_sector * boot_sector.bpb.sectors_per_cluster
        mft_record_size = 0
        index_record_size = 0
        if boot_sector.clusters_per_mft_record > 0:
            mft_record_size = boot_sector.clusters_per_mft_record * cluster_size
        else:
            mft_record_size = 1 << -boot_sector.clusters_per_mft_record
        if boot_sector.clusters_per_index_record > 0:
            index_record_size = boot_sector.clusters_per_index_record * cluster_size
        else:
            index_record_size = 1 << -boot_sector.clusters_per_index_record
        self.__cluster_space = cluster_space = CreateCDiskClusterizer(disk, boot_sector.bpb.sectors_per_cluster, self.sector_count, self.start_sector)
        self.__linear_space = linear_space = CreateCClusterLinearizer(disk, self.sector_count*disk.sector_size, self.start_sector)
        self.__mft_lcn = mft_lcn = boot_sector.mft_lcn
        self.__mftmirr_lcn = mft_mirr_lcn = boot_sector.mftmirr_lcn                        
        self.__cluster_size = cluster_size
        self.__mft_record_size = mft_record_size
        self.__index_record_size = index_record_size    
        self.__volume_serial_number = boot_sector.volume_serial_number
        self.__number_of_sectors = boot_sector.number_of_sectors
        self.__MFT = CNTFSMFT(self)
        self.__MFT.open()

    def mft_ref_for_path(self, full_file_name_and_path):
        """
        mft_ref_for_path(self, full_file_name_and_path)
        returns mft reference for given existant path, or -1 if 
        path cannot be resolved.
        """
        current_folder = FILE_root
        items = filter(lambda x: x!= u"", unicode(full_file_name_and_path).split("\\"))
        idx = 0
        while True:
            folder = CNTFSFile(self, current_folder)
            folder.open()
            indexes = folder.read_indexes()
            if idx == len(items):
                if folder.has_file_name(items[idx-1]):
                    return current_folder
                else:
                    return -1
            if not folder.is_directory or not indexes.has_key(u"$I30"):
                return -1
            index = indexes[u"$I30"]
            Found = False
            for entry, related_object in index.entries:
                if isinstance(related_object, CNTFSFileNameObject):
                    if related_object.get_file_name() == items[idx]:
                        current_folder = entry.get_indexed_file() & 0x0000ffffffffffffL
                        Found = True
                        idx += 1
                        break
            if not Found:
                return -1
        

                         
    def path_for_mft_ref(self, mft_ref):
        """
        path_for_mft_ref(self, mft_ref)
        returns path for mft reference if possible,
        or None, if path cannot be built.
        """
        R = ""
        f = CNTFSFile(self, mft_ref)
        f.open()
        while mft_ref != FILE_root:            
            if len(f.win32_file_names):
                file_name = f.win32_file_names.keys()[0]
            elif len(f.file_names):
                file_name = f.file_names.keys()[0]
            else:
                return None                
            mft_ref = f.file_names[file_name].get_parent_directory() & 0x0000ffffffffffffL
            f = CNTFSFile(self, mft_ref)
            f.open()
            if not f.is_directory:
                return None
            else:
                R = file_name + "\\" + R
        return "\\" + R

                

    def read_attr_defs(self):
        """
        read_attr_defs(self)
        returns a list of attr_def entries
        in $AttrDef file, or exception, if there
        errors.
        """
        file = CNTFSFile(self, FILE_AttrDef)
        file.open()
        if not file.data_streams.has_key(""):
            raise CNTFSError("$AttrDef file has no default data stream")
        ds = file.data_streams[""]
        sz = ds.size
        if sz % 160 == 0:
            count = sz / 160
            struc = "=" + ("160s"*count)
            data = struct.unpack(struc, ds.read_data(0, sz))
            try:
                return map(lambda x: new_ntfs_attrdef_object(x), data)
            except:
                raise CNTFSError("Invalid ATTR_DEF records in $AttrDef file")
        else:
            raise CNTFSError("Invalid $AttrDef data stream size")            


    def read_volume_information(self):
        """
        read_volume_information(self)
        returns volume_information object
        from $Volume file, or raises an
        exception, if errors.
        """
        file = CNTFSFile(self, FILE_Volume)
        file.open()
        if file.ntfs_attributes_by_type.has_key(AT_VOLUME_INFORMATION):
            attr = file.ntfs_attributes_by_type[AT_VOLUME_INFORMATION][0]
            try:
                return new_ntfs_volumeinformation_object(attr.get_content())
            except:
                raise CNTFSError("Invalid AT_VOLUME_INFORMATION attribute value in file $Volume")
        else:
            raise CNTFSError("File $Volume has no AT_VOLUME_INFORMATION attribute")
        


    cluster_space = property (lambda self: self.__cluster_space)
    linear_space = property (lambda self: self.__linear_space)
    mft_lcn = property (lambda self: self.__mft_lcn)
    mftmirr_lcn = property (lambda self: self.__mftmirr_lcn)
    cluster_size = property (lambda self: self.__cluster_size)
    mft_record_size = property (lambda self: self.__mft_record_size)
    index_record_size = property (lambda self: self.__index_record_size)
    volume_serial_number = property (lambda self: self.__volume_serial_number)
    number_of_sectors = property (lambda self: self.__number_of_sectors)
    MFT = property (lambda self: self.__MFT)
    disk = property(lambda self: self.__disk)
    related_partition = property(lambda self: self.__related_partition)
    start_sector = property (lambda self: self.__start_sector)
    sector_count = property (lambda self: self.__sector_count)



def test():

    """
    import boot
    import partition as prt
    import validate
    import time
    import random
              
                


    def get_logical_partitions(prt_tree):
        R = []
        for partition in prt_tree:
            if isinstance(partition, prt.ExtendedPartition):
                R.extend(get_logical_partitions(partition.partitions))
            else:
                R.append(partition)
        return R


    def process(disk, partition):
        volume = CNTFSVolume(disk, partition.start_sector, partition.sector_count)
        volume.initialize()
        R = []

        T = time.time()
        for i in xrange(volume.MFT.mft_record_count):
            try:
                file = CNTFSFile(volume, i)
                file.open()
                #if file.is_deleted:
                #    R.append(file)
                #volume.MFT.load_mft_record(i)
                #print file.file_names.keys(), file.data_streams.keys()
                if i % 0x100 == 0:
                    print "passed: ", hex(i), disk.get_cache_hits(), disk.get_cache_miss(), "\r", 
            except Exception, Value:
                print "Error at ", hex(i), Value, hex(volume.MFT.mft_record_count)
        print "Time: ", time.time() - T, "Items: ", volume.MFT.mft_record_count

    
    try:        
        logger = validate.StdioLogger()
        disk = CreateCCachedDisk(CreateCOSDisk(u"\\\\.\\PhysicalDrive1"), 7, 64)
        #disk = CreateCCachedDisk(CreateCOSDisk(u"F:\\vmw\\winxp\\Windows XP Professional-flat.vmdk"), 7, 64)
        partitions = get_logical_partitions(prt.PartitionValidator(logger).validate(disk))
        for partition in partitions:
            if partition.partition_type == boot.PARTITION_IFS:
                print "FOUND NTFS at: ", partition.start_sector, partition.sector_count
                process(disk, partition)
                raw_input()
    except Exception, Value:
        print "\n\n***Error : ", Value, "****\n"
        traceback.print_exc()
        raw_input()
    """

    def on_prog(drive_name, volume, pos, percent):
        print "Progreess: ", percent, "\r",

    def on_deleted_file(drive_name, mft_ref, file):
        pass

    disk = CreateCCachedDisk(CreateCOSDisk(u"\\\\.\\X:"), 7, 64)
    volume = CNTFSVolume(disk, 0, disk.sector_count)
    volume.initialize()
    F = volume.open_file(2)
    print F.file_names.keys()
    #scan_ntfs_drive("\\\\.\\C:", {"on_progress": on_prog, "on_scan_deleted_item": on_deleted_file})

if __name__ == '__main__':
    test()