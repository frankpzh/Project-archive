package TreeProcess;

import java.util.ArrayList;

import javax.swing.event.*;
import javax.swing.tree.*;

public class FolderModel implements TreeModel {

	private FolderNode root;

	private ArrayList<TreeModelListener> modelList = new ArrayList<TreeModelListener>();

	public FolderModel(FolderNode root) {
		this.root = root;
	}

	public void addTreeModelListener(TreeModelListener arg0) {
		modelList.add(arg0);
	}

	public Object getChild(Object arg0, int arg1) {
		return ((FolderNode) arg0).getChildAt(arg1);
	}

	public int getChildCount(Object arg0) {
		return ((FolderNode) arg0).getChildCount();
	}

	public int getIndexOfChild(Object arg0, Object arg1) {
		return ((FolderNode) arg0).getIndex((FolderNode) arg1);
	}

	public Object getRoot() {
		return root;
	}

	public boolean isLeaf(Object arg0) {
		return ((FolderNode) arg0).isLeaf();
	}

	public void removeTreeModelListener(TreeModelListener arg0) {
		modelList.remove(arg0);
	}

	public void valueForPathChanged(TreePath arg0, Object arg1) {
		Debug.DebugStdout.warning("to do");
	}
	
	public synchronized void changeNodeAbove(TreePath path) {
		for (int i=0;i<modelList.size();i++)
			modelList.get(i).treeStructureChanged(new TreeModelEvent(this,path));
	}

}
