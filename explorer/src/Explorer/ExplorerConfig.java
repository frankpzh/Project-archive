package Explorer;

import java.io.*;
import java.nio.charset.Charset;
import java.util.Stack;
import java.util.Vector;

import javax.swing.JCheckBoxMenuItem;
import javax.swing.JOptionPane;
import javax.xml.parsers.SAXParser;
import javax.xml.parsers.SAXParserFactory;

import org.xml.sax.Attributes;
import org.xml.sax.SAXException;
import org.xml.sax.helpers.DefaultHandler;

import FtpProcess.FtpClientProxy;
import FtpProcess.ServerUsers;
import FtpProcess.ServerUsers.DirMap;

public class ExplorerConfig {

	private class ConfigHandler extends DefaultHandler {

		private Stack<String> path = new Stack<String>();
		
		private int port;
		private Vector<DirMap> maps;
		private String user,pass,name,addr,orig,virt;

		@Override
		public void characters(char[] ch, int start, int length)
				throws SAXException {
			try {
				String str = path.lastElement(), value = new String(ch, start,
						length);
				if (value.indexOf("\n") != -1)
					return;
				if (str.equals("UltraExplorerConfig/ExplorerConfig/ViewMode"))
					viewMode = value;
				else if (str
						.equals("UltraExplorerConfig/ExplorerConfig/SortMode"))
					sortMode = value;
				else if (str
						.equals("UltraExplorerConfig/ServerConfig/BindingPort"))
					serverPort = new Integer(value);
				else if (str.equals("UltraExplorerConfig/ServerConfig/Timeout"))
					serverTimeOut = new Integer(value);
				else if (str.equals("UltraExplorerConfig/ClientConfig/Timeout"))
					clientTimeOut = new Integer(value);
				else if (str.equals("UltraExplorerConfig/ClientConfig/Site/name"))
					name = value;
				else if (str.equals("UltraExplorerConfig/ClientConfig/Site/address"))
					addr = value;
				else if (str.equals("UltraExplorerConfig/ClientConfig/Site/username"))
					user = value;
				else if (str.equals("UltraExplorerConfig/ClientConfig/Site/password"))
					pass = value;
				else if (str.equals("UltraExplorerConfig/ClientConfig/Site/port"))
					port = new Integer(value);
				else if (str.equals("UltraExplorerConfig/ServerConfig/Account/username"))
					user = value;
				else if (str.equals("UltraExplorerConfig/ServerConfig/Account/password"))
					pass = value;
				else if (str.equals("UltraExplorerConfig/ServerConfig/Account/DirMap/name"))
					virt = value;
				else if (str.equals("UltraExplorerConfig/ServerConfig/Account/DirMap/original"))
					orig = value;
			} catch (Exception e) {
				throw new SAXException();
			}
		}

		@Override
		public void endElement(String uri, String localName, String qName)
				throws SAXException {
			String str = path.pop();
			if (str.equals("UltraExplorerConfig/ClientConfig/Site"))
				sites.add(new FtpClientProxy(addr, port, user, pass, name));
			else if (str.equals("UltraExplorerConfig/ServerConfig/Account")) {
				if (user==null) throw new SAXException();
				ServerUsers acct=ServerUsers.getInst(user, pass);
				for (int i=0;i<maps.size();i++)
					acct.addDirMap(maps.elementAt(i).getActuralStr(), maps.elementAt(i).getVirtual());
			}
			else if (str.equals("UltraExplorerConfig/ServerConfig/Account/DirMap")) {
				if (orig==null||virt==null) throw new SAXException();
				maps.add(ServerUsers.getInst("","").new DirMap(orig, virt));
			}
		}

		@Override
		public void startElement(String uri, String localName, String qName,
				Attributes attributes) throws SAXException {
			String str = path.empty() ? qName : path.lastElement() + "/"
					+ qName;
			path.push(str);
			if (str.equals("UltraExplorerConfig/ExplorerConfig/ToolBar"))
				hasToolBar = true;
			else if (str.equals("UltraExplorerConfig/ExplorerConfig/TreeView"))
				hasTreeView = true;
			else if (str.equals("UltraExplorerConfig/ServerConfig/Account")) {
				maps=new Vector<DirMap>();
				user=pass=null;
			}
			else if (str.equals("UltraExplorerConfig/ServerConfig/Account/DirMap"))
				orig=virt=null;
		}

	}

	public static final int VIEWMODE = 0;

	public static final int SORTMODE = 1;

	public static final int HASTOOLBAR = 2;

	public static final int HASTREEVIEW = 3;

	public static final int CLIENTTIMEOUT = 4;

	public static final int CLIENTSITES = 5;

	public static final int SERVERPORT = 6;

	public static final int SERVERTIMEOUT = 7;

	private static ExplorerConfig inst;

	public Vector<FtpClientProxy> sites;

	private String viewMode, sortMode;

	private boolean hasToolBar, hasTreeView;

	int serverPort, serverTimeOut, clientTimeOut;

	public static ExplorerConfig getInst() {
		if (inst == null) {
			inst = new ExplorerConfig();
			inst.readConfig();
		}
		return inst;
	}

	private ExplorerConfig() {
		sites = new Vector<FtpClientProxy>();
	}

	public Object get(int id) {
		switch (id) {
		case VIEWMODE:
			return viewMode;
		case SORTMODE:
			return sortMode;
		case HASTOOLBAR:
			return hasToolBar;
		case HASTREEVIEW:
			return hasTreeView;
		case CLIENTTIMEOUT:
			return clientTimeOut;
		case CLIENTSITES:
			return sites;
		case SERVERPORT:
			return serverPort;
		case SERVERTIMEOUT:
			return serverTimeOut;
		default:
			Debug.DebugStdout.assume(false);
			return null;
		}
	}

	void writeConfig() {
		grabConfig();
		try {
			OutputStreamWriter fout = new OutputStreamWriter(new FileOutputStream(new File("config.xml")),Charset.forName("UTF-8"));
			fout.write("<?xml version=\"1.0\"?>\n\n");
			fout.write("<UltraExplorerConfig>\n\n");
			fout.write("\t<ExplorerConfig>\n");
			fout.write("\t\t<ViewMode>" + viewMode + "</ViewMode>\n");
			fout.write("\t\t<SortMode>" + sortMode + "</SortMode>\n");
			if (hasToolBar)
				fout.write("\t\t<ToolBar />\n");
			if (hasTreeView)
				fout.write("\t\t<TreeView />\n");
			fout.write("\t</ExplorerConfig>\n\n");
			fout.write("\t<ServerConfig>\n\n");
			fout.write("\t\t<BindingPort>" + serverPort + "</BindingPort>\n\n");
			fout.write("\t\t<Timeout>" + serverTimeOut + "</Timeout>\n\n");
			ServerUsers.writeToConfig(fout);
			fout.write("\t</ServerConfig>\n\n");
			fout.write("\t<ClientConfig>\n");
			fout.write("\t\t<Timeout>" + clientTimeOut + "</Timeout>\n\n");
			for (int i = 0; i < sites.size(); i++)
				sites.elementAt(i).writeToConfig(fout);
			fout.write("\t</ClientConfig>\n\n");
			fout.write("</UltraExplorerConfig>\n");
			fout.close();
		} catch (Exception e) {
			JOptionPane.showMessageDialog(Explorer.UltraExplorer.mainSplitPane,
					java.util.ResourceBundle.getBundle("language").getString("Error_to_save_config_file!"), java.util.ResourceBundle.getBundle("language").getString("Config_System"),
					JOptionPane.ERROR_MESSAGE);
		}
	}

	private void grabConfig() {
		hasToolBar = ((JCheckBoxMenuItem) ResourceBuilder.getInst()
				.getViewPopupMenu().getSubElements()[0]).isSelected();
		hasTreeView = ((JCheckBoxMenuItem) ResourceBuilder.getInst()
				.getViewPopupMenu().getSubElements()[1]).isSelected();
		for (int i = 2; i <= 5; i++)
			if (((JCheckBoxMenuItem) ResourceBuilder.getInst()
					.getViewPopupMenu().getSubElements()[i]).isSelected())
				viewMode = ((JCheckBoxMenuItem) ResourceBuilder.getInst()
						.getViewPopupMenu().getSubElements()[i]).getText();
		for (int i = 0; i <= 3; i++)
			if (((JCheckBoxMenuItem) ResourceBuilder.getInst()
					.getViewPopupMenu().getSubElements()[6].getSubElements()[0]
					.getSubElements()[i]).isSelected())
				sortMode = ((JCheckBoxMenuItem) ResourceBuilder.getInst()
						.getViewPopupMenu().getSubElements()[6]
						.getSubElements()[0].getSubElements()[i]).getText();
	}

	void commitConfig() {
		UltraExplorer.startFTPServer();
		if (((JCheckBoxMenuItem) ResourceBuilder.getInst().getViewPopupMenu()
				.getSubElements()[0]).isSelected() != hasToolBar)
			((JCheckBoxMenuItem) ResourceBuilder.getInst().getViewPopupMenu()
					.getSubElements()[0]).doClick();
		if (((JCheckBoxMenuItem) ResourceBuilder.getInst().getViewPopupMenu()
				.getSubElements()[1]).isSelected() != hasTreeView)
			((JCheckBoxMenuItem) ResourceBuilder.getInst().getViewPopupMenu()
					.getSubElements()[1]).doClick();
		for (int i = 2; i <= 5; i++)
			if (((JCheckBoxMenuItem) ResourceBuilder.getInst()
					.getViewPopupMenu().getSubElements()[i]).getText()
					.equalsIgnoreCase(viewMode))
				((JCheckBoxMenuItem) ResourceBuilder.getInst()
						.getViewPopupMenu().getSubElements()[i]).doClick();
		for (int i = 0; i <= 3; i++)
			if (((JCheckBoxMenuItem) ResourceBuilder.getInst()
					.getViewPopupMenu().getSubElements()[6].getSubElements()[0]
					.getSubElements()[i]).getText().equalsIgnoreCase(sortMode))
				((JCheckBoxMenuItem) ResourceBuilder.getInst()
						.getViewPopupMenu().getSubElements()[6]
						.getSubElements()[0].getSubElements()[i]).doClick();
	}

	private void readConfig() {
		viewMode = java.util.ResourceBundle.getBundle("language").getString("tiles");
		sortMode = java.util.ResourceBundle.getBundle("language").getString("name");
		serverPort = 21;
		serverTimeOut = 1000;
		clientTimeOut = 1000;
		hasToolBar = false;
		hasTreeView = false;
		try {
			SAXParser brain = SAXParserFactory.newInstance().newSAXParser();
			brain.parse(new File("config.xml"), new DefaultHandler());
			brain.parse(new File("config.xml"), new ConfigHandler());
		} catch (Exception e) {
			e.printStackTrace();
			JOptionPane.showMessageDialog(Explorer.UltraExplorer.mainSplitPane,
					java.util.ResourceBundle.getBundle("language").getString("Error_to_read_config_file!"), java.util.ResourceBundle.getBundle("language").getString("Config_System"),
					JOptionPane.ERROR_MESSAGE);
			hasToolBar = true;
			hasTreeView = true;
		}
	}
}