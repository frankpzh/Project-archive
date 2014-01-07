package MenuAction;

import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;

public class SetupListener implements ActionListener {

	public void actionPerformed(ActionEvent e) {
		Explorer.ResourceBuilder.getInst().getSetupDialog().setVisible(true);
	}

}
