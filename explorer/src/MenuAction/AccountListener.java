package MenuAction;

import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;

public class AccountListener implements ActionListener {

	public void actionPerformed(ActionEvent e) {
		Explorer.ResourceBuilder.getInst().getAccountDialog().setVisible(true);
	}

}
