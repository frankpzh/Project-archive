#include <ctype.h>
#include <termios.h>
#include <fcntl.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

#include "os.h"
#include "des.h"
#include "md5.h"
#include "logs.h"
#include "tunet.h"
#include "dot1x.h"
#include "ethcard.h"
#include "userconfig.h"
#include "util.h"
#include "setting.h"
#include "mytunetsvc.h"

int main(int argc, char *argv[])
{
	mytunetsvc_get_user_config(&g_UserConfig);
	if ((argc != 1) || (!strlen(g_UserConfig.szUsername)))
	{
		ETHCARD_INFO ethcards[16];
		INT ethcardcount;
		
		INT i, usedot1x, language, limitation;
		CHAR *username, *password, *adapter;

		CHAR inputbuf[1024], *p;
		struct termios term, termsave;
		
		ethcardcount = get_ethcards(ethcards, sizeof(ethcards));
		
		if ((argc != 7) || strcmp(argv[1], "set"))
		{
			puts( " MyTunet Service Program\n");

			puts(" Your Network Devices:");
			for (i = 0;i < ethcardcount; i++)
			{
				printf("    %d. %s\n", i, ethcards[i].desc);
			}
			puts("");
			puts(" Usage: mytunet set <adapter_index> <username> <0/1 (need 802.1x?)>\n"
					"                    <C/E (language)> <C/D/N (Campus/Domestic/NoLimit)>\n"
					"          (then you will input the password separetely.)\n"
					"\n"
					"  For example:  mytunet set 0 wang 1 C D\n"
					"   \n"
					"    will set the logon information like this:\n"
					"     - use the first network device,\n"
					"     - username is \'wang\',\n"
					"     - use 802.1x authorization(ONLY for Zijing 1# - 13# users),\n"
					"     - language is Chinese,\n"
					"     - open the connection for Domestic.\n"
					"\n"
					"    then mytunet will prompt you to input the password.\n");
			return 1;
		}

		i = 2;
		adapter = ethcards[atoi(argv[i++])].name;
		username = argv[i++];

		usedot1x = atoi(argv[i++]);
	
		switch(tolower(argv[i++][0]))
		{
			case 'e':
				language = 0;
				break;
			case 'c':
				language = 1;
				break;
			default:
				language = 0;
				break;
		}
	
		switch(tolower(argv[i++][0]))
		{
			case 'c':
				limitation = LIMITATION_CAMPUS;
				break;
			case 'd':
				limitation = LIMITATION_DOMESTIC;
				break;
			case 'n':
				limitation = LIMITATION_NONE;
				break;
			default:
				limitation = LIMITATION_DOMESTIC;
				break;
		}

		printf("Password:");
		tcgetattr(STDIN_FILENO, &term);
		tcgetattr(STDIN_FILENO, &termsave);
		term.c_lflag &= ~(ECHO);
		tcsetattr(STDIN_FILENO, TCSANOW, &term);
		fgets(inputbuf, sizeof(inputbuf), stdin);
		inputbuf[sizeof(inputbuf) - 1] = 0;
		tcsetattr(STDIN_FILENO, TCSANOW, &termsave);

		for(p = inputbuf + strlen(inputbuf) - 1; *p == '\n' || *p == '\r'; p--)
			*p = 0;
		puts("");

		password = inputbuf;

		mytunetsvc_set_user_config(username, password, 0, adapter, limitation, language, usedot1x, 0);
		return 0;
	}
	mytunetsvc_init();
	mytunetsvc_main();
	mytunetsvc_cleanup();
	return 0;
}
