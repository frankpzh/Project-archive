package AdvancedView;

import java.awt.*;
import java.awt.event.*;

import javax.swing.*;
import javax.swing.table.*;

public class FileTableCellRenderer extends DefaultTableCellRenderer {

	private static final long serialVersionUID = -8400856327904398911L;

	public Component getTableCellRendererComponent(JTable table, Object value,
			boolean isSelected, boolean hasFocus, int row, int column) {
		JLabel res;
		if (column == 0) {
			 res= (JLabel) super.getTableCellRendererComponent(table, value,
						isSelected, hasFocus, row, column);
			res.setIcon(((FileTableModel) table.getModel()).getFile(row)
					.getSystemIcon());
		}else {
			 res= (JLabel) super.getTableCellRendererComponent(table, value,
						false,false, row, column);
		}
		res.addMouseListener(new DblClickListener(((FileTableModel) table.getModel()).getFile(row)));
		return res;
	}

	private class DblClickListener extends MouseAdapter {

		private FileItem file;

		public void mouseClicked(MouseEvent e) {
			if (e.getClickCount() == 2 && e.getButton() == MouseEvent.BUTTON1)
				file.doAction();
		}

		public DblClickListener(FileItem file) {
			this.file = file;
		}

	}

}
