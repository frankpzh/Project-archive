package AdvancedView;

import java.text.NumberFormat;
import java.util.*;
import javax.swing.table.*;

public class FileTableModel extends AbstractTableModel {

	private static final long serialVersionUID = 7106208104349948741L;

	private Vector<FileItem> files;

	public FileTableModel(Vector<FileItem> files) {
		this.files = files;
	}

	public int getColumnCount() {
		return 4;
	}

	public FileItem getFile(int row) {
		return files.elementAt(row);
	}

	public String getColumnName(int col) {
		switch (col) {
		case 0:
			return java.util.ResourceBundle.getBundle("language").getString("Filename");
		case 1:
			return java.util.ResourceBundle.getBundle("language").getString("Size");
		case 2:
			return java.util.ResourceBundle.getBundle("language").getString("Type");
		case 3:
			return java.util.ResourceBundle.getBundle("language").getString("Last_Modified");
		}
		return null;
	}

	public int getRowCount() {
		return files.size();
	}

	public Object getValueAt(int row, int col) {
		switch (col) {
		case 0:
			return files.elementAt(row).getName();
		case 1:
			if (files.elementAt(row).isDirectory())
				return "";
			else
				return formatLength(files.elementAt(row).length());
		case 2:
			if (files.elementAt(row).isDirectory())
				return "";
			else
				return files.elementAt(row).getExtension();
		case 3:
			return formatDate(files.elementAt(row).lastModified());
		}
		return null;
	}

	private String formatLength(long len) {
		double length = len;
		NumberFormat nf = NumberFormat.getInstance();
		nf.setMinimumFractionDigits(0);
		nf.setMaximumFractionDigits(2);
		if (length >= 1024) {
			length /= 1024;
			if (length >= 1024) {
				length /= 1024;
				if (length >= 1024) {
					length /= 1024;
					return nf.format(length) + " GB";
				} else
					return nf.format(length) + " MB";
			} else
				return nf.format(length) + " KB";
		} else
			return nf.format(length) + " B";
	}

	private String formatDate(long sec) {
		NumberFormat nf = NumberFormat.getInstance();
		nf.setMinimumIntegerDigits(2);
		nf.setMaximumIntegerDigits(2);
		Calendar cal = Calendar.getInstance();
		cal.setTimeInMillis(sec);
		return cal.get(Calendar.YEAR) + java.util.ResourceBundle.getBundle("language").getString("Äê") + (cal.get(Calendar.MONTH) + 1)
				+ java.util.ResourceBundle.getBundle("language").getString("ÔÂ") + cal.get(Calendar.DAY_OF_MONTH) + java.util.ResourceBundle.getBundle("language").getString("ÈÕ_")
				+ nf.format(cal.get(Calendar.HOUR_OF_DAY)) + ":"
				+ nf.format(cal.get(Calendar.MINUTE));
	}

}
