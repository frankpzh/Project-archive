package AdvancedView;

import java.awt.Component;
import java.io.*;
import java.util.*;
import javax.swing.*;
import javax.imageio.*;

import java.awt.Point;
import java.awt.geom.AffineTransform;
import java.awt.image.*;
import java.util.regex.*;
import javax.swing.filechooser.*;

import Explorer.*;
import FtpProcess.*;
import TreeProcess.TimeWaster;

public class FileItem extends File {
    
    private static final long serialVersionUID = 8158339342598836392L;
    
    public final static int ROOT = 0;
    
    public final static int COMPUTER = 1;
    
    public final static int NETWORK = 2;
    
    public final static int ON_LOCAL = 3;
    
    public final static int ON_NETWORK = 4;
    
    public final static int FAKE_NODE = 5;
    
    public static FileItem choosed;
    
    private int type;
    
    private long size, modified;
    
    private boolean isDir = true, temp,shared;
    
    private Vector<FileItem> sons = null;
    
    private File lastSavedDir = new File("");
    
    public FtpClientProxy ftp = null;
    
    public int getType() {
	return type;
    }
    
    public long lastModified() {
	if (type == ON_LOCAL)
	    return super.lastModified();
	return modified;
    }
    
    public boolean isShared() {
	if (!isDir) return false;
	return shared;
    }
    
    public long length() {
	if (type == ON_LOCAL)
	    return super.length();
	return size;
    }
    
    public boolean isTemp() {
	if (type != ON_NETWORK)
	    return false;
	return temp;
    }
    
    public boolean isFile() {
	if (type == ON_LOCAL)
	    return super.isFile();
	return !isDir;
    }
    
    public File[] listFiles() {
	if (type != ON_NETWORK)
	    return super.listFiles();
	if (sons == null)
	    sons = ftp.getFiles(this);
	FileItem[] res = new FileItem[sons.size()];
	for (int i = 0; i < sons.size(); i++)
	    res[i] = sons.elementAt(i);
	return res;
    }
    
    public Icon getSystemIcon() {
	switch (type) {
	    case COMPUTER:
		return IconCollector.getInst().getIcon(IconCollector.ICONTREE,
		    "local");
	    case NETWORK:
		return IconCollector.getInst().getIcon(IconCollector.ICONTREE,
		    "network");
	    case ON_LOCAL:
		if (this.isFile() || this.isDirectory())
		    return FileSystemView.getFileSystemView().getSystemIcon(
			new File(this.getPath()));
	    case ON_NETWORK:
		if (this.isDirectory())
		    return FileSystemView.getFileSystemView().getSystemIcon(
			new File("temp"));
		else
		    try {
			File tmp = new File("temp\\temp." + this.getExtension());
			FileOutputStream fos = new FileOutputStream(tmp);
			fos.close();
			Icon res = FileSystemView.getFileSystemView()
			.getSystemIcon(tmp);
			tmp.delete();
			return res;
		    } catch (Exception e) {
			return null;
		    }
		
	    default:
		Debug.DebugStdout.assume(false);
		return null;
	}
    }
    
    public Vector<FileItem> listFileItem() {
	Debug.DebugStdout.assume(this.type == ON_NETWORK);
	if (sons == null)
	    sons = ftp.getFiles(this);
	return sons;
    }
    
    public boolean isVirtual() {
	Debug.DebugStdout.assume(this.type == ON_NETWORK);
	if (!isDirectory())
	    return false;
	if (getName().equals("."))
	    return true;
	if (getName().equals(".."))
	    return true;
	return false;
    }
    
    public boolean equals(Object other) {
	if (!super.equals(other))
	    return false;
	return ((FileItem) other).type == type && ((FileItem) other).ftp == ftp;
    }
    
    public boolean isDirectory() {
	if (type == ON_LOCAL)
	    return super.isDirectory();
	return isDir;
    }
    
    public boolean isDisk() {
	return (type == ON_LOCAL) && (getParent() == null);
    }
    
    public boolean isSite() {
	return (type == ON_NETWORK) && (getParent() == null);
    }
    
    public String getExtension() {
	String str = getName();
	int i = str.lastIndexOf(".");
	if (i == -1)
	    return "";
	return str.substring(i + 1, str.length());
    }
    
    public String getName() {
	if (type == COMPUTER)
	    return "My Computer";
	if (type == NETWORK)
	    return "Network";
	if (isDisk())
	    return "Disk " + getPath().substring(0, 1);
	if (isSite())
	    return getHost();
	return super.getName();
    }
    
    public String getPath() {
	String str = super.getPath();
	if (type == ON_NETWORK)
	    str = str.replace('\\', '/');
	return str;
    }
    
    public File getParentFile() {
	File res = super.getParentFile();
	if (type != ON_NETWORK)
	    return res;
	return new FileItem(res.getPath(), ON_NETWORK);
    }
    
    public Icon getIcon() {
	if (type == COMPUTER)
	    return IconCollector.getInst().getIcon(IconCollector.ICONDIRTYPE,
		"computer");
	if (type == NETWORK)
	    return IconCollector.getInst().getIcon(IconCollector.ICONDIRTYPE,
		"network");
	if (this.isDisk()) {
	    String str = FileSystemView.getFileSystemView()
	    .getSystemTypeDescription(new File(getPath()));
	    if (str.indexOf("CD") >= 0)
		return IconCollector.getInst().getIcon(
		    IconCollector.ICONDIRTYPE, "cd");
	    else if (this.isShared())
		return IconCollector.getInst().getIcon(
		    IconCollector.ICONDIRTYPE, "diskshared");
	    else
		return IconCollector.getInst().getIcon(
		    IconCollector.ICONDIRTYPE, "disk");
	}
	if (this.isSite()) {
	    if (this.isTemp())
		return IconCollector.getInst().getIcon(
		    IconCollector.ICONDIRTYPE, "tempsite");
	    else if (ftp.isOnline())
		return IconCollector.getInst().getIcon(
		    IconCollector.ICONDIRTYPE, "siteonline");
	    else
		return IconCollector.getInst().getIcon(
		    IconCollector.ICONDIRTYPE, "siteoffline");
	}
	if (this.isDirectory()) {
	    if (this.isShared())
		return IconCollector.getInst().getIcon(IconCollector.ICONDIRTYPE,
		    "shared");
	    else
		return IconCollector.getInst().getIcon(IconCollector.ICONDIRTYPE,
		    "default");
	} else if (this.isFile())
	    return IconCollector.getInst().getIcon(IconCollector.ICONFILETYPE,
		"default");
	else
	    return IconCollector.getInst().getIcon(IconCollector.ICONFILETYPE,
		"hidden");
    }
    
    public void clearSon() {
	Debug.DebugStdout.assume(getType() == FileItem.ON_NETWORK);
	sons = null;
    }
    
    public String getHost() {
	Debug.DebugStdout.assume(this.type == ON_NETWORK);
	return ftp.getHostName();
    }
    
    public FileItem(FtpClientProxy ftp, boolean always) {
	super("/");
	this.ftp = ftp;
	temp = !always;
	type = ON_NETWORK;
	checkShared();
    }
    
    public FileItem(File f) {
	super(f.getPath());
	type = ON_LOCAL;
	checkShared();
    }
    
    public FileItem(int type) {
	super("/");
	this.type = type;
	if (type==ON_LOCAL)
	    checkShared();
    }
    
    public FileItem(String path, int type) {
	super(path);
	this.type = type;
	if (type==ON_LOCAL)
	    checkShared();
    }
    
    public FileItem(FileItem pre, String name, int type) {
	super(pre, name);
	this.ftp = pre.ftp;
	this.type = type;
	if (type==ON_LOCAL)
	    checkShared();
    }
    
    public Icon makeIcon(int width, int height) {
	BufferedImage img;
	File imgFile;
	switch (type) {
	    case ON_LOCAL:
		if (this.isDirectory()) return null;
		if (this.length()>=10485760) return null;
		imgFile=new File(this.getAbsolutePath());
		break;
	    case ON_NETWORK:
		if (this.isDirectory()) return null;
		if (this.length()>=262144) return null;
		imgFile=new File("temp\\temp."+this.getExtension());
		if (!ftp.transport(new FileItem(imgFile),this))
		    return null;
		break;
	    case COMPUTER:
	    case NETWORK:
		return null;
	    default:
		Debug.DebugStdout.assume(false);
		return null;
	}
	
	try {
	    img = ImageIO.read(imgFile);
	} catch (Exception e) {
	    img = null;
	}
	if (img==null)
	    return null;
	else {
	    double scale=Math.min((double)width/img.getWidth(),(double)height/img.getHeight())*0.95;
	    AffineTransform transform=new AffineTransform();
	    transform.scale(scale,scale);
	    img=new AffineTransformOp(transform,AffineTransformOp.TYPE_BICUBIC).filter(img,null);
	    return new ImageIcon(img);
	}
    }
    
    public void doAction() {
	if (isDirectory())
	    Explorer.UltraExplorer.treeViewWindow.enterNode(this);
	else if (isFile()) {
	    switch (getType()) {
		case FileItem.ON_LOCAL:
		    try {
			Runtime.getRuntime().exec(
			    "cmd /c start \"\" \"" + getAbsolutePath() + "\"");
			wait(10);
		    } catch (Exception e) {
		    }
		    break;
		case FileItem.ON_NETWORK:
		    JFileChooser jfc = new JFileChooser(lastSavedDir);
		    jfc.setSelectedFile(new File(lastSavedDir, getName()));
		    if (jfc.showSaveDialog(Explorer.UltraExplorer.mainWindow) == JFileChooser.APPROVE_OPTION) {
			lastSavedDir = jfc.getSelectedFile().getParentFile();
			Thread waste = new Thread(new TimeWaster(
			    Explorer.UltraExplorer.mainWindow));
			waste.start();
			if (!ftp.transport(new FileItem(jfc.getSelectedFile()),
			    this)) {
			    waste.interrupt();
			    JOptionPane.showMessageDialog(
				Explorer.UltraExplorer.mainWindow,
				"File Download Failed.", "UltraExplorer",
				JOptionPane.ERROR_MESSAGE);
			}
			else
			    waste.interrupt();
		    }
		    break;
		default:
		    Debug.DebugStdout.assume(false);
	    }
	}
    }
    
    public static FileItem parseList(FileItem pre, String line) {
	String[] part = line.split(" +");
	if (part.length == 0)
	    return null;
	if (Pattern.compile("[0-9]").matcher(part[0]).matches())
	    return parseWindows(pre, line);
	else
	    return parseUnix(pre, line);
    }
    
    private static int parseMonth(String str) {
	if (str.equalsIgnoreCase("JAN"))
	    return Calendar.JANUARY;
	if (str.equalsIgnoreCase("FEB"))
	    return Calendar.FEBRUARY;
	if (str.equalsIgnoreCase("MAR"))
	    return Calendar.MARCH;
	if (str.equalsIgnoreCase("APR"))
	    return Calendar.APRIL;
	if (str.equalsIgnoreCase("MAY"))
	    return Calendar.MAY;
	if (str.equalsIgnoreCase("JUN"))
	    return Calendar.JUNE;
	if (str.equalsIgnoreCase("JUL"))
	    return Calendar.JULY;
	if (str.equalsIgnoreCase("AUG"))
	    return Calendar.AUGUST;
	if (str.equalsIgnoreCase("SEP"))
	    return Calendar.SEPTEMBER;
	if (str.equalsIgnoreCase("OCT"))
	    return Calendar.OCTOBER;
	if (str.equalsIgnoreCase("NOV"))
	    return Calendar.NOVEMBER;
	if (str.equalsIgnoreCase("DEC"))
	    return Calendar.DECEMBER;
	return Calendar.JANUARY;
    }
    
    public static FileItem parseUnix(FileItem pre, String line) {
	try {
	    String[] part = line.split(" +", 9);
	    FileItem f = new FileItem(pre, part[8], ON_NETWORK);
	    f.isDir = (part[0].charAt(0) == 'd');
	    f.size = new Long(part[4]);
	    Calendar cal = Calendar.getInstance();
	    cal.set(Calendar.MONTH, parseMonth(part[5]));
	    cal.set(Calendar.DATE, new Integer(part[6]));
	    int i = 0;
	    if ((i = part[7].indexOf(":")) >= 0) {
		cal.set(Calendar.YEAR, Calendar.getInstance().get(Calendar.YEAR));
		cal.set(Calendar.HOUR, new Integer(part[7].substring(0, i)));
		cal.set(Calendar.MINUTE, new Integer(part[7].substring(i + 1,
		    part[7].length())));
	    } else {
		cal.set(Calendar.YEAR, new Integer(part[7]));
		cal.set(Calendar.HOUR, 0);
		cal.set(Calendar.MINUTE, 0);
	    }
	    f.modified = cal.getTime().getTime();
	    return f;
	}catch(Exception e) {
	    return null;
	}
    }
    
    public static FileItem parseWindows(FileItem pre, String line) {
	try {
	    String[] part = line.split(" +", 4);
	    FileItem f = new FileItem(pre, part[3], ON_NETWORK);
	    f.isDir = part[2].equals("<DIR>");
	    if (f.isDir)
		f.size = new Integer(part[2]);
	    f.modified = 0;
	    return f;
	}catch(Exception e) {
	    return null;
	}
    }
    
    public void doRight(Component fat,Point point) {
	choosed=this;
	switch(type) {
	    case ROOT:
	    case COMPUTER:
		return;
	    case NETWORK:
		Explorer.ResourceBuilder.getInst().getPopNetwork().show(fat,point.x,point.y);
		return;
	    case ON_LOCAL:
		if (this.isDirectory())
		    Explorer.ResourceBuilder.getInst().getPopDir().show(fat,point.x,point.y);
		else if (this.isAudio())
		    Explorer.ResourceBuilder.getInst().getAudioDir().show(fat,point.x,point.y);
		return;
	    case ON_NETWORK:
		if (!this.isSite()) return;
		if (temp)
		    Explorer.ResourceBuilder.getInst().getPopTempSite().show(fat,point.x,point.y);
		else
		    Explorer.ResourceBuilder.getInst().getPopSite().show(fat,point.x,point.y);
		return;
	    default:
		Debug.DebugStdout.assume(false);
	}
    }
    
    private void checkShared() {
	Vector<ServerUsers> users=ServerUsers.listInsts();
	for (int i=0;i<users.size();i++) {
	    ServerUsers.DirMap[] maps=users.elementAt(i).getMaps();
	    for (int j=0;j<maps.length;j++)
		if (maps[j].getActural().equals(this)) {
		shared=true;
		return;
		}
	}
    }
    
    public void setTemp(boolean b) {
	temp=b;
    }
    
    public void setShared(boolean b) {
	shared=b;
    }
    
    String pureText() {
	if (this.length()>20480) return null;
	File txtFile;
	switch (type) {
	    case ON_LOCAL:
		if (this.isDirectory()) return null;
		txtFile=new File(this.getAbsolutePath());
		break;
	    case ON_NETWORK:
		if (this.isDirectory()) return null;
		txtFile=new File("temp\\temp");
		if (!ftp.transport(new FileItem(txtFile),this))
		    return null;
		break;
	    case COMPUTER:
	    case NETWORK:
		return null;
	    default:
		Debug.DebugStdout.assume(false);
		return null;
	}
	try {
	    BufferedReader fin=new BufferedReader(new FileReader(txtFile));
	    StringBuffer res=new StringBuffer();
	    String str;
	    while ((str=fin.readLine())!=null) {
		for (int i=0;i<str.length();i++)
		    if (!Character.isDefined(str.charAt(i))) {
		    fin.close();
		    return null;
		    }
		res.append(str+"\n");
	    }
	    fin.close();
	    return res.toString();
	}catch(Exception e) {
	    return null;
	}
    }
    
    private boolean isAudio() {
	String ext=this.getExtension();
	if (ext.equalsIgnoreCase("mp3")) return true;
	if (ext.equalsIgnoreCase("wma")) return true;
	if (ext.equalsIgnoreCase("wav")) return true;
	if (ext.equalsIgnoreCase("mid")) return true;
	return false;
    }
    
}
