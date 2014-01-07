package FtpProcess;

import java.io.File;


public class NetFile extends File {
    
    private static final long serialVersionUID = 3325376893460599275L;
    
    private File virtual;
    
    private ServerUsers account;
    
    public NetFile(ServerUsers account) {
	super("/");
	virtual = null;
	this.account = account;
    }
    
    public NetFile(NetFile root, File dir, String virtualName) {
	super(dir.getAbsolutePath());
	virtual = new File("/" + virtualName);
	this.account = root.account;
    }
    
    public NetFile(NetFile parent, String child) {
	super(parent, child);
	virtual = new File(parent.virtual, child);
	this.account = parent.account;
    }
    
    public File[] listFiles() {
	File[] res;
	if (virtual != null) {
	    res = super.listFiles();
	    for (int i = 0; i < res.length; i++)
		res[i] = new NetFile(this, res[i].getName());
	} else {
	    ServerUsers.DirMap[] arr=account.getMaps();
	    res = new File[arr.length];
	    for (int i = 0; i < arr.length; i++) {
		res[i] = new NetFile(this, arr[i].getActural(), arr[i] .getVirtual());
	    }
	}
	return res;
    }
    
    public NetFile getRoot() {
	return new NetFile(account);
    }
    
    public String getNetPath() {
	if (virtual == null)
	    return "\\";
	return virtual.getPath();
    }
    
    public String getName() {
	return virtual.getName();
    }
    
    public NetFile parseString(String str) {
	NetFile res;
	if (!str.matches("(/|\\\\)(.*)"))
	    return new NetFile(this, str);
	
	String[] splitted = str.split("(/|\\\\)");
	if (splitted.length <= 1)
	    return this.getRoot();
	
	int index = 0;
	File[] files = this.getRoot().listFiles();
	for (; index < files.length; index++)
	    if (files[index].getName().equals(splitted[1]))
		break;
	
	if (index >= files.length)
	    return new NetFile(this.getRoot(), splitted[1]);
	
	res = (NetFile) files[index];
	for (int i = 2; i < splitted.length; i++)
	    res = new NetFile(res, splitted[i]);
	return res;
    }
    
}
