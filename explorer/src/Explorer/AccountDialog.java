package Explorer;

import javax.swing.JFrame;

public class AccountDialog {

	private static JFrame inst;
	
	private AccountDialog() {
	}

	public static JFrame build() {
		if (inst!=null) return inst;
		return (inst=new AccountFrame());
	}

}
