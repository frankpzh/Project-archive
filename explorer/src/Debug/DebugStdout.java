package Debug;

public class DebugStdout {
	public static void error(String out) {
		System.err.println(out);
		new Exception().printStackTrace();
	}

	public static void warning(String out) {
		System.err.println(out);
		new Exception().printStackTrace();
	}

	public static void notice(String out) {
		System.err.println(out);
		new Exception().printStackTrace();
	}

	public static void assume(boolean yes) {
		if (!yes) {
			System.err.println("Assumption failed!!");
			new Exception().printStackTrace();
		}
	}
}
