# Revision history:

## Revision 1.11  1999/06/28 11:27:40
Tidy-up of the URL display.

## Revision 1.10  1999/03/26 13:49:36
Simplified `handy-url-read-urls' and `handy-url-insert-url'.

## Revision 1.9  1999/03/22 11:54:51
Updated some of the documentation.

## Revision 1.8  1999/03/22 11:34:17
Added optional sorting of the display.

## Revision 1.7  1999/02/10 10:20:21
Fixed a bug that would cause problems if handyurl was called while in the
handyurl buffer.

## Revision 1.6  1999/02/09 01:19:19
Tidy up.

## Revision 1.5  1999/01/22 09:17:33
Modified the format used for inseting URLs, I now use the <URL:..> wrapper.
Added a "naked url insert" operation so that you can get an URL without any
kind of wrapping.

## Revision 1.4  1999/01/17 09:47:20
Changed HANDY-URL so that it can take an optional parameter that specifies a
different URL file.

## Revision 1.3  1998/10/26 15:00:55
Split handy-url-mode functionality from the handy-url function.

## Revision 1.2  1998/10/07 09:38:50
Re-wrote pretty much everything. The format of the URL file is now a lisp
list of cons cells, the car contains the name of the site and the cdr
contains the URL. Also added some extra keystrokes that allow for the
inserting of the URL, the site name or both.

## Revision 1.1  1998/03/20 10:51:47
Initial revision
