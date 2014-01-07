/*
 * AddFavoriteListener.java
 *
 * Created on 2007年8月9日, 上午4:53
 *
 * To change this template, choose Tools | Template Manager
 * and open the template in the editor.
 */

package MenuAction;

import AdvancedView.FileItem;
import Explorer.ExplorerConfig;
import Explorer.History;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;

/**
 *
 * @author Administrator
 */
public class AddFavoriteListener implements ActionListener {
	public void actionPerformed(ActionEvent e) {
	    FileItem.choosed.setTemp(false);
	    ExplorerConfig.getInst().sites.add(FileItem.choosed.ftp);
	    History.getInst().refresh();
	}
    
}
