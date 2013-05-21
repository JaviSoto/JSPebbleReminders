#include "pebble_os.h"
#include "pebble_app.h"
#include "pebble_fonts.h"

#define MY_UUID { 0x3C, 0xB4, 0x32, 0xD0, 0xD2, 0xF8, 0x44, 0x63, 0xA6, 0xC4, 0x36, 0xE0, 0xC5, 0x32, 0xB0, 0x50 }
PBL_APP_INFO(MY_UUID,
             "Reminders", "Javier Soto",
             1, 0, /* App version */
             DEFAULT_MENU_ICON,
             APP_INFO_STANDARD_APP);

Window window;
Window detailWindow;

TextLayer errorTextLayer;
TextLayer fullReminderTitleTextLayer;

SimpleMenuLayer menuLayer;
SimpleMenuSection sections[1];

static const char *appTitle = "Reminder";

#define MAX_REMINDERS 10
#define MAX_REMINDER_TEXT_LENGTH 100
SimpleMenuItem menuItems[MAX_REMINDERS];

// Methods
static void initializeApplication(AppContextRef ctx);
static void messageSentSuccessfullyCallback(DictionaryIterator *sent, void *context);
static void messageSentWithErrorCallback(DictionaryIterator *failed, AppMessageResult reason, void *context);
static void messageReceivedSuccessfullyCallback(DictionaryIterator *received, void *context);
static void messageReceivedWithErrorCallback(void *context, AppMessageResult reason);
static void requestReminders();
static void addMenuItem(int index, char *title);
static char *appMessageResultToString(AppMessageResult reason);
static void simpleMenuItemSelectedCallback(int index, void *context);
static void createMenu(int numElements);

/* DEBUG */

static void displayErrorMessage(char *errorMessage)
{
    text_layer_set_text(&errorTextLayer, errorMessage);
    layer_set_hidden(&errorTextLayer.layer, false);

    vibes_double_pulse();
}

/* INIT */

void pbl_main(void *params)
{
    PebbleAppHandlers handlers =
    {
        .init_handler = &initializeApplication,
        .messaging_info =
        {
            .buffer_sizes =
            {
                .inbound = dict_calc_buffer_size(MAX_REMINDERS, sizeof(char) * MAX_REMINDER_TEXT_LENGTH),
                .outbound = dict_calc_buffer_size(1),
            },
            .default_callbacks.callbacks =
            {
                .out_sent = messageSentSuccessfullyCallback,
                .out_failed = messageSentWithErrorCallback,
                .in_received = messageReceivedSuccessfullyCallback,
                .in_dropped = messageReceivedWithErrorCallback,
            },
        }
    };

    app_event_loop(params, &handlers);
}

static void initializeApplication(AppContextRef ctx)
{
    window_init(&window, appTitle);
    window_stack_push(&window, true);

    // Error text layer
    text_layer_init(&errorTextLayer, window.layer.bounds);
    text_layer_set_text_color(&errorTextLayer, GColorBlack);
    text_layer_set_background_color(&errorTextLayer, GColorWhite);
    text_layer_set_font(&errorTextLayer, fonts_get_system_font(FONT_KEY_GOTHIC_28_BOLD));
    text_layer_set_text_alignment(&errorTextLayer, GTextAlignmentCenter);
    text_layer_set_text(&errorTextLayer, "text");
    layer_add_child(&window.layer, &errorTextLayer.layer);
    layer_set_hidden(&errorTextLayer.layer, true);

    // Start
    requestReminders();
}

/* MESSAGE HANDLING */

static void requestReminders()
{
    Tuplet value = TupletCString(0, "reminders");

    DictionaryIterator *iter;
    app_message_out_get(&iter);

    if (iter == NULL)
        return;

    dict_write_tuplet(iter, &value);
    dict_write_end(iter);

    app_message_out_send();
    app_message_out_release();
}

static void messageSentSuccessfullyCallback(DictionaryIterator *sent, void *context)
{

}

static void messageSentWithErrorCallback(DictionaryIterator *failed, AppMessageResult reason, void *context)
{
    displayErrorMessage("failed to send");
}

static void messageReceivedSuccessfullyCallback(DictionaryIterator *received, void *context)
{
    static int initialized = 0;

    if (initialized == 1)
    {
        displayErrorMessage("Can't load reminders more than once.");
        return;
    }
    
    initialized = 1;

    Tuple *firstElement = dict_read_first(received);

    int index = 0;

    if (firstElement)
    {
        addMenuItem(0, (char *)firstElement->value);
        index++;

        while (1)
        {
            Tuple *nextElement = dict_read_next(received);

            if (!nextElement || index + 1 >= MAX_REMINDERS)
            {
                break;
            }

            char *text = (char *)nextElement->value;

            addMenuItem(index, text);

            index++;
        }    
    }

    createMenu(index);
}

static void messageReceivedWithErrorCallback(void *context, AppMessageResult reason)
{
    displayErrorMessage(appMessageResultToString(reason));
}

/* MENU */

static void addMenuItem(int index, char *title)
{
    menuItems[index] = (SimpleMenuItem){.title = title, .subtitle = NULL, .icon = NULL, .callback = simpleMenuItemSelectedCallback};
}

static void createMenu(int numElements)
{
    // Menu
    sections[0] = (SimpleMenuSection){.items = menuItems, .num_items = numElements, .title = appTitle};

    simple_menu_layer_init(&menuLayer,
                           window.layer.bounds,
                           &window,
                           sections,
                           1,
                           NULL);

    layer_add_child(&window.layer, simple_menu_layer_get_layer(&menuLayer));
}

static void simpleMenuItemSelectedCallback(int index, void *context)
{
    window_init(&detailWindow, "details");
    window_stack_push(&detailWindow, true);

    const char *reminderTextSelected = ((SimpleMenuItem)menuItems[index]).title;

    text_layer_init(&fullReminderTitleTextLayer, detailWindow.layer.bounds);
    text_layer_set_text_color(&fullReminderTitleTextLayer, GColorBlack);
    text_layer_set_background_color(&fullReminderTitleTextLayer, GColorWhite);
    text_layer_set_font(&fullReminderTitleTextLayer, fonts_get_system_font(FONT_KEY_GOTHIC_28_BOLD));
    text_layer_set_text_alignment(&fullReminderTitleTextLayer, GTextAlignmentLeft);
    text_layer_set_text(&fullReminderTitleTextLayer, reminderTextSelected);
    layer_add_child(&detailWindow.layer, &fullReminderTitleTextLayer.layer);
}

/* Helpers */

static char *appMessageResultToString(AppMessageResult reason)
{
    switch (reason)
    {
        case APP_MSG_BUFFER_OVERFLOW:
            return "buffer overflow";
        default:
            return "unknown error";
    }
}