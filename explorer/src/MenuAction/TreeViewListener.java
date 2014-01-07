package MenuAction;

import javax.swing.*;
import java.awt.event.*;

public class TreeViewListener implements ActionListener {

	private JSplitPane panel;

	private JCheckBoxMenuItem same;

	public void actionPerformed(ActionEvent e) {
		if (same != null)
			same.setSelected(((JCheckBoxMenuItem) e.getSource()).isSelected());
		if (((JCheckBoxMenuItem) e.getSource()).isSelected()) {
			Explorer.UltraExplorer.treeViewWindow.setVisible(true);
			panel
					.setDividerLocation(Explorer.Constants.DEFAULT_DIVIDER_LOCATION);
		} else {
			Explorer.UltraExplorer.treeViewWindow.setVisible(false);
			panel.setDividerLocation(0);
		}
	}

	public void setSame(JCheckBoxMenuItem same) {
		this.same = same;
	}
	
	public TreeViewListener(JSplitPane panel) {
		this.panel = panel;
	}

}
