package Explorer;

import java.util.*;
import javax.swing.*;
import java.awt.event.*;

import javax.swing.tree.*;

import TreeProcess.FolderNode;
import TreeProcess.JDirTree;

import AdvancedView.FileItem;
import AdvancedView.JFileViewer;


public class History {

	private static History inst = null;

	private static int pointer;

	private static boolean inRecursive=false; 
	
	private static Vector<TreePath> history;

	private static Vector<AbstractButton> backButton, forwardButton, upButton;

	public static History getInst() {
		if (inst == null)
			inst = new History();
		return inst;
	}

	private History() {
		pointer = 0;
		history = new Vector<TreePath>();
		backButton=new Vector<AbstractButton>();
		forwardButton=new Vector<AbstractButton>();
		upButton=new Vector<AbstractButton>();
	}

	public void addBack(AbstractButton btn) {
		btn.addActionListener(new ActionListener() {
			public void actionPerformed(ActionEvent e) {
				back();
			}
		});
		backButton.add(btn);
	}

	public void addForward(AbstractButton btn) {
		btn.addActionListener(new ActionListener() {
			public void actionPerformed(ActionEvent e) {
				forward();
			}
		});
		forwardButton.add(btn);
	}

	public void addUp(AbstractButton btn) {
		btn.addActionListener(new ActionListener() {
			public void actionPerformed(ActionEvent e) {
				up();
			}
		});
		upButton.add(btn);
	}

	public void goInto(TreePath p) {
		JFileViewer viewer = Explorer.UltraExplorer.fileViewer;
		viewer.setDir((FolderNode) p.getLastPathComponent());
		if (inRecursive) return;
		if (pointer>0&&p.equals(history.elementAt(pointer-1))) return;
		while (pointer != history.size())
			history.remove(history.size() - 1);
		history.add(p);
		pointer=history.size();
		refreshButton();
	}

	public boolean couldBack() {
		return pointer > 1;
	}

	public boolean couldForward() {
		return pointer < history.size();
	}

	public boolean couldUp() {
		return ((FolderNode) history.elementAt(pointer - 1)
				.getLastPathComponent()).getType() != FileItem.ROOT;
	}

	public void back() {
		JDirTree tree=Explorer.UltraExplorer.treeViewWindow;
		JFileViewer viewer = Explorer.UltraExplorer.fileViewer;
		inRecursive=true;
		if (couldBack()) {
			pointer--;
			tree.setSelectionPath(history.elementAt(pointer - 1));
			viewer.setDir((FolderNode) history.elementAt(pointer - 1)
					.getLastPathComponent());
		}
		refreshButton();
		inRecursive=false;
	}

	public void forward() {
		JDirTree tree=Explorer.UltraExplorer.treeViewWindow;
		JFileViewer viewer = Explorer.UltraExplorer.fileViewer;
		inRecursive=true;
		if (couldForward()) {
			pointer++;
			tree.setSelectionPath(history.elementAt(pointer - 1));
			viewer.setDir((FolderNode) history.elementAt(pointer - 1)
					.getLastPathComponent());
		}
		refreshButton();
		inRecursive=false;
	}

	public void up() {
		JDirTree tree=Explorer.UltraExplorer.treeViewWindow;
		JFileViewer viewer = Explorer.UltraExplorer.fileViewer;
		inRecursive=true;
		TreePath p = history.elementAt(pointer - 1).getParentPath();
		tree.setSelectionPath(p);
		viewer.setDir((FolderNode) p.getLastPathComponent());
		while (pointer != history.size())
			history.remove(history.size() - 1);
		history.add(p);
		pointer=history.size();
		refreshButton();
		inRecursive=false;
	}

	public void refresh() {
		JDirTree tree=Explorer.UltraExplorer.treeViewWindow;
		JFileViewer viewer = Explorer.UltraExplorer.fileViewer;
		TreePath p = history.elementAt(pointer - 1);
		tree.setSelectionPath(p);
		viewer.setDir((FolderNode) p.getLastPathComponent());
		refreshButton();
	}
	
	public void refreshButton() {
		if (couldUp())
			for (int i=0;i<upButton.size();i++)
				upButton.elementAt(i).setEnabled(true);
		else
			for (int i=0;i<upButton.size();i++)
				upButton.elementAt(i).setEnabled(false);
		if (couldBack())
			for (int i=0;i<backButton.size();i++)
				backButton.elementAt(i).setEnabled(true);
		else
			for (int i=0;i<backButton.size();i++)
				backButton.elementAt(i).setEnabled(false);
		if (couldForward())
			for (int i=0;i<forwardButton.size();i++)
				forwardButton.elementAt(i).setEnabled(true);
		else
			for (int i=0;i<forwardButton.size();i++)
				forwardButton.elementAt(i).setEnabled(false);
	}
	
}
