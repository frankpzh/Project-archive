package AdvancedView;

import java.awt.Component;
import java.util.*;
import java.awt.event.*;

public class FileItemModel implements MouseListener, FocusListener {

	private JFileItem base;

	private boolean pressed, rollover, focus, selected;

	static private Vector<JFileItem> selection = new Vector<JFileItem>();

	private ArrayList<ActionListener> actionList = new ArrayList<ActionListener>();

	public FileItemModel(JFileItem base) {
		this.base = base;
	}

	public void addActionListener(ActionListener l) {
		actionList.add(l);
	}

	public boolean hasFocus() {
		return focus;
	}

	public boolean isPressed() {
		return pressed;
	}

	public boolean isRollover() {
		return rollover;
	}

	public boolean isSelected() {
		return selected;
	}

	public void removeActionListener(ActionListener l) {
		actionList.remove(l);
	}

	public static void setSelected(Vector<JFileItem> files) {
		if (selection.size() > 0)
			for (int i = selection.size() - 1; i >= 0; i--)
				selection.elementAt(i).getModel().setSelected(false);
		selection = files;
		if (selection.size() > 0)
			for (int i = selection.size() - 1; i >= 0; i--)
				selection.elementAt(i).getModel().setSelected(true);
	}

	public void setSelected(boolean b) {
		selected = b;
		base.repaint();
	}

	public void clearSelected() {
		if (selection.size() > 0)
			for (int i = selection.size() - 1; i >= 0; i--)
				selection.elementAt(i).getModel().setSelected(false);
	}

	public void mouseClicked(MouseEvent e) {
		if (e.getButton() == MouseEvent.BUTTON1) {
			if ((e.getModifiers() & InputEvent.CTRL_MASK) == 0) {
				if (selection.size() > 0)
					for (int i = selection.size() - 1; i >= 0; i--)
						selection.elementAt(i).getModel().setSelected(false);
				selection.clear();
			}
			selection.add(base);
			selected = true;
			base.requestFocus();
			base.repaint();
			if (e.getClickCount() == 2) {
				for (int i = 0; i < actionList.size(); i++)
					actionList.get(i).actionPerformed(
							new ActionEvent(this, ActionEvent.ACTION_PERFORMED,
									"dblclick"));
				base.getFile().doAction();
			}
		} else
			base.getFile().doRight((Component)e.getSource(),e.getPoint());
	}

	public void mouseEntered(MouseEvent e) {
		rollover = true;
		base.repaint();
	}

	public void mouseExited(MouseEvent e) {
		rollover = false;
		base.repaint();
	}

	public void mousePressed(MouseEvent e) {
		pressed = true;
		base.repaint();
	}

	public void mouseReleased(MouseEvent e) {
		pressed = false;
		base.repaint();
	}

	public Object[] getSelectedObjects() {
		return selection.toArray();
	}

	public void focusGained(FocusEvent e) {
		focus = true;
		base.repaint();
	}

	public void focusLost(FocusEvent e) {
		focus = false;
		base.repaint();
	}

}
