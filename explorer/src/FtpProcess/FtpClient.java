package FtpProcess;

import java.io.*;
import java.net.*;
import java.util.*;

import AdvancedView.FileItem;

public class FtpClient implements Runnable {

	public static final int UNINIT = 0;

	public static final int CONNECTED = 1;

	public static final int READY = 2;

	public static final int LOGINFAILED = 3;

	public static final int DISCONNECTED = 4;

	private static FtpClient inst = null;

	private int port, svrCmd, id;

	private Socket sock, data;

	private ServerSocket dataSvr;

	private InetAddress server;

	private Thread dataLine;

	private BufferedReader cmdIn, dataInChar;

	private BufferedWriter cmdOut;

	private InputStream dataInByte;

	private boolean success;

	private boolean inUse;

	private FileItem para;

	private Vector<FileItem> listResult;

	private int status = UNINIT;

	public synchronized static FtpClient getInst() {
		if (inst == null)
			inst = new FtpClient();
		return inst;
	}

	private FtpClient() {
		dataLine = new Thread(this);
		dataLine.start();
	}

	public void run() {
		byte[] buf = new byte[2048];
		do {
			svrCmd = 0;
			try {
				while (svrCmd == 0) {
					try {
						Thread.sleep(100);
					} catch (Exception e) {
					}
				}
				dataSvr = new ServerSocket(0);
				data = dataSvr.accept();
				dataInByte = data.getInputStream();
				dataInChar = new BufferedReader(new InputStreamReader(
						dataInByte));

				switch (svrCmd) {
				case 1:
					String str;
					Vector<FileItem> res = new Vector<FileItem>();
					while ((str = dataInChar.readLine()) != null) {
						FileItem f = FileItem.parseList(para, str);
						if (f == null) {
							res = null;
							break;
						}
						if (!f.isVirtual())
							res.add(f);
					}
					if (res != null)
						listResult = res;
					else
						listResult = null;
					svrCmd = 0;
					break;
				case 2:
					FileOutputStream fos = new FileOutputStream(para);
					int len = 0;
					while ((len = dataInByte.read(buf, 0, 2048)) > 0)
						fos.write(buf, 0, len);
					fos.close();
					success = true;
					svrCmd = 0;
					break;
				default:
					Debug.DebugStdout.assume(false);
				}

				data.close();
			} catch (Exception e) {
				e.printStackTrace();
				try {
					data.close();
				} catch (Exception t) {
				}
				success = false;
				svrCmd = 0;
			}
		} while (true);
	}

	public void changeServer(InetAddress server, int port) {
		if (status == CONNECTED || status == READY)
			disconnect();
		this.server = server;
		this.port = port;
		status = UNINIT;
	}

	public void disconnect() {
		Debug.DebugStdout.assume(sock != null);
		try {
			data.close();
		} catch (Exception e) {
		}
		try {
			sock.close();
		} catch (Exception e) {
		}
		status = DISCONNECTED;
		sock = null;
	}

	private int getReply() throws IOException {
		String str = cmdIn.readLine(), str1;
		if (str == null)
			return 0;
		int res = new Integer(str.substring(0, 3));
		if (str.charAt(3) != ' ')
			while ((str1 = cmdIn.readLine()).length() < 4
					|| !str1.substring(0, 4).equals(str.substring(0, 3) + ' '))
				;
		return res;
	}

	private void putCmd(String str) throws IOException {
		cmdOut.write(str);
		cmdOut.newLine();
		cmdOut.flush();
	}

	public void connect() throws DisconnectedException {
		Debug.DebugStdout.assume(server != null);
		Debug.DebugStdout.assume(status == UNINIT || status == DISCONNECTED
				|| status == LOGINFAILED);
		try {
			SocketAddress addr = new InetSocketAddress(server, port);
			sock = new Socket();
			sock.setSoTimeout((Integer) Explorer.ExplorerConfig.getInst().get(
					Explorer.ExplorerConfig.CLIENTTIMEOUT));
			sock.connect(addr, (Integer) Explorer.ExplorerConfig.getInst().get(
					Explorer.ExplorerConfig.CLIENTTIMEOUT));
			cmdIn = new BufferedReader(new InputStreamReader(sock
					.getInputStream()));
			cmdOut = new BufferedWriter(new OutputStreamWriter(sock
					.getOutputStream()));
			if (getReply() != 220)
				throw new ReplyErrorException();
		} catch (Exception e) {
			status = DISCONNECTED;
			try {
				sock.close();
			} catch (Exception t) {
			}
			throw new DisconnectedException();
		}
		status = CONNECTED;
	}

	public void login(String user, String pass) throws DisconnectedException {
		Debug.DebugStdout.assume(status == CONNECTED);
		try {
			putCmd("USER " + user);
			int reply = getReply();
			if (reply / 100 == 2)
				status = READY;
			else if (reply / 100 == 3) {
				putCmd("PASS " + pass);
				if (getReply() / 100 == 2)
					status = READY;
				else
					throw new ReplyErrorException();
			} else
				throw new ReplyErrorException();
		} catch (Exception e) {
			status = DISCONNECTED;
			try {
				sock.close();
			} catch (Exception t) {
			}
			throw new DisconnectedException();
		}
	}

	private String addrToStr(byte[] addr, int port) {
		Debug.DebugStdout.assume(addr.length == 4);
		int[] tmp = new int[4];
		for (int i = 0; i < 4; i++)
			tmp[i] = addr[i] + ((addr[i] < 0) ? 256 : 0);
		return tmp[0] + "," + tmp[1] + "," + tmp[2] + "," + tmp[3] + "," + port
				/ 256 + "," + port % 256;
	}

	public Vector<FileItem> chdir(FileItem dir) throws DisconnectedException {
		Debug.DebugStdout.assume(status == READY);
		para = dir;
		svrCmd = 1;
		dataLine.interrupt();
		try {
			Thread.sleep(10);
			putCmd("CWD " + dir.getPath());
			if (getReply() / 100 != 2)
				throw new ReplyErrorException();
			putCmd("PORT "
					+ addrToStr(InetAddress.getLocalHost().getAddress(),
							dataSvr.getLocalPort()));
			if (getReply() / 100 != 2)
				throw new ReplyErrorException();
			putCmd("TYPE A");
			if (getReply() / 100 != 2)
				throw new ReplyErrorException();
			putCmd("LIST");
			int reply = 0;
			while ((reply = getReply()) / 100 == 1)
				;
			if (reply / 100 == 2) {
				while (svrCmd == 1)
					Thread.sleep(10);
				if (listResult == null)
					throw new ReplyErrorException();
				return listResult;
			} else
				throw new ReplyErrorException();
		} catch (Exception e) {
			if (!(e instanceof ReplyErrorException)) {
				status = DISCONNECTED;
				try {
					sock.close();
				} catch (Exception t) {
				}
				throw new DisconnectedException();
			}
			return null;
		}
	}

	public boolean getFile(FileItem dst, FileItem src)
			throws DisconnectedException {
		Debug.DebugStdout.assume(status == READY);
		Debug.DebugStdout.assume(dst.getType() == FileItem.ON_LOCAL);
		Debug.DebugStdout.assume(!dst.isDirectory());
		Debug.DebugStdout.assume(src.getType() == FileItem.ON_NETWORK);
		para = dst;
		svrCmd = 2;
		dataLine.interrupt();
		try {
			Thread.sleep(10);
			putCmd("CWD " + src.getParentFile().getPath());
			if (getReply() / 100 != 2)
				throw new ReplyErrorException();
			putCmd("PORT "
					+ addrToStr(InetAddress.getLocalHost().getAddress(),
							dataSvr.getLocalPort()));
			if (getReply() / 100 != 2)
				throw new ReplyErrorException();
			putCmd("TYPE I");
			if (getReply() / 100 != 2)
				throw new ReplyErrorException();
			putCmd("RETR " + src.getName());
			while (svrCmd == 2)
				Thread.sleep(10);
			int reply = 0;
			while ((reply = getReply()) / 100 == 1)
				;
			if (reply / 100 == 2) {
				return success;
			} else
				throw new ReplyErrorException();
		} catch (Exception e) {
			if (!(e instanceof ReplyErrorException)) {
				status = DISCONNECTED;
				try {
					sock.close();
				} catch (Exception t) {
				}
				throw new DisconnectedException();
			}
			return false;
		}
	}

	public int getStatus() {
		return status;
	}

	public void setID(int newId) {
		id = newId;
	}

	public int getID() {
		return id;
	}

	boolean getInUse() {
		return inUse;
	}

	void setInUse(boolean b) {
		inUse = b;
	}

}
