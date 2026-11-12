#include "my_application.h"

#include <gdk/gdk.h>

#include <cstring>

int main(int argc, char** argv) {
  // GTK3 draws its own (client-side) decorations on Wayland, which look out of
  // place on KDE. Run through XWayland there so KWin draws the native title bar.
  const char* desktop = g_getenv("XDG_CURRENT_DESKTOP");
  if (desktop != nullptr && strstr(desktop, "KDE") != nullptr &&
      g_getenv("GDK_BACKEND") == nullptr) {
    gdk_set_allowed_backends("x11,wayland");
  }

  g_autoptr(MyApplication) app = my_application_new();
  return g_application_run(G_APPLICATION(app), argc, argv);
}
