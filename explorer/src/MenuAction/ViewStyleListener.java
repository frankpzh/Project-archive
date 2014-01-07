package MenuAction;

import java.util.*;
import javax.swing.*;

import java.awt.event.*;

public class ViewStyleListener implements ActionListener {

	private Vector<JCheckBoxMenuItem[]> chooses=new Vector<JCheckBoxMenuItem[]>();

	public void actionPerformed(ActionEvent e) {
		for (int t = 0; t < chooses.size(); t++)
			for (int i = 0; i < chooses.elementAt(t).length; i++)
				chooses.elementAt(t)[i].setSelected(chooses.elementAt(t)[i]
						.getText().equals(
								((JCheckBoxMenuItem) e.getSource()).getText()));
		Explorer.UltraExplorer.fileViewer.setStyle(((JCheckBoxMenuItem) e
				.getSource()).getText());
	}

	public ViewStyleListener(JCheckBoxMenuItem choose[]) {
		this.chooses.add(choose);
	}
	
	public void addSelectionGroup(JCheckBoxMenuItem choose[]) {
		this.chooses.add(choose);
	}

}
