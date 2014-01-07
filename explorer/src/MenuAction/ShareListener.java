/*
 * ShareListener.java
 *
 * Created on 2007年8月9日, 上午4:58
 *
 * To change this template, choose Tools | Template Manager
 * and open the template in the editor.
 */

package MenuAction;

import AdvancedView.FileItem;
import Explorer.History;
import FtpProcess.ServerUsers;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.util.Vector;
import javax.swing.JOptionPane;

/**
 *
 * @author Administrator
 */
public class ShareListener implements ActionListener {
	public void actionPerformed(ActionEvent e) {
	    String user=JOptionPane.showInputDialog("请问您要将它共享给哪个用户呢？");
	    Vector<ServerUsers> insts=ServerUsers.listInsts();
	    int i=0;
	    for (;i<insts.size();i++)
		if (insts.elementAt(i).getUser().equals(user))
		    break;
	    if (i>=insts.size()) {
		JOptionPane.showMessageDialog(Explorer.UltraExplorer.mainWindow,"不存在该用户！");
		return;
	    }
	    String name=JOptionPane.showInputDialog("请问您给该目录取什么名字呢？");
	    if (name.equals("")||!insts.elementAt(i).addDirMap(FileItem.choosed.getAbsolutePath(),name)) {
		JOptionPane.showMessageDialog(Explorer.UltraExplorer.mainWindow,"名字为空或者与其他目录冲突！");
		return;
	    }
	    FileItem.choosed.setShared(true);
	    History.getInst().refresh();
	}
    
    
}
