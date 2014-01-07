package MenuAction;

import java.net.*;
import java.util.Vector;

import javax.swing.*;
import java.awt.event.*;

import Explorer.ExplorerConfig;
import FtpProcess.*;
import TreeProcess.*;

public class RefreshNetworkListener implements ActionListener, Runnable {
    
    private static Thread check;
    
    private JMenuItem self;
    
    public RefreshNetworkListener(JMenuItem self) {
	this.self = self;
    }
    
    @SuppressWarnings("unchecked")
    public void actionPerformed(ActionEvent e) {
	self.setEnabled(false);
	Vector<FtpClientProxy> sites = (Vector<FtpClientProxy>) ExplorerConfig
	    .getInst().get(ExplorerConfig.CLIENTSITES);
	Explorer.UltraExplorer.treeViewWindow.clearTemp();
	for (int i = 0; i < sites.size(); i++)
	    sites.elementAt(i).checkSite();
	check = new Thread(this);
	check.start();
    }
    
    public void run() {
	try {
	    InetAddress addr = InetAddress.getLocalHost();
	    byte[] ip = addr.getAddress();
	    Debug.DebugStdout.assume(ip.length == 4);
	    FtpClientProxy subnet[] = new FtpClientProxy[254];
	    for (ip[3] = 1; ip[3] != -1; ip[3]++)
		subnet[((int) ip[3] < 0) ? (int) ip[3] + 255 : (int) ip[3] - 1] = new FtpClientProxy(
		    InetAddress.getByAddress(ip), 21);
	    for (int i = 0; i < 254; i++)
		subnet[i].waitCheck();
	} catch (Exception t) {
	} finally {
	    if (Explorer.UltraExplorer.treeViewWindow.getSelectionPath()!=null
		&&Explorer.UltraExplorer.treeViewWindow.getSelectionPath().equals(
			((FolderNode) 
			    ((FolderNode) 
				Explorer.UltraExplorer.treeViewWindow.getModel().getRoot()
			    ).getChildAt(1)
			).getPath()
		    )
		)
		Explorer.UltraExplorer.fileViewer.setDir((FolderNode) Explorer.UltraExplorer.treeViewWindow
		    .getSelectionPath().getLastPathComponent());
	    self.setEnabled(true);
	}
    }
    
}
