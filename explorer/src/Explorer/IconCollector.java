package Explorer;

import java.util.*;
import java.awt.*;
import javax.swing.*;

public class IconCollector {
	
	public final static int ICONTREE=0;
	public final static int ICONFILETYPE=1;
	public final static int ICONDIRTYPE=2;
	public final static int ICONBUTTON=3;
	
	private class ImageIconString extends ImageIcon implements Comparable<ImageIcon> {

		private static final long serialVersionUID = 627637123692123880L;

		public int compareTo(ImageIcon other) {
			return this.toString().compareTo(other.toString());
		}
		
		public ImageIconString(String filename,String desc) {
			super(filename,desc);
		}
	}
	
	private static IconCollector inst=null;
	private static Vector<ImageIconString> iconTree,iconFileType,iconDirType,iconButton;
	
	public static synchronized IconCollector getInst() {
		if (inst==null)
			inst=new IconCollector();
		return inst;
	}
	
	private IconCollector() {
		initIconTree();
		initIconFileType();
		initIconDirType();
		initIconButton();
	}
	
	private void initIconTree() {
		iconTree=new Vector<ImageIconString>();
		iconTree.add(loadIcon("tree","world"));
		iconTree.add(loadIcon("tree","local"));
		iconTree.add(loadIcon("tree","network"));
		iconTree.add(loadIcon("tree","disk"));
		iconTree.add(loadIcon("tree","diskshared"));
		iconTree.add(loadIcon("tree","cd"));
		iconTree.add(loadIcon("tree","folder"));
		iconTree.add(loadIcon("tree","folderopen"));
		iconTree.add(loadIcon("tree","foldershared"));
		iconTree.add(loadIcon("tree","folderopenshared"));
		iconTree.add(loadIcon("tree","open"));
		iconTree.add(loadIcon("tree","unopen"));
		iconTree.add(loadIcon("tree","siteonline"));
		iconTree.add(loadIcon("tree","siteoffline"));
		iconTree.add(loadIcon("tree","netfolder"));
		iconTree.add(loadIcon("tree","netfolderopen"));
		Collections.sort(iconTree);
	}
	
	private void initIconFileType() {
		iconFileType=new Vector<ImageIconString>();
		iconFileType.add(loadIcon("filetype","default"));
		iconFileType.add(loadIcon("filetype","hidden"));
		iconFileType.add(loadIcon("filetype","background"));
		Collections.sort(iconFileType);
	}
	
	private void initIconDirType() {
		iconDirType=new Vector<ImageIconString>();
		iconDirType.add(loadIcon("dirtype","default"));
		iconDirType.add(loadIcon("dirtype","disk"));
		iconDirType.add(loadIcon("dirtype","shared"));
		iconDirType.add(loadIcon("dirtype","diskshared"));
		iconDirType.add(loadIcon("dirtype","cd"));
		iconDirType.add(loadIcon("dirtype","siteonline"));
		iconDirType.add(loadIcon("dirtype","siteoffline"));
		iconDirType.add(loadIcon("dirtype","tempsite"));
		iconDirType.add(loadIcon("dirtype","computer"));
		iconDirType.add(loadIcon("dirtype","network"));
		Collections.sort(iconDirType);
	}
	
	private void initIconButton() {
		iconButton=new Vector<ImageIconString>();
		iconButton.add(loadIcon("button","back"));
		iconButton.add(loadIcon("button","forward"));
		iconButton.add(loadIcon("button","up"));
		iconButton.add(loadIcon("button","refresh"));
		Collections.sort(iconButton);
	}
	
	private ImageIconString loadIcon(String type,String filename) {
		ImageIconString out=new ImageIconString("icons/"+type+"/"+filename+".png",filename);
		while (out.getImageLoadStatus()==MediaTracker.LOADING);
		if (out.getImageLoadStatus()!=MediaTracker.COMPLETE)
			Debug.DebugStdout.error("Error loading icons!");
		return out;
	}
	
	public Icon getIcon(int type,String name) {
		int key;
		ImageIcon toSearch=new ImageIcon();
		toSearch.setDescription(name);
		switch (type) {
		case ICONTREE:
			key=Collections.binarySearch(iconTree, toSearch);
			if (key<0)
				return null;
			else
				return iconTree.elementAt(key);
		case ICONFILETYPE:
			key=Collections.binarySearch(iconFileType, toSearch);
			if (key<0)
				return null;
			else
				return iconFileType.elementAt(key);
		case ICONDIRTYPE:
			key=Collections.binarySearch(iconDirType, toSearch);
			if (key<0)
				return null;
			else
				return iconDirType.elementAt(key);
		case ICONBUTTON:
			key=Collections.binarySearch(iconButton, toSearch);
			if (key<0)
				return null;
			else
				return iconButton.elementAt(key);
		default:
			Debug.DebugStdout.error("Error use of getIcon.");
			return null;
		}
	}
	
}
