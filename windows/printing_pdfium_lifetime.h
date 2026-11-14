#ifndef DESKTOP_PRINTING_PDFIUM_LIFETIME_H_
#define DESKTOP_PRINTING_PDFIUM_LIFETIME_H_

#include <fpdfview.h>

// printing and syncfusion_pdfviewer_windows share pdfium.dll. A print/raster
// job must not destroy its global state while the viewer still owns documents.
// Keep that state for the process lifetime; jobs still close their own pages,
// documents and bitmaps. Force-include this header only in printing_plugin.
#define FPDF_DestroyLibrary() ((void)0)

#endif  // DESKTOP_PRINTING_PDFIUM_LIFETIME_H_
