package MenuAction;

import javax.swing.*;

import java.awt.event.*;

public class ToolbarListener implements ActionListener {

	private JToolBar toolbar;

	private JCheckBoxMenuItem same;

	public void actionPerformed(ActionEvent e) {
		if (same != null)
			same.setSelected(((JCheckBoxMenuItem) e.getSource()).isSelected());
		toolbar.setVisible(((JCheckBoxMenuItem) e.getSource()).isSelected());
	}

	public void setSame(JCheckBoxMenuItem same) {
		this.same = same;
	}

	public ToolbarListener(JToolBar toolbar) {
		this.toolbar = toolbar;
	}

}
