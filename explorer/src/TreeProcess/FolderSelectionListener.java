package TreeProcess;

import javax.swing.event.TreeSelectionEvent;
import javax.swing.event.TreeSelectionListener;

import AdvancedView.FileItem;


public class FolderSelectionListener implements TreeSelectionListener {
    
    public static boolean operating;
    
    public void valueChanged(TreeSelectionEvent e) {
	if (operating) return;
	final FolderNode node = (FolderNode) e.getPath().getLastPathComponent();
	if (node!=null&&node.getType() == FileItem.ON_NETWORK)
	    if (!node.updateSon())
		return;
	if (e.isAddedPath())
	    Explorer.History.getInst().goInto(e.getPath());
    }
    
}
