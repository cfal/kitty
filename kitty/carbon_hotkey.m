#include <Cocoa/Cocoa.h>
#include <Carbon/Carbon.h>

#include "glfw-wrapper.h"

static OSType
four_char_code_to_ostype(NSString* code) {
  OSType result = 0;
  NSData* data = [code dataUsingEncoding: NSMacOSRomanStringEncoding];
  [data getBytes:&result length:sizeof(result)];
  return result;
}

#define UNUSED __attribute__ ((unused))

static OSStatus
cocoa_global_hotkey_handler(EventHandlerCallRef nextHandler UNUSED, EventRef anEvent UNUSED, void *userData UNUSED) {
    if ([NSApp isActive]) {
        [NSApp hide:NULL];
    } else {
        NSWindow *ns_window = glfwGetCocoaWindow(glfwGetCurrentContext());
        [ns_window makeKeyAndOrderFront:NULL];
        [NSApp activateIgnoringOtherApps:YES];
    }
    return noErr;
}

void
cocoa_setup_global_hotkey(void) {
    EventHotKeyRef global_hot_key_ref;
    EventHotKeyID global_hot_key_id;
    global_hot_key_id.signature = four_char_code_to_ostype(@"kthk");
    global_hot_key_id.id = 1;
    
    EventTypeSpec event_type;
    event_type.eventClass = kEventClassKeyboard;
    event_type.eventKind = kEventHotKeyPressed;

    InstallApplicationEventHandler(&cocoa_global_hotkey_handler, 1, &event_type, NULL, NULL);

    // 122 is F1
    RegisterEventHotKey(/* inHotKeyCode= */ 122,
                        /* inHotKeyModifiers= */ 0,
                        /* inHotKeyID= */ global_hot_key_id,
                        /* inTarget= */ GetApplicationEventTarget(),
                        /* inOptions= */ 0,
                        /* outRef= */ &global_hot_key_ref);
}
