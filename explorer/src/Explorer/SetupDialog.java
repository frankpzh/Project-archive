package Explorer;

import javax.swing.JFrame;

public class SetupDialog {
	
	private static JFrame inst;
	
	private SetupDialog() {
	}

	public static JFrame build() {
		if (inst!=null) return inst;
		return (inst=new SetupFrame());
	}

}
