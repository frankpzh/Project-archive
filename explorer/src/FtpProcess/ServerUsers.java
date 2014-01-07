package FtpProcess;

import java.io.OutputStreamWriter;
import java.util.*;
import java.io.File;
import java.io.IOException;
import java.security.*;

public class ServerUsers {
    
    private static Vector<ServerUsers> insts = new Vector<ServerUsers>();
    
    private String user, passMD5;
    
    private Map<String,DirMap> maps=new TreeMap<String,DirMap>();
    
    public static Vector<ServerUsers> listInsts() {
	return insts;
    }
    
    public String getUser() {
	return user;
    }
    
    public String getPassMD5() {
	return passMD5;
    }
    
    public static ServerUsers getInst(String user, String passMD5) {
	ServerUsers res = findInst(user, passMD5);
	if (res != null)
	    return res;
	return new ServerUsers(user, passMD5);
    }
    
    public static ServerUsers findInst(String user, String passMD5) {
	for (int i = 0; i < insts.size(); i++)
	    if (insts.elementAt(i).checkUser(user, passMD5))
		return insts.elementAt(i);
	return null;
    }
    
    private ServerUsers(String user, String passMD5) {
	this.user = user;
	this.passMD5 = passMD5;
	insts.add(this);
    }
    
    public boolean addDirMap(String actural, String virtual) {
	DirMap map=new DirMap(actural,virtual);
	if (maps.containsKey(map.virtual)) return false;
	maps.put(map.virtual,map);
	return true;
    }
    
    private boolean checkUser(String user, String passMD5) {
	if (!this.user.equals(user))
	    return false;
	if (this.passMD5 == null)
	    return true;
	return (this.passMD5.equals(passMD5));
    }
    
    public final static String MD5(String s) {
	char hexDigits[] = { '0', '1', '2', '3', '4', '5', '6', '7', '8', '9',
	'a', 'b', 'c', 'd', 'e', 'f' };
	try {
	    MessageDigest mdTemp = MessageDigest.getInstance("MD5");
	    mdTemp.update(s.getBytes());
	    byte[] md = mdTemp.digest();
	    char str[] = new char[md.length * 2];
	    for (int i = 0; i < md.length; i++) {
		str[i * 2] = hexDigits[md[i] >>> 4 & 0xf];
		str[i * 2 + 1] = hexDigits[md[i] & 0xf];
	    }
	    return new String(str);
	} catch (NoSuchAlgorithmException e) {
	    Debug.DebugStdout
		.notice("No MD5 algorithm available, give up encoding.");
	    return s;
	}
    }
    
    public DirMap[] getMaps() {
	int n=maps.keySet().size();
	String[] arr=new String[n];
	DirMap[] res=new DirMap[n];
	maps.keySet().toArray(arr);
	for (int i=0;i<n;i++)
	    res[i]=maps.get(arr[i]);
	return res;
    }
    
    public class DirMap {
	private File actural;
	
	private String virtual;
	
	public DirMap(String actural, String virtual) {
	    this.actural = new File(actural);
	    this.virtual = virtual;
	}
	
	public File getActural() {
	    return actural;
	}
	
	public String getVirtual() {
	    return virtual;
	}
	
	public String getActuralStr() {
	    return actural.getAbsolutePath();
	}
	
	public boolean equals(Object p) {
	    if (!(p instanceof DirMap)) return false;
	    DirMap t=(DirMap)p;
	    return (t.getActural().equals(actural)&&t.getVirtual().equals(virtual));
	}
    }
    
    public static void writeToConfig(OutputStreamWriter f) throws IOException {
	for (int i = 0; i < insts.size(); i++) {
	    if (insts.elementAt(i).user.equals(""))
		continue;
	    f.write("\t\t<Account>\n");
	    f.write("\t\t\t<username>" + insts.elementAt(i).user
		+ "</username>\n");
	    if (insts.elementAt(i).passMD5 != null)
		f.write("\t\t\t<password>" + insts.elementAt(i).passMD5
		    + "</password>\n");
	    DirMap arr[]=insts.elementAt(i).getMaps();
	    for (int j = 0; j < arr.length; j++) {
		f.write("\t\t\t<DirMap>\n");
		f.write("\t\t\t\t<name>"
		    + arr[j].getVirtual()
		    + "</name>\n");
		f.write("\t\t\t\t<original>"
		    + arr[j].getActuralStr()
		    + "</original>\n");
		f.write("\t\t\t</DirMap>\n");
	    }
	    f.write("\t\t</Account>\n\n");
	}
    }
    
    public void rename(String oldName, String newName) {
	DirMap p=maps.get(oldName);
	p.virtual=newName;
	maps.remove(oldName);
	maps.put(newName,p);
    }
    
    public void delete(String string) {
	maps.remove(string);
    }
    
    public void setUser(String string) {
	user=string;
    }
    
    public void setPassMD5(String string) {
	passMD5=string;
    }
    
}
