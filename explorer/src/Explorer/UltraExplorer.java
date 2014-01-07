package Explorer;

import java.io.*;
import java.awt.*;
import javax.swing.*;
import java.awt.event.*;

import javax.swing.tree.*;

import AdvancedView.*;
import FtpProcess.*;
import TreeProcess.*;

public final class UltraExplorer {
    
    static JSplitPane mainSplitPane;
    
    static FtpServer server;
    
    static JToolBar toolBar;
    
    static TreePath selPath;
    
    public static JFrame mainWindow;
    
    public static JDirTree treeViewWindow;
    
    public static JFileViewer fileViewer;
    
    public static Font msyh = null;
    
    public static void main(String[] args) {
	initFont();
	initUI();
	ExplorerConfig.getInst().commitConfig();
	startUI();
    }
    
    static void startFTPServer() {
	if (server!=null)
	    server.shutDown();
	server = new FtpServer((Integer)ExplorerConfig.getInst().get(ExplorerConfig.SERVERPORT));
	Thread th=new Thread(server);
	th.setPriority(Thread.MIN_PRIORITY);
	th.start();
    }
    
    private static void initFont() {
	try {
	    msyh = Font.createFont(Font.TRUETYPE_FONT, new BufferedInputStream(
		new FileInputStream(new File("msyh.ttf"))));
	    msyh = msyh.deriveFont(Font.BOLD, 12);
	} catch (Exception e) {
	    msyh = null;
	}
    }
    
    public static void initUI() {
	try {
	    UIManager.setLookAndFeel(UIManager.getSystemLookAndFeelClassName());
	} catch (Exception e) {
	}
	Font song=((Font)UIManager.get("MenuItem.font")).deriveFont(12.0f);
	UIManager.put("MenuBar.font",song);
	UIManager.put("Menu.font",song);
	UIManager.put("MenuItem.font",song);
	UIManager.put("ToolTip.font",song);
	UIManager.put("CheckBoxMenuItem.font",song);
	UIManager.put("OptionPane.messageFont",msyh);
	UIManager.put("OptionPane.buttonFont",msyh);
	
	mainWindow = new JFrame("UltraExplorer");
	mainWindow.setSize(950, 700);
	if (msyh != null)
	    mainWindow.setFont(msyh);
	
	initTree();
	
	mainSplitPane = new JSplitPane(JSplitPane.HORIZONTAL_SPLIT,
	    new JScrollPane(treeViewWindow), fileViewer = new JFileViewer());
	mainSplitPane.setDividerSize(3);
	mainSplitPane.setDividerLocation(Constants.DEFAULT_DIVIDER_LOCATION);
	mainWindow.add(mainSplitPane);
	
	mainWindow.add(toolBar = ResourceBuilder.getInst().getToolbar(),
	    BorderLayout.NORTH);
	mainWindow.setJMenuBar(ResourceBuilder.getInst().getExplorerMenuBar());
	
	mainWindow.addWindowListener(new WindowAdapter() {
	    public void windowClosing(WindowEvent e) {
		ExplorerConfig.getInst().writeConfig();
		exit();
	    }
	});
    }
    
    private static void startUI() {
	treeViewWindow.setSelectionPath(new TreePath(treeViewWindow.getModel().getRoot()));
	mainWindow.setVisible(true);
    }
    
    private static void initTree() {
	IconCollector icon = IconCollector.getInst();
	UIManager.put("Tree.collapsedIcon", icon.getIcon(
	    IconCollector.ICONTREE, "unopen"));
	UIManager.put("Tree.expandedIcon", icon.getIcon(IconCollector.ICONTREE,
	    "open"));
	treeViewWindow = new JDirTree(new FolderModel(new FolderNode()));
	treeViewWindow.setRowHeight(22);
	treeViewWindow.setCellRenderer(new FolderRenderer());
	treeViewWindow.addTreeWillExpandListener(new FileTreeProcesser());
	treeViewWindow.addTreeSelectionListener(new FolderSelectionListener());
	treeViewWindow.getSelectionModel().setSelectionMode(
	    TreeSelectionModel.SINGLE_TREE_SELECTION);
	treeViewWindow.putClientProperty("JTree.lineStyle", "None");
	
	treeViewWindow.addMouseListener(new MouseAdapter() {
	    public void mousePressed(MouseEvent e) {
		if (e.getButton() == MouseEvent.BUTTON3) {
		    selPath = treeViewWindow.getPathForLocation(e.getX(), e
			.getY());
		    if (treeViewWindow.getRowForLocation(e.getX(), e.getY()) != -1)
			((FolderNode)selPath.getLastPathComponent()).getFile().doRight((Component)e.getSource(),e.getPoint());
		}
	    }
	});
    }
    
    public static void exit() {
	if (server!=null)
	    server.shutDown();
	ExplorerConfig.getInst().writeConfig();
	if (FtpClient.getInst().getStatus()==FtpClient.CONNECTED||
	    FtpClient.getInst().getStatus()==FtpClient.READY)
	    FtpClient.getInst().disconnect();
	System.exit(0);
    }
    
}
