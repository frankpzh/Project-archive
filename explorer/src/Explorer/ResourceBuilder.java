package Explorer;

import AdvancedView.FileItem;
import MenuAction.AddFavoriteListener;
import MenuAction.LoginListener;
import MenuAction.ShareListener;
import Player.PlayServer;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;

import javax.swing.*;

import MenuAction.AccountListener;
import MenuAction.ExitListener;
import MenuAction.RefreshNetworkListener;
import MenuAction.SetupListener;
import MenuAction.SortMethodListener;
import MenuAction.ToolbarListener;
import MenuAction.TreeViewListener;
import MenuAction.ViewStyleListener;

public class ResourceBuilder {
    
    private static ResourceBuilder inst = null;
    
    public static ResourceBuilder getInst() {
	if (inst == null) {
	    inst = new ResourceBuilder();
	}
	return inst;
    }
    
    private JMenuBar main;
    
    private JToolBar tool;
    
    private JPopupMenu popView,popNetwork,popDir,popTempSite,popSite,popAudio;
    
    private JCheckBoxMenuItem[] chooseViewMain = new JCheckBoxMenuItem[4],
	chooseViewPop = new JCheckBoxMenuItem[4],
	chooseSortMain = new JCheckBoxMenuItem[4],
	chooseSortPop = new JCheckBoxMenuItem[4];
    
    private JCheckBoxMenuItem[] hasComp = new JCheckBoxMenuItem[4];
    
    private ActionListener[] hasCompListen = new ActionListener[4];
    
    private ResourceBuilder() {
	tool = buildToolbar();
    }
    
    private void initMenu() {
	main = buildExplorerMenuBar();
	popView = buildViewPopupMenu();
	popDir = buildPopDir();
	popNetwork = buildPopNetwork();
	popTempSite = buildPopTempSite();
	popSite = buildPopSite();
	popAudio=buildPopAudio();
	((ToolbarListener) hasCompListen[0]).setSame(hasComp[2]);
	((ToolbarListener) hasCompListen[2]).setSame(hasComp[0]);
	((TreeViewListener) hasCompListen[1]).setSame(hasComp[3]);
	((TreeViewListener) hasCompListen[3]).setSame(hasComp[1]);
    }
    
    private JMenuBar buildExplorerMenuBar() {
	JMenuBar menuBar = new JMenuBar();
	JMenu mnuTemp = new JMenu(java.util.ResourceBundle.getBundle("language").getString("File"));
	mnuTemp.setMnemonic('f');
	
	mnuTemp.addSeparator();
	
	JMenuItem mnuitmTemp = new JMenuItem(java.util.ResourceBundle.getBundle("language").getString("Exit"), 'x');
	mnuitmTemp.addActionListener(new ExitListener());
	mnuTemp.add(mnuitmTemp);
	
	menuBar.add(mnuTemp);
	
	mnuTemp = new JMenu(java.util.ResourceBundle.getBundle("language").getString("View"));
	mnuTemp.setMnemonic('v');
	
	mnuitmTemp = new JCheckBoxMenuItem(java.util.ResourceBundle.getBundle("language").getString("Toolbar"), true);
	mnuitmTemp.setMnemonic('t');
	mnuitmTemp.addActionListener(hasCompListen[0] = new ToolbarListener(
	    UltraExplorer.toolBar));
	mnuTemp.add(mnuitmTemp);
	hasComp[0] = (JCheckBoxMenuItem) mnuitmTemp;
	
	mnuitmTemp = new JCheckBoxMenuItem(java.util.ResourceBundle.getBundle("language").getString("Tree_View"), true);
	mnuitmTemp.setMnemonic('v');
	mnuitmTemp.addActionListener(hasCompListen[1] = new TreeViewListener(
	    UltraExplorer.mainSplitPane));
	mnuTemp.add(mnuitmTemp);
	hasComp[1] = (JCheckBoxMenuItem) mnuitmTemp;
	
	mnuTemp.addSeparator();
	
	ViewStyleListener vslTmp;
	mnuitmTemp = new JCheckBoxMenuItem(java.util.ResourceBundle.getBundle("language").getString("Thumbnails"), false);
	chooseViewMain[0] = (JCheckBoxMenuItem) mnuitmTemp;
	mnuitmTemp.setMnemonic('h');
	mnuitmTemp.addActionListener(vslTmp = new ViewStyleListener(
	    chooseViewMain));
	vslTmp.addSelectionGroup(chooseViewPop);
	mnuTemp.add(mnuitmTemp);
	
	mnuitmTemp = new JCheckBoxMenuItem(java.util.ResourceBundle.getBundle("language").getString("Tiles"), false);
	chooseViewMain[1] = (JCheckBoxMenuItem) mnuitmTemp;
	mnuitmTemp.setMnemonic('s');
	mnuitmTemp.addActionListener(vslTmp = new ViewStyleListener(
	    chooseViewMain));
	vslTmp.addSelectionGroup(chooseViewPop);
	mnuTemp.add(mnuitmTemp);
	
	mnuitmTemp = new JCheckBoxMenuItem(java.util.ResourceBundle.getBundle("language").getString("Details"), false);
	chooseViewMain[2] = (JCheckBoxMenuItem) mnuitmTemp;
	mnuitmTemp.setMnemonic('d');
	mnuitmTemp.addActionListener(vslTmp = new ViewStyleListener(
	    chooseViewMain));
	vslTmp.addSelectionGroup(chooseViewPop);
	mnuTemp.add(mnuitmTemp);
	
	mnuitmTemp = new JCheckBoxMenuItem(java.util.ResourceBundle.getBundle("language").getString("Filmstrip"), false);
	chooseViewMain[3] = (JCheckBoxMenuItem) mnuitmTemp;
	mnuitmTemp.setMnemonic('p');
	mnuitmTemp.addActionListener(vslTmp = new ViewStyleListener(
	    chooseViewMain));
	vslTmp.addSelectionGroup(chooseViewPop);
	mnuTemp.add(mnuitmTemp);
	
	mnuTemp.addSeparator();
	
	JMenu mnuTemp2 = new JMenu(java.util.ResourceBundle.getBundle("language").getString("Arrange_Icons_by"));
	mnuTemp2.setMnemonic('i');
	
	SortMethodListener smlTmp;
	mnuitmTemp = new JCheckBoxMenuItem(java.util.ResourceBundle.getBundle("language").getString("Name"), false);
	chooseSortMain[0] = (JCheckBoxMenuItem) mnuitmTemp;
	mnuitmTemp.setMnemonic('n');
	mnuitmTemp.addActionListener(smlTmp = new SortMethodListener(
	    chooseSortMain));
	smlTmp.addSelectionGroup(chooseSortPop);
	mnuTemp2.add(mnuitmTemp);
	
	mnuitmTemp = new JCheckBoxMenuItem(java.util.ResourceBundle.getBundle("language").getString("Type"), false);
	chooseSortMain[1] = (JCheckBoxMenuItem) mnuitmTemp;
	mnuitmTemp.setMnemonic('t');
	mnuitmTemp.addActionListener(smlTmp = new SortMethodListener(
	    chooseSortMain));
	smlTmp.addSelectionGroup(chooseSortPop);
	mnuTemp2.add(mnuitmTemp);
	
	mnuitmTemp = new JCheckBoxMenuItem(java.util.ResourceBundle.getBundle("language").getString("Size"), false);
	chooseSortMain[2] = (JCheckBoxMenuItem) mnuitmTemp;
	mnuitmTemp.setMnemonic('s');
	mnuitmTemp.addActionListener(smlTmp = new SortMethodListener(
	    chooseSortMain));
	smlTmp.addSelectionGroup(chooseSortPop);
	mnuTemp2.add(mnuitmTemp);
	
	mnuitmTemp = new JCheckBoxMenuItem(java.util.ResourceBundle.getBundle("language").getString("Modified"), false);
	chooseSortMain[3] = (JCheckBoxMenuItem) mnuitmTemp;
	mnuitmTemp.setMnemonic('m');
	mnuitmTemp.addActionListener(smlTmp = new SortMethodListener(
	    chooseSortMain));
	smlTmp.addSelectionGroup(chooseSortPop);
	mnuTemp2.add(mnuitmTemp);
	
	mnuTemp.add(mnuTemp2);
	
	mnuTemp.addSeparator();
	
	mnuTemp2 = new JMenu(java.util.ResourceBundle.getBundle("language").getString("Go_to"));
	mnuTemp2.setMnemonic('g');
	
	mnuitmTemp = new JMenuItem(java.util.ResourceBundle.getBundle("language").getString("Back"), 'b');
	History.getInst().addBack(mnuitmTemp);
	mnuTemp2.add(mnuitmTemp);
	
	mnuitmTemp = new JMenuItem(java.util.ResourceBundle.getBundle("language").getString("Forward"), 'f');
	History.getInst().addForward(mnuitmTemp);
	mnuTemp2.add(mnuitmTemp);
	
	mnuitmTemp = new JMenuItem(java.util.ResourceBundle.getBundle("language").getString("Up_One_Level"), 'u');
	History.getInst().addUp(mnuitmTemp);
	mnuTemp2.add(mnuitmTemp);
	
	mnuTemp.add(mnuTemp2);
	
	mnuitmTemp = new JMenuItem(java.util.ResourceBundle.getBundle("language").getString("Refresh"), 'r');
	mnuitmTemp.addActionListener(new ActionListener() {
	    public void actionPerformed(ActionEvent e) {
		History.getInst().refresh();
	    }
	});
	
	mnuTemp.add(mnuitmTemp);
	
	menuBar.add(mnuTemp);
	
	mnuTemp=new JMenu("播放");
	mnuitmTemp = new JCheckBoxMenuItem("播放/停止");
	((JCheckBoxMenuItem)mnuitmTemp).setSelected(true);
	PlayServer.getInst().play();
	mnuitmTemp.addActionListener(new ActionListener() {
	    public void actionPerformed(ActionEvent e) {
		if (((JCheckBoxMenuItem)e.getSource()).isSelected())
		    PlayServer.getInst().play();
		else
		    PlayServer.getInst().stop();
	    }
	});
	mnuTemp.add(mnuitmTemp);
	mnuitmTemp = new JMenuItem("下一首");
	mnuitmTemp.addActionListener(new ActionListener() {
	    public void actionPerformed(ActionEvent e) {
		PlayServer.getInst().next();
	    }
	});
	mnuTemp.add(mnuitmTemp);
	mnuitmTemp = new JMenuItem("清空列表");
	mnuitmTemp.addActionListener(new ActionListener() {
	    public void actionPerformed(ActionEvent e) {
		PlayServer.getInst().clearList();
	    }
	});
	mnuTemp.add(mnuitmTemp);
	menuBar.add(mnuTemp);
	
	mnuTemp = new JMenu(java.util.ResourceBundle.getBundle("language").getString("Tools"));
	mnuTemp.setMnemonic('t');
	
	mnuitmTemp = new JMenuItem(java.util.ResourceBundle.getBundle("language").getString("Network_Setup..."), 'n');
	mnuitmTemp.addActionListener(new SetupListener());
	mnuTemp.add(mnuitmTemp);
	
	mnuitmTemp = new JMenuItem(java.util.ResourceBundle.getBundle("language").getString("Accounts_Management..."), 'a');
	mnuitmTemp.addActionListener(new AccountListener());
	mnuTemp.add(mnuitmTemp);
	
	mnuTemp.addSeparator();
	
	mnuitmTemp = new JMenuItem(java.util.ResourceBundle.getBundle("language").getString("Refresh_Sites_on_Network"), 'r');
	mnuitmTemp.addActionListener(new RefreshNetworkListener(mnuitmTemp));
	mnuTemp.add(mnuitmTemp);
	
	menuBar.add(mnuTemp);
	
	mnuTemp = new JMenu(java.util.ResourceBundle.getBundle("language").getString("Help"));
	mnuTemp.setMnemonic('h');
	
	mnuitmTemp = new JMenuItem(java.util.ResourceBundle.getBundle("language").getString("About_Author..."), 'a');
	mnuitmTemp.addActionListener(new ActionListener() {
	    public void actionPerformed(ActionEvent e) {
		JOptionPane.showMessageDialog(UltraExplorer.mainWindow,
		    java.util.ResourceBundle.getBundle("language").getString("Author Information"),
		    java.util.ResourceBundle.getBundle("language").getString("UltraExplorer"), JOptionPane.INFORMATION_MESSAGE);
	    }
	});
	
	mnuTemp.add(mnuitmTemp);
	
	mnuitmTemp = new JMenuItem(java.util.ResourceBundle.getBundle("language").getString("UltraExplorer Information 1"), 'u');
	mnuitmTemp.addActionListener(new ActionListener() {
	    public void actionPerformed(ActionEvent e) {
		JOptionPane
		    .showMessageDialog(
		    UltraExplorer.mainWindow,
		    java.util.ResourceBundle.getBundle("language").getString("UltraExplorer Information 2")
		    + java.util.ResourceBundle.getBundle("language").getString("UltraExplorer Information 3")
		    + java.util.ResourceBundle.getBundle("language").getString("UltraExplorer Information 4"),
		    java.util.ResourceBundle.getBundle("language").getString("UltraExplorer"),
		    JOptionPane.INFORMATION_MESSAGE);
	    }
	});
	mnuTemp.add(mnuitmTemp);
	
	menuBar.add(mnuTemp);
	return menuBar;
    }
    
    private JPopupMenu buildViewPopupMenu() {
	JPopupMenu mnuTemp = new JPopupMenu();
	
	JMenuItem mnuitmTemp = new JCheckBoxMenuItem(java.util.ResourceBundle.getBundle("language").getString("Toolbar"), true);
	mnuitmTemp.setMnemonic('t');
	mnuitmTemp.addActionListener(hasCompListen[2] = new ToolbarListener(
	    UltraExplorer.toolBar));
	hasComp[2] = (JCheckBoxMenuItem) mnuitmTemp;
	mnuTemp.add(mnuitmTemp);
	
	mnuitmTemp = new JCheckBoxMenuItem(java.util.ResourceBundle.getBundle("language").getString("Tree_View"), true);
	mnuitmTemp.setMnemonic('v');
	mnuitmTemp.addActionListener(hasCompListen[3] = new TreeViewListener(
	    UltraExplorer.mainSplitPane));
	hasComp[3] = (JCheckBoxMenuItem) mnuitmTemp;
	mnuTemp.add(mnuitmTemp);
	
	mnuTemp.addSeparator();
	
	ViewStyleListener vslTmp;
	mnuitmTemp = new JCheckBoxMenuItem(java.util.ResourceBundle.getBundle("language").getString("Thumbnails"), false);
	chooseViewPop[0] = (JCheckBoxMenuItem) mnuitmTemp;
	mnuitmTemp.setMnemonic('h');
	mnuitmTemp.addActionListener(vslTmp = new ViewStyleListener(
	    chooseViewPop));
	vslTmp.addSelectionGroup(chooseViewMain);
	mnuTemp.add(mnuitmTemp);
	
	mnuitmTemp = new JCheckBoxMenuItem(java.util.ResourceBundle.getBundle("language").getString("Tiles"), false);
	chooseViewPop[1] = (JCheckBoxMenuItem) mnuitmTemp;
	mnuitmTemp.setMnemonic('s');
	mnuitmTemp.addActionListener(vslTmp = new ViewStyleListener(
	    chooseViewPop));
	vslTmp.addSelectionGroup(chooseViewMain);
	mnuTemp.add(mnuitmTemp);
	
	mnuitmTemp = new JCheckBoxMenuItem(java.util.ResourceBundle.getBundle("language").getString("Details"), false);
	chooseViewPop[2] = (JCheckBoxMenuItem) mnuitmTemp;
	mnuitmTemp.setMnemonic('d');
	mnuitmTemp.addActionListener(vslTmp = new ViewStyleListener(
	    chooseViewPop));
	vslTmp.addSelectionGroup(chooseViewMain);
	mnuTemp.add(mnuitmTemp);
	
	mnuitmTemp = new JCheckBoxMenuItem(java.util.ResourceBundle.getBundle("language").getString("Filmstrip"), false);
	chooseViewPop[3] = (JCheckBoxMenuItem) mnuitmTemp;
	mnuitmTemp.setMnemonic('p');
	mnuitmTemp.addActionListener(vslTmp = new ViewStyleListener(
	    chooseViewPop));
	vslTmp.addSelectionGroup(chooseViewMain);
	mnuTemp.add(mnuitmTemp);
	
	mnuTemp.addSeparator();
	
	JMenu mnuTemp2 = new JMenu(java.util.ResourceBundle.getBundle("language").getString("Arrange_Icons_by"));
	mnuTemp2.setMnemonic('i');
	
	SortMethodListener smlTmp;
	mnuitmTemp = new JCheckBoxMenuItem(java.util.ResourceBundle.getBundle("language").getString("Name"), false);
	chooseSortPop[0] = (JCheckBoxMenuItem) mnuitmTemp;
	mnuitmTemp.setMnemonic('n');
	mnuitmTemp.addActionListener(smlTmp = new SortMethodListener(
	    chooseSortPop));
	smlTmp.addSelectionGroup(chooseSortMain);
	mnuTemp2.add(mnuitmTemp);
	
	mnuitmTemp = new JCheckBoxMenuItem(java.util.ResourceBundle.getBundle("language").getString("Type"), false);
	chooseSortPop[1] = (JCheckBoxMenuItem) mnuitmTemp;
	mnuitmTemp.setMnemonic('t');
	mnuitmTemp.addActionListener(smlTmp = new SortMethodListener(
	    chooseSortPop));
	smlTmp.addSelectionGroup(chooseSortMain);
	mnuTemp2.add(mnuitmTemp);
	
	mnuitmTemp = new JCheckBoxMenuItem(java.util.ResourceBundle.getBundle("language").getString("Size"), false);
	chooseSortPop[2] = (JCheckBoxMenuItem) mnuitmTemp;
	mnuitmTemp.setMnemonic('s');
	mnuitmTemp.addActionListener(smlTmp = new SortMethodListener(
	    chooseSortPop));
	smlTmp.addSelectionGroup(chooseSortMain);
	mnuTemp2.add(mnuitmTemp);
	
	mnuitmTemp = new JCheckBoxMenuItem(java.util.ResourceBundle.getBundle("language").getString("Modified"), false);
	chooseSortPop[3] = (JCheckBoxMenuItem) mnuitmTemp;
	mnuitmTemp.setMnemonic('m');
	mnuitmTemp.addActionListener(smlTmp = new SortMethodListener(
	    chooseSortPop));
	smlTmp.addSelectionGroup(chooseSortMain);
	mnuTemp2.add(mnuitmTemp);
	
	mnuTemp.add(mnuTemp2);
	
	mnuTemp.addSeparator();
	
	mnuTemp2 = new JMenu(java.util.ResourceBundle.getBundle("language").getString("Go_to"));
	mnuTemp2.setMnemonic('g');
	
	mnuitmTemp = new JMenuItem(java.util.ResourceBundle.getBundle("language").getString("Back"), 'b');
	History.getInst().addBack(mnuitmTemp);
	mnuTemp2.add(mnuitmTemp);
	
	mnuitmTemp = new JMenuItem(java.util.ResourceBundle.getBundle("language").getString("Forward"), 'f');
	History.getInst().addForward(mnuitmTemp);
	mnuTemp2.add(mnuitmTemp);
	
	mnuitmTemp = new JMenuItem(java.util.ResourceBundle.getBundle("language").getString("Up_One_Level"), 'u');
	History.getInst().addUp(mnuitmTemp);
	mnuTemp2.add(mnuitmTemp);
	
	mnuTemp.add(mnuTemp2);
	
	mnuitmTemp = new JMenuItem(java.util.ResourceBundle.getBundle("language").getString("Refresh"), 'r');
	mnuitmTemp.addActionListener(new ActionListener() {
	    public void actionPerformed(ActionEvent e) {
		History.getInst().refresh();
	    }
	});
	
	mnuTemp.add(mnuitmTemp);
	return mnuTemp;
    }
    
    private JToolBar buildToolbar() {
	JToolBar toolBar = new JToolBar();
	JButton btnTemp = new JButton(java.util.ResourceBundle.getBundle("language").getString("Back"), IconCollector.getInst().getIcon(
	    IconCollector.ICONBUTTON, "back"));
	btnTemp.setFocusPainted(false);
	History.getInst().addBack(btnTemp);
	toolBar.add(btnTemp);
	btnTemp = new JButton(java.util.ResourceBundle.getBundle("language").getString("Forward"), IconCollector.getInst().getIcon(
	    IconCollector.ICONBUTTON, "forward"));
	btnTemp.setFocusPainted(false);
	History.getInst().addForward(btnTemp);
	toolBar.add(btnTemp);
	btnTemp = new JButton(java.util.ResourceBundle.getBundle("language").getString("Up"), IconCollector.getInst().getIcon(
	    IconCollector.ICONBUTTON, "up"));
	btnTemp.setFocusPainted(false);
	History.getInst().addUp(btnTemp);
	toolBar.add(btnTemp);
	toolBar.addSeparator();
	btnTemp = new JButton(java.util.ResourceBundle.getBundle("language").getString("Refresh"), IconCollector.getInst().getIcon(
	    IconCollector.ICONBUTTON, "refresh"));
	btnTemp.setFocusPainted(false);
	btnTemp.addActionListener(new ActionListener() {
	    public void actionPerformed(ActionEvent e) {
		History.getInst().refresh();
	    }
	});
	toolBar.add(btnTemp);
	return toolBar;
    }
    
    public JMenuBar getExplorerMenuBar() {
	if (main == null)
	    initMenu();
	return main;
    }
    
    public JToolBar getToolbar() {
	return tool;
    }
    
    public JPopupMenu getViewPopupMenu() {
	if (popView == null)
	    initMenu();
	return popView;
    }
    
    public JPopupMenu getPopDir() {
	if (popView == null)
	    initMenu();
	return popDir;
    }
    
    public JPopupMenu getPopNetwork() {
	if (popView == null)
	    initMenu();
	return popNetwork;
    }
    
    public JPopupMenu getPopTempSite() {
	if (popView == null)
	    initMenu();
	return popTempSite;
    }
    
    public JFrame getSetupDialog() {
	return SetupDialog.build();
    }
    
    public JFrame getAccountDialog() {
	return AccountDialog.build();
    }
    
    private JPopupMenu buildPopDir() {
	JPopupMenu m=new JPopupMenu();
	JMenuItem it=new JMenuItem("设置为共享文件夹");
	it.addActionListener(new ShareListener());
	m.add(it);
	return m;
    }
    
    private JPopupMenu buildPopNetwork() {
	JPopupMenu m=new JPopupMenu();
	JMenuItem it=new JMenuItem("刷新网上邻居");
	it.addActionListener(new RefreshNetworkListener(it));
	m.add(it);
	return m;
    }
    
    private JPopupMenu buildPopTempSite() {
	JPopupMenu m=new JPopupMenu();
	JMenuItem it=new JMenuItem("添加为收藏站点");
	it.addActionListener(new AddFavoriteListener());
	m.add(it);
	return m;
    }
    
    private JPopupMenu buildPopSite() {
	JPopupMenu m=new JPopupMenu();
	JMenuItem it=new JMenuItem("使用其他账号登录");
	it.addActionListener(new LoginListener());
	m.add(it);
	return m;
    }
    
    private JPopupMenu buildPopAudio() {
	JPopupMenu m=new JPopupMenu();
	JMenuItem it=new JMenuItem("播放音乐文件");
	it.addActionListener(new ActionListener() {
	    public void actionPerformed(ActionEvent e) {
		PlayServer.getInst().insertToList(FileItem.choosed);
	    }
	});
	m.add(it);
	it=new JMenuItem("加入播放列表");
	it.addActionListener(new ActionListener() {
	    public void actionPerformed(ActionEvent e) {
		PlayServer.getInst().addToList(FileItem.choosed);
	    }
	});
	m.add(it);
	return m;
    }
    
    public JPopupMenu getPopSite() {
	return popSite;
    }
    
    public JPopupMenu getAudioDir() {
	return popAudio;
    }
}