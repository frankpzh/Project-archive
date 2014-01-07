package TreeProcess;

import java.io.*;
import java.awt.*;
import javax.swing.*;
import javax.swing.tree.*;
import javax.swing.filechooser.*;

import AdvancedView.FileItem;

import Explorer.IconCollector;


public class FolderRenderer extends DefaultTreeCellRenderer implements
    TreeCellRenderer {
    
    private static final long serialVersionUID = 3788761964379960628L;
    
    private JLabel item;
    
    public FolderRenderer() {
	super();
    }
    
    public Component getTreeCellRendererComponent(JTree tree, Object value,
	boolean selected, boolean expanded, boolean leaf, int row,
	boolean hasFocus) {
	item = (JLabel) super.getTreeCellRendererComponent(tree, value,
	    selected, expanded, leaf, row, hasFocus);
	
	if (Explorer.UltraExplorer.msyh != null)
	    item.setFont(Explorer.UltraExplorer.msyh);
	
	Icon icon = null;
	IconCollector set = IconCollector.getInst();
	switch (((FolderNode) value).getType()) {
	    case FileItem.ROOT:
		icon = set.getIcon(IconCollector.ICONTREE, "world");
		break;
	    case FileItem.COMPUTER:
		icon = set.getIcon(IconCollector.ICONTREE, "local");
		break;
	    case FileItem.NETWORK:
		icon = set.getIcon(IconCollector.ICONTREE, "network");
		break;
	    case FileItem.ON_LOCAL:
		if (((FolderNode) ((FolderNode) value).getParent()).getType() == FileItem.COMPUTER) {
		    String str = FileSystemView.getFileSystemView()
		    .getSystemTypeDescription(
			new File(((FolderNode) value).getFile()
			.getPath()));
		    if (str.indexOf("CD") >= 0)
			icon = set.getIcon(IconCollector.ICONTREE, "cd");
		    else if (((FolderNode) value).getFile().isShared())
			icon = set.getIcon(IconCollector.ICONTREE, "diskshared");
		    else
			icon = set.getIcon(IconCollector.ICONTREE, "disk");
		} else {
		    if (((FolderNode) value).getFile().isShared()) {
			if (expanded)
			    icon = set.getIcon(IconCollector.ICONTREE, "folderopenshared");
			else
			    icon = set.getIcon(IconCollector.ICONTREE, "foldershared");
		    } else {
			if (expanded)
			    icon = set.getIcon(IconCollector.ICONTREE, "folderopen");
			else
			    icon = set.getIcon(IconCollector.ICONTREE, "folder");
		    }
		}
		break;
	    case FileItem.ON_NETWORK:
		if (((FolderNode) ((FolderNode) value).getParent()).getType() == FileItem.NETWORK) {
		    if (((FolderNode) value).getFile().ftp.isOnline())
			icon = set.getIcon(IconCollector.ICONTREE, "siteonline");
		    else
			icon = set.getIcon(IconCollector.ICONTREE, "siteoffline");
		} else if (expanded)
		    icon = set.getIcon(IconCollector.ICONTREE, "netfolderopen");
		else
		    icon = set.getIcon(IconCollector.ICONTREE, "netfolder");
		break;
	}
	item.setIcon(icon);
	
	return item;
    }
    
}
