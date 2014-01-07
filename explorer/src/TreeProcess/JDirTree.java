package TreeProcess;

import javax.swing.*;
import javax.swing.tree.*;

import AdvancedView.FileItem;
import FtpProcess.*;

public class JDirTree extends JTree {

	private static final long serialVersionUID = 8758020474003853189L;

	public JDirTree(TreeModel model) {
		super(model);
	}

	public void enterNode(FileItem node) {
		TreePath path = getSelectionPath();
		FolderNode oldNode = (FolderNode) path.getLastPathComponent();
		this.expandPath(path);
		int i = oldNode.getFileItemIndex(node);
		if (i == -1)
			Debug.DebugStdout.error("Error at enterNode()!");
		else
			setSelectionPath(((FolderNode)oldNode.getChildAt(i)).getPath());
	}
	
	public void clearTemp() {
		FolderNode now = (FolderNode) this.getModel().getRoot();
		now = (FolderNode) now.getChildAt(1);
		now.clearTemp();
	}

	public synchronized void siteOnline(FtpClientProxy site) {
		FolderNode now = (FolderNode) this.getModel().getRoot();
		now = (FolderNode) now.getChildAt(1);
		for (int i = 0; i < now.getChildCount(); i++)
			if (((FolderNode) now.getChildAt(i)).getFile().ftp == site)
				return;
		now.updateSon(site);
	}

	public void siteOffline(FtpClientProxy site) {
		FolderNode now = (FolderNode) this.getModel().getRoot();
		now = (FolderNode) now.getChildAt(1);
		for (int i = 0; i < now.getChildCount(); i++)
			if (((FolderNode) now.getChildAt(i)).getFile().ftp == site) {
				if (((FolderNode) now.getChildAt(i)).getFile().isTemp())
					now.clearSon(i);
				else
					((FolderNode) now.getChildAt(i)).clearSon();
				return;
			}
	}

    public void killNetwork() {
	FolderNode now = (FolderNode) this.getModel().getRoot();
	now = (FolderNode) now.getChildAt(1);
	if (Explorer.UltraExplorer.treeViewWindow.getSelectionPath() != null)
	    if (now.getPath().isDescendant(Explorer.UltraExplorer.treeViewWindow
	    .getSelectionPath()))
		Explorer.UltraExplorer.treeViewWindow.setSelectionPath(now.getPath());
        now.killSon();
    }

    public void generateNetwork() {
	FolderNode now = (FolderNode) this.getModel().getRoot();
	now = (FolderNode) now.getChildAt(1);
        now.updateSon();
	if (Explorer.UltraExplorer.treeViewWindow != null)
	    ((FolderModel) Explorer.UltraExplorer.treeViewWindow.getModel())
	    .changeNodeAbove(now.getPath());
        Explorer.History.getInst().refresh();
    }

}
