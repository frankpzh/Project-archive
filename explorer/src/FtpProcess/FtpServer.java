package FtpProcess;

import java.io.*;
import java.net.*;
import java.util.Calendar;
import java.util.regex.*;

import javax.swing.JOptionPane;

public class FtpServer implements Runnable {
    
    public final static int INIT = 0;
    
    public final static int PORTERROR = 1;
    
    public final static int ONLINE = 2;
    
    private ServerSocket server;
    
    private int status = 0;
    
    private int port;
    
    public FtpServer(int port) {
	this.port = port;
    }
    
    public int getStatus() {
	return status;
    }
    
    public void run() {
	Socket sock;
	try {
	    server = new ServerSocket(port);
	} catch (IOException e) {
	    status = PORTERROR;
	    JOptionPane
		.showMessageDialog(
		Explorer.UltraExplorer.mainWindow,
		java.util.ResourceBundle.getBundle("language").getString("The_specified_port_is_in_use._choose_another_one_in_Network_Setup."),
		"FTP Server", JOptionPane.ERROR_MESSAGE);
	    return;
	}
	while (true) {
	    try {
		sock = server.accept();
	    } catch (Exception e) {
		continue;
	    }
	    new Thread(new ServerConnection(sock)).start();
	}
    }
    
    public void shutDown() {
	try {
	    if (server != null)
		server.close();
	} catch (IOException e) {
	}
    }
    
}

class ServerConnection implements Runnable {
    
    private static final int UNINIT = 0;
    
    private static final int INVALID = 1;
    
    private static final int UNLOGIN = 2;
    
    private static final int HASUSER = 3;
    
    private static final int LOGIN = 4;
    
    private int status = UNINIT;
    
    private Socket sock, data;
    
    private BufferedReader cmdIn;// , dataInAsc;
    
    private BufferedWriter cmdOut, dataOutAsc;
    
    // private InputStream dataInByte;
    
    private OutputStream dataOutByte;
    
    private char type1 = 'A';// , stru = 'F';
    
    private String user, pass;
    
    private SocketAddress client;
    
    private NetFile workDir;
    
    public ServerConnection(Socket sock) {
	this.sock = sock;
	try {
	    cmdIn = new BufferedReader(new InputStreamReader(sock
		.getInputStream()));
	    cmdOut = new BufferedWriter(new OutputStreamWriter(sock
		.getOutputStream()));
	    status = UNLOGIN;
	} catch (IOException e) {
	    status = INVALID;
	}
    }
    
    private boolean openDataConnection() {
	try {
	    data = new Socket();
	    data.setSoTimeout((Integer)Explorer.ExplorerConfig.getInst().get(
		Explorer.ExplorerConfig.SERVERTIMEOUT));
	    data.connect(client);
	    // dataInByte = data.getInputStream();
	    dataOutByte = data.getOutputStream();
	    // dataInAsc = new BufferedReader(new
	    // InputStreamReader(dataInByte));
	    dataOutAsc = new BufferedWriter(new OutputStreamWriter(dataOutByte));
	    return true;
	} catch (IOException e) {
	    closeDataConnection();
	    return false;
	}
    }
    
    private void closeDataConnection() {
	try {
	    data.close();
	} catch (IOException e) {
	}
    }
    
    public void run() {
	if (status != UNLOGIN)
	    return;
	try {
	    sendMsg("220 Welcome to UltraExplorer-buildin FTP site.");
	    String cmd;
	    Matcher match;
	    while ((cmd =getCmd()) != null) {
		if ((match = Pattern.compile("MODE [SBC]").matcher(cmd))
		.matches()) {
		    if ((match = Pattern.compile("MODE S").matcher(cmd))
		    .matches()) {
			sendMsg("200 Command okay.");
		    } else
			sendMsg("504 Command not implemented for that parameter.");
		} else if ((match = Pattern.compile("STRU [FRP]").matcher(cmd))
		.matches()) {
		    if ((match = Pattern.compile("STRU ([F])").matcher(cmd))
		    .matches()) {
			// stru = match.group(1).charAt(0);
			sendMsg("200 Command okay.");
		    } else
			sendMsg("504 Command not implemented for that parameter.");
		} else if ((match = Pattern.compile("TYPE [AEINTC]|(L \\d+)")
		.matcher(cmd)).matches()) {
		    if ((match = Pattern.compile("TYPE ([AIN])").matcher(cmd))
		    .matches()) {
			if (match.group(1).charAt(0) != 'N')
			    type1 = match.group(1).charAt(0);
			sendMsg("200 Command okay.");
		    } else
			sendMsg("504 Command not implemented for that parameter.");
		} else if ((match = Pattern.compile("QUIT").matcher(cmd))
		.matches()) {
		    sock.close();
		    return;
		} else if ((match = Pattern.compile("USER (.+)").matcher(cmd))
		.matches()) {
		    user = match.group(1);
		    status = HASUSER;
		    sendMsg("331 User name okay, need password.");
		} else if ((match = Pattern.compile("PASS (.+)").matcher(cmd))
		.matches()) {
		    if (status != HASUSER) {
			status = UNLOGIN;
			sendMsg("530 Not logged in.");
		    } else {
			pass = match.group(1);
			ServerUsers acc = ServerUsers.findInst(user,
			    ServerUsers.MD5(pass));
			if (acc == null)
			    sendMsg("530 Not logged in.");
			else {
			    sendMsg("230 User logged in, proceed.");
			    workDir = new NetFile(acc);
			    status = LOGIN;
			}
		    }
		} else if ((match = Pattern.compile("CWD (.+)").matcher(cmd))
		.matches()) {
		    if (status != LOGIN)
			sendMsg("530 Not logged in.");
		    else {
			NetFile old = workDir;
			workDir = old.parseString(match.group(1));
			if (!workDir.exists() || !workDir.isDirectory()) {
			    sendMsg("550 No such directory.");
			    workDir = old;
			} else
			    sendMsg("250 Requested file action okay, completed.");
		    }
		} else if ((match = Pattern.compile(
		    "PORT (\\d+),(\\d+),(\\d+),(\\d+),(\\d+),(\\d+)")
		    .matcher(cmd)).matches()) {
		    if (status != LOGIN)
			sendMsg("530 Not logged in.");
		    else {
			byte addr[] = new byte[4];
			addr[0] = new Integer(match.group(1)).byteValue();
			addr[1] = new Integer(match.group(2)).byteValue();
			addr[2] = new Integer(match.group(3)).byteValue();
			addr[3] = new Integer(match.group(4)).byteValue();
			int port = (new Integer(match.group(5))) * 256
			    + new Integer(match.group(6));
			client = new InetSocketAddress(InetAddress
			    .getByAddress(addr), port);
			sendMsg("200 Command okay.");
		    }
		} else if ((match = Pattern.compile("RETR (.+)").matcher(cmd))
		.matches()) {
		    if (status != LOGIN)
			sendMsg("530 Not logged in.");
		    else {
			NetFile retrAddr;
			
			retrAddr = workDir.parseString(match.group(1));
			if (retrAddr.exists() && retrAddr.isFile()) {
			    sendMsg("150 File status okay; about to open data connection.");
			    if (openDataConnection()) {
				if (doRetr(retrAddr))
				    sendMsg("226 Closing data connection.");
				else
				    sendMsg("426 Connection closed; transfer aborted.");
				closeDataConnection();
			    } else
				sendMsg("425 Can't open data connection.");
			} else
			    sendMsg("450 Requested file action not taken.");
		    }
		} else if ((match = Pattern.compile("STOR (.+)").matcher(cmd))
		.matches()) {
		    if (status != LOGIN)
			sendMsg("530 Not logged in.");
		    else {
			sendMsg("550 Permission denied.");
			// to do
		    }
		} else if ((match = Pattern.compile("LIST( (.+))?")
		.matcher(cmd)).matches()) {
		    if (status != LOGIN)
			sendMsg("530 Not logged in.");
		    else {
			NetFile listAddr;
			if (cmd.equals("LIST"))
			    listAddr = workDir;
			else
			    listAddr = workDir.parseString(match.group(2));
			if (listAddr.exists()) {
			    sendMsg("150 File status okay; about to open data connection.");
			    if (openDataConnection()) {
				if (doList(listAddr))
				    sendMsg("226 Closing data connection.");
				else
				    sendMsg("426 Connection closed; transfer aborted.");
				closeDataConnection();
			    } else
				sendMsg("425 Can't open data connection.");
			} else
			    sendMsg("450 Requested file action not taken.");
		    }
		} else if ((match = Pattern.compile("NOOP").matcher(cmd))
		.matches()) {
		    sendMsg("200 Command okay.");
		} else if ((match = Pattern.compile("PWD").matcher(cmd))
		.matches()) {
		    if (status != LOGIN)
			sendMsg("530 Not logged in.");
		    else
			sendMsg("257 \"" + workDir.getNetPath()
			+ "\" is current directory.");
		} else {
		    sendMsg("502 Command not implemented.");
		}
	    }
	} catch (Exception e) {
	    try {
		sock.close();
	    } catch (IOException e1) {
	    }
	}
    }
    
    private boolean doRetr(NetFile retrAddr) {
	try {
	    int i;
	    if (type1 == 'A') {
		char buf[] = new char[2048];
		BufferedReader fin = new BufferedReader(
		    new FileReader(retrAddr));
		while ((i = fin.read(buf)) >= 0)
		    dataOutAsc.write(buf, 0, i);
	    } else {
		byte buf[] = new byte[2048];
		FileInputStream fin = new FileInputStream(retrAddr);
		while ((i = fin.read(buf)) >= 0)
		    dataOutByte.write(buf, 0, i);
	    }
	    return true;
	} catch (IOException e) {
	    return false;
	}
    }
    
    private boolean doList(NetFile listAddr) {
	try {
	    if (listAddr.isFile())
		listSingleFile(listAddr);
	    else {
		File[] files = listAddr.listFiles();
		for (int i = 0; i < files.length; i++)
		    listSingleFile(files[i]);
	    }
	    return true;
	} catch (IOException e) {
	    return false;
	}
    }
    
    private void listSingleFile(File listAddr) throws IOException {
	if (type1 != 'A')
	    throw new IOException();
	String str = (listAddr.isDirectory() ? 'd' : '-') + "r--r--r-- 1 "
	    + user + " group " + listAddr.length() + " "
	    + parseModified(listAddr.lastModified()) + " "
	    + listAddr.getName();
	dataOutAsc.write(str);
	dataOutAsc.newLine();
	dataOutAsc.flush();
    }
    
    private String parseModified(long l) {
	Calendar cal = Calendar.getInstance();
	Calendar now = Calendar.getInstance();
	cal.setTimeInMillis(l);
	return parseMonth(cal.get(Calendar.MONTH))
	+ " "
	    + cal.get(Calendar.DAY_OF_MONTH)
	    + " "
	    + (now.get(Calendar.YEAR) == cal.get(Calendar.YEAR) ? cal
	    .get(Calendar.HOUR_OF_DAY)
	    + ":" + cal.get(Calendar.MINUTE) : cal
	    .get(Calendar.YEAR));
    }
    
    private String parseMonth(int i) {
	switch (i) {
	    case 0:
		return "Jan";
	    case 1:
		return "Feb";
	    case 2:
		return "Mar";
	    case 3:
		return "Apr";
	    case 4:
		return "May";
	    case 5:
		return "Jun";
	    case 6:
		return "Jul";
	    case 7:
		return "Aug";
	    case 8:
		return "Sep";
	    case 9:
		return "Oct";
	    case 10:
		return "Nov";
	    case 11:
		return "Dec";
	    default:
		Debug.DebugStdout.assume(false);
		return "";
	}
    }
    
    private void sendMsg(String str) throws IOException {
	cmdOut.write(str);
	cmdOut.newLine();
	cmdOut.flush();
    }
    
    private String getCmd() throws IOException {
	while(!cmdIn.ready()) {
	    try{
		Thread.sleep(10);
	    }catch(Exception e){}
	}
	return cmdIn.readLine();
    }
}
