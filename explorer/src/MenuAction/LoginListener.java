/*
 * LoginListener.java
 *
 * Created on 2007年8月9日, 上午6:28
 *
 * To change this template, choose Tools | Template Manager
 * and open the template in the editor.
 */

package MenuAction;

import AdvancedView.FileItem;
import Explorer.LoginFrame;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.util.Vector;

/**
 *
 * @author Administrator
 */
public class LoginListener implements ActionListener {
	public void actionPerformed(ActionEvent e) {
	    Vector<String> info=new Vector<String>();
	    info.add(FileItem.choosed.ftp.getUser());
	    info.add(FileItem.choosed.ftp.getPass());
	    LoginFrame.getInst(info).setVisible(true);
	    if (info.size()==2) {
		FileItem.choosed.ftp.setUser(info.elementAt(0),info.elementAt(1));
		FileItem.choosed.ftp.checkSite();
		
	    }
	}
    
}
