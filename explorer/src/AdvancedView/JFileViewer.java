package AdvancedView;

import java.io.*;
import java.awt.*;
import java.util.*;
import javax.swing.*;
import javax.swing.event.*;

import TreeProcess.*;
import java.awt.event.*;

public class JFileViewer extends JPanel implements MouseListener,
    Comparator<FileItem> {
    
    private static final long serialVersionUID = 8912715370028267730L;
    
    public final static int THUMBNAILS = 0;
    
    public final static int TILES = 1;
    
    public final static int DETAILS = 2;
    
    public final static int FILMSTRIP = 3;
    
    public final static int NAME = 0;
    
    public final static int TYPE = 10;
    
    public final static int SIZE = 20;
    
    public final static int MODIFIED = 30;
    
    private JScrollPane sp;
    
    private JTable detail;
    
    private JSplitPane filmStrip;
    
    private JLabel filmShow;
    
    private JPanel tile, film;
    
    private int style, sortMethod;
    
    private Vector<FileItem> files;
    
    private void sort() {
	if (files.size() > 0)
	    Collections.sort(files, this);
    }
    
    private void refresh() {
	Thread waste = new Thread(new TimeWaster(this));
	waste.start();
	sort();
	int divider = ((JSplitPane) this.getParent()).getDividerLocation();
	this.setVisible(false);
	this.removeAll();
	
	switch (style) {
	    case THUMBNAILS:
	    case TILES:
		tile = new JPanel();
		tile.setBackground(Color.WHITE);
		tile.setLayout(new FlowLayoutEx(FlowLayout.LEFT));
		for (int i = 0; i < files.size(); i++)
		    tile.add(new JFileItem(files.elementAt(i), style));
		
		sp = new JScrollPane(tile,
		    JScrollPane.VERTICAL_SCROLLBAR_AS_NEEDED,
		    JScrollPane.HORIZONTAL_SCROLLBAR_NEVER);
		sp.setOpaque(false);
		sp.getViewport().setOpaque(false);
		sp.getVerticalScrollBar().setUnitIncrement(60);
		sp.addMouseListener(this);
		sp.addComponentListener(new ComponentAdapter() {
		    public void componentResized(ComponentEvent e) {
			tile.setPreferredSize(new Dimension(sp.getViewport()
			.getExtentSize().width - 5, sp.getViewport()
			.getExtentSize().height));
		    }
		});
		this.add(sp);
		break;
	    case DETAILS:
		detail = new JTable(new FileTableModel(files));
		detail.setShowGrid(false);
		detail.setShowHorizontalLines(false);
		detail.setShowVerticalLines(false);
		for (int i = 0; i < detail.getColumnModel().getColumnCount(); i++)
		    detail.getColumnModel().getColumn(i).setCellRenderer(
			new FileTableCellRenderer());
		detail.addMouseListener(new MouseAdapter() {
		    public void mouseClicked(MouseEvent e) {
			if (e.getClickCount() == 2
			    && e.getButton() == MouseEvent.BUTTON1) {
			    ((FileTableModel) ((JTable) e.getSource()).getModel())
			    .getFile(
				((JTable) e.getSource())
				.getSelectedRow()).doAction();
			} else if (e.getButton() == MouseEvent.BUTTON3)
			    ((FileTableModel) ((JTable) e.getSource()).getModel())
			    .getFile(((JTable) e.getSource()).rowAtPoint(e.getPoint()))
			    .doRight((Component)e.getSource(),e.getPoint());
		    }
		});
		
		sp = new JScrollPane(detail);
		sp.setBackground(Color.WHITE);
		sp.getViewport().setBackground(Color.WHITE);
		sp.addMouseListener(this);
		this.add(sp);
		break;
	    case FILMSTRIP:
		detail = new JTable(new FileTableModel(files));
		detail.setShowGrid(false);
		detail.setShowHorizontalLines(false);
		detail.setShowVerticalLines(false);
		for (int i = 0; i < detail.getColumnModel().getColumnCount(); i++)
		    detail.getColumnModel().getColumn(i).setCellRenderer(
			new FileTableCellRenderer());
		detail.addMouseListener(new MouseAdapter() {
		    public void mouseClicked(MouseEvent e) {
			if (e.getClickCount() == 2
			    && e.getButton() == MouseEvent.BUTTON1) {
			    ((FileTableModel) ((JTable) e.getSource()).getModel())
			    .getFile(
				((JTable) e.getSource())
				.getSelectedRow()).doAction();
			} else if (e.getButton() == MouseEvent.BUTTON3)
			    ((FileTableModel) ((JTable) e.getSource()).getModel())
			    .getFile(((JTable) e.getSource()).rowAtPoint(e.getPoint()))
				.doRight((Component)e.getSource(),e.getPoint());
		    }
		});
		detail.getSelectionModel().addListSelectionListener(
		    new ListSelectionListener() {
		    private int last = -1;
		    
		    public void valueChanged(ListSelectionEvent e) {
			int i;
			
			for (i = e.getFirstIndex(); i <= e.getLastIndex(); i++)
			    if (detail.getSelectionModel().isSelectedIndex(i))
				break;
			if (i > e.getLastIndex())
			    i = -1;
			if (last == i)
			    return;
			last = i;
			Thread waste = new Thread(new TimeWaster(filmShow));
			waste.start();
			Icon pic;
			String str;
			film.setVisible(false);
			if (i != -1 && (pic = ((FileTableModel) detail
			    .getModel()).getFile(i).makeIcon(
			    filmShow.getWidth(),filmShow.getHeight())) != null) {
			    filmShow.setText("");
			    filmShow.setIcon(pic);
			    film.removeAll();
			    film.add(filmShow);
			}else if (i != -1
			    && (str=((FileTableModel) detail
			    .getModel()).getFile(i).pureText())!=null) {
			    filmShow.setText("");
			    filmShow.setIcon(null);
			    JTextArea ta=new JTextArea(str);
			    ta.setEditable(false);
			    film.removeAll();
			    film.add(new JScrollPane(ta));
			} else {
			    filmShow.setText(java.util.ResourceBundle.getBundle("language").getString("This_file_could_not_be_previewed."));
			    filmShow.setIcon(null);
			    film.removeAll();
			    film.add(filmShow);
			}
			film.setVisible(true);
			waste.interrupt();
		    }
		});
		
		sp = new JScrollPane(detail);
		sp.setBackground(Color.WHITE);
		sp.getViewport().setBackground(Color.WHITE);
		sp.addMouseListener(this);
		
		filmShow = new JLabel(java.util.ResourceBundle.getBundle("language").getString("This_file_could_not_be_previewed."));
		filmShow.setHorizontalAlignment(JLabel.CENTER);
		filmShow.setVerticalAlignment(JLabel.CENTER);
		
		film = new JPanel();
		film.setLayout(new BorderLayout());
		film.add(filmShow);
		
		filmStrip = new JSplitPane();
		filmStrip.setOrientation(JSplitPane.VERTICAL_SPLIT);
		filmStrip.setTopComponent(film);
		filmStrip.setBottomComponent(sp);
		filmStrip.setDividerLocation(450);
		
		this.add(filmStrip);
		
		break;
	}
	
	this.setVisible(true);
	((JSplitPane) this.getParent()).setDividerLocation(divider);
	waste.interrupt();
    }
    
    public JFileViewer() {
	super();
	files = new Vector<FileItem>();
	this.setLayout(new BorderLayout());
	this.setBackground(new Color(255, 255, 255));
    }
    
    public void setStyle(String name) {
	if (name.equals(java.util.ResourceBundle.getBundle("language").getString("Thumbnails")))
	    style = THUMBNAILS;
	else if (name.equals(java.util.ResourceBundle.getBundle("language").getString("Tiles")))
	    style = TILES;
	else if (name.equals(java.util.ResourceBundle.getBundle("language").getString("Details")))
	    style = DETAILS;
	else if (name.equals(java.util.ResourceBundle.getBundle("language").getString("Filmstrip")))
	    style = FILMSTRIP;
	else
	    Debug.DebugStdout.error("Error use of setStyle!");
	refresh();
    }
    
    public void setSortMethod(String name) {
	if (name.equals(java.util.ResourceBundle.getBundle("language").getString("Name")))
	    sortMethod = NAME;
	else if (name.equals(java.util.ResourceBundle.getBundle("language").getString("Type")))
	    sortMethod = TYPE;
	else if (name.equals(java.util.ResourceBundle.getBundle("language").getString("Size")))
	    sortMethod = SIZE;
	else if (name.equals(java.util.ResourceBundle.getBundle("language").getString("Modified")))
	    sortMethod = MODIFIED;
	else
	    Debug.DebugStdout.error("Error use of setSortMethod!");
	refresh();
    }
    
    public void setDir(FolderNode base) {
	File[] all;
	files.clear();
	switch (base.getType()) {
	    case FileItem.ROOT:
		for (int i = 0; i < base.getChildCount(); i++)
		    files.add(((FolderNode) base.getChildAt(i)).getFile());
		break;
	    case FileItem.COMPUTER:
		all = File.listRoots();
		if (all != null)
		    for (int i = 0; i < all.length; i++)
			files.add(new FileItem(all[i]));
		else
		    Debug.DebugStdout.error("Error fetch roots.");
		break;
	    case FileItem.NETWORK:
		for (int i = 0; i < base.getChildCount(); i++)
		    files.add(((FolderNode) base.getChildAt(i)).getFile());
		break;
	    case FileItem.ON_LOCAL:
		all = base.getFile().listFiles();
		if (all != null)
		    for (int i = 0; i < all.length; i++)
			files.add(new FileItem(all[i]));
		else
		    Debug.DebugStdout
			.warning("Error fetch " + base.getFile() + ".");
		break;
	    case FileItem.ON_NETWORK:
		Vector<FileItem> dirs = base.getFile().listFileItem();
		if (dirs != null)
		    for (int i = 0; i < dirs.size(); i++)
			files.add(dirs.elementAt(i));
		break;
	    default:
		Debug.DebugStdout.error("Error use of setDir!");
	}
	refresh();
    }
    
    public void mouseClicked(MouseEvent e) {
	switch (e.getButton()) {
	    case MouseEvent.BUTTON1:
		switch (style) {
		    case THUMBNAILS:
		    case TILES:
			if (tile.getComponentCount() > 0)
			    ((JFileItem) tile.getComponent(0)).getModel()
			    .clearSelected();
			break;
		    case DETAILS:
			detail.clearSelection();
			break;
		    case FILMSTRIP:
			detail.clearSelection();
			break;
		}
		break;
	    case MouseEvent.BUTTON3:
		Explorer.ResourceBuilder.getInst().getViewPopupMenu().show(sp,
		    e.getX(), e.getY());
		break;
	}
    }
    
    public void mouseEntered(MouseEvent e) {
    }
    
    public void mouseExited(MouseEvent e) {
    }
    
    public void mousePressed(MouseEvent e) {
    }
    
    public void mouseReleased(MouseEvent arg0) {
    }
    
    public int compare(FileItem a, FileItem b) {
	if (b.isDirectory() && !a.isDirectory())
	    return 1;
	if (a.isDirectory() && !b.isDirectory())
	    return -1;
	switch (sortMethod) {
	    case NAME:
		return a.compareTo(b);
	    case TYPE:
		return a.getExtension().compareTo(b.getExtension());
	    case SIZE:
		return ((Long) a.length()).compareTo(b.length());
	    case MODIFIED:
		return ((Long) a.lastModified()).compareTo(b.lastModified());
	    default:
		Debug.DebugStdout.assume(false);
		return 0;
	}
    }
    
}
