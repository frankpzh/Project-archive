package TreeProcess;

import java.io.*;
import java.util.*;
import javax.swing.tree.*;

import AdvancedView.FileItem;
import Explorer.ExplorerConfig;
import FtpProcess.*;

public class FolderNode implements TreeNode, Comparable<FolderNode> {
    static private FolderNode root = null;
    
    private TreePath path;
    
    private FileItem current;
    
    private FolderNode father;
    
    private Vector<FolderNode> sons = new Vector<FolderNode>();
    
    public Enumeration<FolderNode> children() {
	return Collections.enumeration(sons);
    }
    
    public boolean getAllowsChildren() {
	return true;
    }
    
    public TreeNode getChildAt(int childIndex) {
	return sons.elementAt(childIndex);
    }
    
    public int getChildCount() {
	return sons.size();
    }
    
    public int getIndex(TreeNode node) {
	for (int i = 0; i < sons.size(); i++)
	    if (sons.elementAt(i) == node)
		return i;
	return -1;
    }
    
    public int getFileItemIndex(FileItem node) {
	for (int i = 0; i < sons.size(); i++)
	    if (sons.elementAt(i).current.equals(node))
		return i;
	return -1;
    }
    
    public TreePath getPath() {
	return path;
    }
    
    public TreeNode getParent() {
	return father;
    }
    
    public boolean isLeaf() {
	return (sons.size() == 0);
    }
    
    public boolean isFaked() {
	if (sons.size() == 0)
	    return true;
	if (sons.size() == 1
	    && sons.elementAt(0).getType() == FileItem.FAKE_NODE)
	    return true;
	return false;
    }
    
    public void insertFakeSon() {
	sons.clear();
	switch (current.getType()) {
	    case FileItem.ROOT:
	    case FileItem.FAKE_NODE:
		Debug.DebugStdout.error("Bad use of insertFakeSon.");
		break;
	    case FileItem.COMPUTER:
	    case FileItem.NETWORK:
		sons.add(new FolderNode(this, new FileItem(FileItem.FAKE_NODE)));
		break;
	    case FileItem.ON_LOCAL:
		int i;
		sons.clear();
		File[] folders = current.listFiles();
		if (folders != null) {
		    for (i = 0; i < folders.length; i++)
			if (folders[i].isDirectory())
			    break;
		    if (i < folders.length)
			sons.add(new FolderNode(this, new FileItem(
			    FileItem.FAKE_NODE)));
		}
		break;
	    case FileItem.ON_NETWORK:
	    default:
		Debug.DebugStdout.assume(false);
	}
	if (Explorer.UltraExplorer.treeViewWindow != null)
	    ((FolderModel) Explorer.UltraExplorer.treeViewWindow.getModel())
	    .changeNodeAbove(path);
    }
    
    @SuppressWarnings("unchecked")
	public boolean updateSon() {
	switch (current.getType()) {
	    case FileItem.COMPUTER:
		sons.clear();
		File[] disks = File.listRoots();
		for (int i = 0; i < disks.length; i++)
		    sons.add(new FolderNode(this, new FileItem(disks[i])));
		break;
	    case FileItem.ON_LOCAL:
		sons.clear();
		File[] folders = current.listFiles();
		for (int i = 0; i < folders.length; i++)
		    if (folders[i].isDirectory())
			sons.add(new FolderNode(this, new FileItem(folders[i])));
		Collections.sort(sons);
		break;
	    case FileItem.ON_NETWORK:
		sons.clear();
		Vector<FileItem> dirs = current.listFileItem();
		if (dirs == null)
		    return false;
		else {
		    for (int i = 0; i < dirs.size(); i++)
			if (dirs.elementAt(i).isDirectory())
			    sons.add(new FolderNode(this, dirs.elementAt(i)));
		    Collections.sort(sons);
		}
		break;
	    case FileItem.NETWORK:
		Vector<FtpClientProxy> sites = (Vector) ExplorerConfig
		    .getInst().get(ExplorerConfig.CLIENTSITES);
		for (int i = 0; i < sites.size(); i++)
		    this.sons.add(new FolderNode(this, new FileItem(sites
			.elementAt(i), true)));
		break;
	    case FileItem.ROOT:
	    case FileItem.FAKE_NODE:
	    default:
		Debug.DebugStdout.assume(false);
		break;
	}
	if (Explorer.UltraExplorer.treeViewWindow != null)
	    ((FolderModel) Explorer.UltraExplorer.treeViewWindow.getModel())
	    .changeNodeAbove(path);
	return true;
    }
    
    public void updateSon(FtpClientProxy ftp) {
	Debug.DebugStdout.assume(current.getType() == FileItem.NETWORK);
	sons.add(new FolderNode(this, new FileItem(ftp, false)));
	((FolderModel) Explorer.UltraExplorer.treeViewWindow.getModel())
	.changeNodeAbove(path);
    }
    
    public void clearSon() {
	Debug.DebugStdout.assume(current.getType() == FileItem.ON_NETWORK);
	Debug.DebugStdout.assume(father.current.getType() == FileItem.NETWORK);
	boolean b=Explorer.UltraExplorer.treeViewWindow.getSelectionPath() != null&&
	    path.isDescendant(Explorer.UltraExplorer.treeViewWindow.getSelectionPath());
	if (b) {
	    Explorer.UltraExplorer.treeViewWindow.collapsePath(father.path);
	    Explorer.UltraExplorer.treeViewWindow.setSelectionPath(father.path);
	}
	sons.clear();
	current.clearSon();
	if (Explorer.UltraExplorer.treeViewWindow != null)
	    ((FolderModel) Explorer.UltraExplorer.treeViewWindow.getModel())
	    .changeNodeAbove(path);
	if (b) Explorer.History.getInst().goInto(father.path);
    }
    
    public void clearSon(int i) {
	Debug.DebugStdout.assume(current.getType() == FileItem.NETWORK);
	boolean b=Explorer.UltraExplorer.treeViewWindow.getSelectionPath() != null&&
	    sons.elementAt(i).path.isDescendant(Explorer.UltraExplorer.treeViewWindow
	    .getSelectionPath());
	if (b) Explorer.UltraExplorer.treeViewWindow.setSelectionPath(path);
	sons.remove(i);
	if (Explorer.UltraExplorer.treeViewWindow != null)
	    ((FolderModel) Explorer.UltraExplorer.treeViewWindow.getModel())
	    .changeNodeAbove(path);
	if (b) Explorer.History.getInst().goInto(path);
    }
    
    public void clearTemp() {
	Debug.DebugStdout.assume(current.getType() == FileItem.NETWORK);
	for (int i = 0; i < sons.size(); i++)
	    if (sons.get(i).current.isTemp()) {
	    sons.remove(i);
	    i--;
	    }
	((FolderModel) Explorer.UltraExplorer.treeViewWindow.getModel())
	.changeNodeAbove(path);
    }
    
    public int getType() {
	return current.getType();
    }
    
    public FileItem getFile() {
	return current;
    }
    
    public FolderNode() {
	if (!(root == null))
	    Debug.DebugStdout.error("Root has been redefined.");
	
	root = this;
	father = null;
	sons.clear();
	path = new TreePath(this);
	current = new FileItem(FileItem.ROOT);
	
	if (!sons.add(new FolderNode(root, new FileItem(FileItem.COMPUTER))))
	    Debug.DebugStdout.error("Insert failed.");
	if (!sons.add(new FolderNode(root, new FileItem(FileItem.NETWORK))))
	    Debug.DebugStdout.error("Insert failed.");
    }
    
    @SuppressWarnings("unchecked")
    public FolderNode(FolderNode pre, FileItem addr) {
	father = pre;
	current = addr;
	path = pre.path.pathByAddingChild(this);
	sons.clear();
	switch (addr.getType()) {
	    case FileItem.ON_LOCAL:
	    case FileItem.COMPUTER:
		insertFakeSon();
		return;
	    case FileItem.NETWORK:
		this.updateSon();
		return;
	    case FileItem.ON_NETWORK:
		return;
	    case FileItem.FAKE_NODE:
		return;
	    default:
		Debug.DebugStdout.assume(false);
	}
    }
    
    public String toString() {
	switch (current.getType()) {
	    case FileItem.ROOT:
		return java.util.ResourceBundle.getBundle("language").getString("The_World");
	    case FileItem.COMPUTER:
		return java.util.ResourceBundle.getBundle("language").getString("My_Computer");
	    case FileItem.NETWORK:
		return java.util.ResourceBundle.getBundle("language").getString("Sites_on_Network");
	    case FileItem.ON_LOCAL:
		return current.getName().toString();
	    case FileItem.ON_NETWORK:
		if (father.current.getType() == FileItem.NETWORK)
		    return current.getHost();
		else
		    return current.getName().toString();
	    case FileItem.FAKE_NODE:
		return "fake node";
	    default:
		Debug.DebugStdout.assume(false);
		return "";
	}
    }
    
    public int compareTo(FolderNode other) {
	return toString().compareToIgnoreCase(other.toString());
    }
    
    void killSon() {
	Debug.DebugStdout.assume(this.getType()==FileItem.NETWORK);
	sons.clear();
    }
}
