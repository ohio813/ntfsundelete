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


STR_NOT_AVAIL = u"Not available"
STR_DRV_ACCES_ERROR = u"Drive access error. Reason: %s"
STR_CANNOT_OPEN_NTFS_VOLUME = u"This volume looks like non-NTFS. Cannot perform scanning."
STR_GENERAL_INFO_TEMPLATE = """
    <html>
    <head>
        <link rel=stylesheet href="file://%s//reports-style.css" type="text/css">
    </head>
    <body>
    <table>
    <tr><td colspan="2"><b>General information:</b></td></tr>
    <tr><td>MFT reference:</td><td>%s</td></tr>
    <tr><td>File location:</td><td>%s</td></tr>
    <tr><td>Data streams:</td><td>%s</td></tr>
    <tr><td>Deleted:</td><td>%s</td></tr>
    <tr><td>Number of used MFT records:</td><td>%s</td></tr>
    <tr><td colspan=2><br/></td></tr>
    <tr><td colspan=2><b>Details:</b></td></tr>
    %s    
    </table>
    </body>
    </html>
    """

STR_SEARCH_COMPLETE = u"Search complete. Found %s items "
STR_NON_NTFS_DRIVE = u"Volume %s looks like non-NTFS. Cannot perform search."
STR_KNOWN_DATA_STREAMS = u"Known data streams: "
STR_USER_SKIPPED = "User skipped"
STR_USER_CANCELLED = "User cancelled"
STR_CANNOT_OPEN_FILE = "cannot open file %s on volume %s"
STR_ERROR_ON = u"Error on %s: %s"
STR_CANNOT_CREATE_FOLDER = "Cannot create folder "
STR_START_RECOVERY_TO = u"Start recovery to "
STR_GEN_FILE_LIST = u"Genegating file list. Wait..."
STR_FILE_LIST_GENERATED = u"File list generated - %s entries, %s files, total size: %s bytes"
STR_RECOVERY_PAUSED = u"Recovery process paused. Press Ok button to continue."
