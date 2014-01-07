#ifndef _MYTUNETSVC_H_
#define _MYTUNETSVC_H_

#include "os.h"
#include "userconfig.h"

void mytunetsvc_init();
void mytunetsvc_cleanup();
int mytunetsvc_login();
int mytunetsvc_logout();
void mytunetsvc_main();

INT WINAPI mytunetsvc_set_user_config(CHAR *username, CHAR *password, BOOL isMD5Pwd, CHAR *adapter, INT limitation, INT language, BOOL usedot1x, BOOL retrydot1x);
INT WINAPI mytunetsvc_get_user_config(USERCONFIG *uc);

#define MYTUNET_SERVICE_NAME    "MyTunetSvc"
#define MYTUNET_SERVICE_DESC    "MyTunet, an unoffical Tsinghua Network Logon Program"

#define MYTUNET_SERVICE_LOGIN   (128 + 1)
#define MYTUNET_SERVICE_LOGOUT  (128 + 2)

#endif
