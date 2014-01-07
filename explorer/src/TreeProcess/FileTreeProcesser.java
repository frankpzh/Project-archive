package TreeProcess;

import java.util.*;
import javax.swing.*;
import javax.swing.event.*;

import AdvancedView.FileItem;


public class FileTreeProcesser implements TreeWillExpandListener {

	public void treeWillCollapse(TreeExpansionEvent event) {
		FolderNode node = (FolderNode) event.getPath().getLastPathComponent();
		switch (node.getType()) {
		case FileItem.COMPUTER:
		case FileItem.ON_LOCAL:
			Enumeration<FolderNode> sons = node.children();
			for (; sons.hasMoreElements();)
				if (!sons.nextElement().isFaked())
					break;
			if (!sons.hasMoreElements())
				node.insertFakeSon();
			break;
		}
	}

	public void treeWillExpand(TreeExpansionEvent event) {
		FolderNode node = (FolderNode) event.getPath().getLastPathComponent();
		switch (node.getType()) {
		case FileItem.COMPUTER:
		case FileItem.ON_LOCAL:
			if (node.isFaked()) {
				Thread waste = new Thread(new TimeWaster((JTree) event
						.getSource()));
				waste.start();
				node.updateSon();
				waste.interrupt();
			}
			break;
		}
	}
}
