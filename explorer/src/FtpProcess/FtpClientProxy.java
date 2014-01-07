package FtpProcess;

import java.io.IOException;
import java.io.OutputStreamWriter;
import java.net.*;
import java.util.*;

import TreeProcess.JDirTree;

import AdvancedView.FileItem;

public class FtpClientProxy {
    
    private int port, id;
    
    private boolean online;
    
    private InetAddress addr;
    
    private String user, pass, serverName;
    
    private Thread simpCheck;
    
    private static Thread checkOnline;
    
    public FtpClientProxy(String addr, int port, String name) {
	try {
	    this.addr = InetAddress.getByName(addr);
	} catch (Exception e) {
	    e.printStackTrace();
	}
	this.port = port;
	this.user = "anonymous";
	this.pass = "ultraexplorer";
	serverName = name;
	id=this.hashCode()+this.user.hashCode()+this.pass.hashCode();
	new Thread(new Runnable() {
	    public void run() {
		checkSite();
	    }
	}).start();
    }
    
    public FtpClientProxy(String addr, int port, String user, String pass,
	String name) {
	try {
	    this.addr = InetAddress.getByName(addr);
	} catch (Exception e) {
	    e.printStackTrace();
	}
	this.port = port;
	this.user = user;
	this.pass = pass;
	serverName = name;
	id=this.hashCode()+this.user.hashCode()+this.pass.hashCode();
	new Thread(new Runnable() {
	    public void run() {
		checkSite();
	    }
	}).start();
    }
    
    public FtpClientProxy(InetAddress addr, int port) {
	this.addr = addr;
	this.port = port;
	this.user = "anonymous";
	this.pass = "ultraexplorer";
	id=this.hashCode()+this.user.hashCode()+this.pass.hashCode();
	this.serverName=this.getHostName();
	(simpCheck = new Thread(new simplyCheck())).start();
    }
    
    public void setName(String name) {
	serverName = name;
    }
    
    public void waitCheck() {
	try {
	    while (simpCheck != null && simpCheck.isAlive())
		Thread.sleep(100);
	} catch (Exception e) {
	}
    }
    
    public void checkSite() {
	try {
	    while (checkOnline != null && checkOnline.isAlive())
		Thread.sleep(100);
	} catch (Exception e) {
	}
	checkOnline = new Thread(new checkOnline());
	checkOnline.start();
    }
    
    private void noticeTree() {
	while (Explorer.UltraExplorer.treeViewWindow == null) {
	    try {
		Thread.sleep(100);
	    } catch (Exception e) {
	    }
	}
	JDirTree tree = Explorer.UltraExplorer.treeViewWindow;
	if (online)
	    tree.siteOnline(this);
	else
	    tree.siteOffline(this);
    }
    
    private class simplyCheck implements Runnable {
	public void run() {
	    Socket sock = new Socket();
	    try {
		sock.setSoTimeout(1000);
		sock.connect(new InetSocketAddress(addr, port), 1000);
		if (online = sock.isConnected())
		    noticeTree();
	    } catch (Exception e) {
		online = false;
	    } finally {
		try {
		    sock.close();
		} catch (Exception t) {}
	    }
	}
    }
    
    private class checkOnline implements Runnable {
	public void run() {
	    FtpClient client = FtpClient.getInst();
	    synchronized (client) {
		checkServer(client);
		for (int i = 0; i < 2; i++) {
		    try {
			switch (client.getStatus()) {
			    case FtpClient.UNINIT:
			    case FtpClient.DISCONNECTED:
			    case FtpClient.LOGINFAILED:
				client.connect();
			    case FtpClient.CONNECTED:
				client.login(user, pass);
			    case FtpClient.READY:
				online = true;
				noticeTree();
				releaseServer(client);
				return;
			}
		    } catch (Exception e) {
		    }
		}
		online = false;
		releaseServer(client);
		noticeTree();
	    }
	}
    }
    
    private void checkServer(FtpClient client) {
	while (client.getInUse()) {
	    try{
		Thread.sleep(100);
	    }catch(Exception e){
	    }
	}
	if (client.getID() != id) {
	    client.setID(id);
	    client.changeServer(addr, port);
	}
    }
    
    private void releaseServer(FtpClient client) {
	client.setInUse(false);
    }
    
    public Vector<FileItem> getFiles(FileItem f) {
	if (!online)
	    return null;
	FtpClient client = FtpClient.getInst();
	synchronized (client) {
	    checkServer(client);
	    for (int i = 0; i < 2; i++) {
		try {
		    switch (client.getStatus()) {
			case FtpClient.UNINIT:
			case FtpClient.DISCONNECTED:
			case FtpClient.LOGINFAILED:
			    client.connect();
			case FtpClient.CONNECTED:
			    client.login(user, pass);
			case FtpClient.READY:
			    Vector<FileItem> res = client.chdir(f);
			    if (res==null)
				res=new Vector<FileItem>();
			    releaseServer(client);
			    return res;
		    }
		} catch (Exception e) {
		}
	    }
	    online = false;
	    noticeTree();
	    releaseServer(client);
	    return null;
	}
    }
    
    public boolean transport(FileItem dst, FileItem src) {
	if (!online)
	    return false;
	FtpClient client = FtpClient.getInst();
	synchronized (client) {
	    checkServer(client);
	    for (int i = 0; i < 2; i++) {
		try {
		    switch (client.getStatus()) {
			case FtpClient.UNINIT:
			case FtpClient.DISCONNECTED:
			case FtpClient.LOGINFAILED:
			    client.connect();
			case FtpClient.CONNECTED:
			    client.login(user, pass);
			case FtpClient.READY:
			    releaseServer(client);
			    return client.getFile(dst, src);
		    }
		} catch (Exception e) {
		}
	    }
	    online = false;
	    noticeTree();
	    releaseServer(client);
	    return false;
	}
    }
    
    public boolean isOnline() {
	return online;
    }
    
    public String getHostName() {
	if (serverName != null)
	    return serverName;
	return addr.getHostName();
    }
    
    public void writeToConfig(OutputStreamWriter f) throws IOException {
	f.write("\t\t<Site>\n");
	f.write("\t\t\t<name>"+serverName+"</name>\n");
	f.write("\t\t\t<address>"+addr.getHostAddress()+"</address>\n");
	f.write("\t\t\t<port>"+port+"</port>\n");
	f.write("\t\t\t<username>"+user+"</username>\n");
	f.write("\t\t\t<password>"+pass+"</password>\n");
	f.write("\t\t</Site>\n\n");
    }
    
    public Vector<String> infoOut() {
	Vector<String> res=new Vector<String>();
	res.add(serverName);
	res.add(addr.getHostAddress());
	res.add(((Integer)port).toString());
	res.add(user);
	res.add(pass);
	return res;
    }
    
    public void setUser(String user, String pass) {
	this.user=user;
	this.pass=pass;
	id=this.hashCode()+this.user.hashCode()+this.pass.hashCode();
	Explorer.UltraExplorer.treeViewWindow.siteOffline(this);
    }
    
    public String getUser() {
	return user;
    }
    
    public String getPass() {
	return pass;
    }
    
}
