/*
 * ShareListener.java
 *
 * Created on 2007��8��9��, ����4:58
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
	    String user=JOptionPane.showInputDialog("������Ҫ����������ĸ��û��أ�");
	    Vector<ServerUsers> insts=ServerUsers.listInsts();
	    int i=0;
	    for (;i<insts.size();i++)
		if (insts.elementAt(i).getUser().equals(user))
		    break;
	    if (i>=insts.size()) {
		JOptionPane.showMessageDialog(Explorer.UltraExplorer.mainWindow,"�����ڸ��û���");
		return;
	    }
	    String name=JOptionPane.showInputDialog("����������Ŀ¼ȡʲô�����أ�");
	    if (name.equals("")||!insts.elementAt(i).addDirMap(FileItem.choosed.getAbsolutePath(),name)) {
		JOptionPane.showMessageDialog(Explorer.UltraExplorer.mainWindow,"����Ϊ�ջ���������Ŀ¼��ͻ��");
		return;
	    }
	    FileItem.choosed.setShared(true);
	    History.getInst().refresh();
	}
    
    
}
