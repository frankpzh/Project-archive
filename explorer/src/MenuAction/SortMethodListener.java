package MenuAction;

import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.util.Vector;

import javax.swing.JCheckBoxMenuItem;

public class SortMethodListener implements ActionListener {

	private Vector<JCheckBoxMenuItem[]> chooses = new Vector<JCheckBoxMenuItem[]>();

	public void actionPerformed(ActionEvent e) {
		for (int t = 0; t < chooses.size(); t++)
			for (int i = 0; i < chooses.elementAt(t).length; i++)
				chooses.elementAt(t)[i].setSelected(chooses.elementAt(t)[i]
						.getText().equals(
								((JCheckBoxMenuItem) e.getSource()).getText()));
		Explorer.UltraExplorer.fileViewer.setSortMethod(((JCheckBoxMenuItem) e
				.getSource()).getText());
	}

	public SortMethodListener(JCheckBoxMenuItem choose[]) {
		this.chooses.add(choose);
	}
	
	public void addSelectionGroup(JCheckBoxMenuItem choose[]) {
		this.chooses.add(choose);
	}

}
