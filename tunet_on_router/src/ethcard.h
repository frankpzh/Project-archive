#ifndef __ETHCARD_H__
#define __ETHCARD_H__

#ifdef _LINUX
	#include <netpacket/packet.h>
	#include <net/ethernet.h>
	#include <sys/ioctl.h>
	#include <sys/types.h>
	#include <net/if.h>
	#include <net/if_packet.h>
	#include <net/if_arp.h>
	
	typedef struct _ETHCARD
	{
		int fd;
		int iface;
	}ETHCARD;
	
#endif

#include "os.h"

#define MAX_ETHCARDS 16

#pragma pack(push, 1)
	typedef struct _ETHCARD_INFO
	{
		CHAR name[255];
		CHAR desc[255];
		CHAR mac[255];
		CHAR ip[255];
		BOOL live;
	}ETHCARD_INFO;

	typedef struct frame_data {
		BYTE dest[6];
		BYTE src[6];
		union
		{
			UINT16 type;
			BYTE types[2];
		};
	}ETH_FRAME;
#pragma pack(pop)
	
typedef VOID ( *ETHCARD_LOOP_RECV_PROC ) (ETHCARD *ethcard, BYTE *pkt_data, INT pkt_len);


typedef struct _ETHCARD_LOOP_RECV_PROC_PARAM
{
	ETHCARD *ethcard;
	ETHCARD_LOOP_RECV_PROC proc;
}ETHCARD_LOOP_RECV_PROC_PARAM;


INT		get_ethcards(ETHCARD_INFO *devices, INT bufsize);
INT		ethcard_send_packet(ETHCARD *ethcard, BYTE *buf, INT len);
VOID	ethcard_start_loop_recv(ETHCARD *ethcard, ETHCARD_LOOP_RECV_PROC proc);
VOID	ethcard_stop_loop_recv();
ETHCARD *ethcard_open(CHAR *name);
ETHCARD *ethcard_close(ETHCARD *ethcard);

VOID	ethcard_init();
VOID	ethcard_cleanup();

#endif
