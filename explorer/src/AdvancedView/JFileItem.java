package AdvancedView;

import java.io.*;
import java.awt.*;

import javax.swing.*;
import javax.imageio.*;
import java.awt.image.*;

public class JFileItem extends JComponent {
    
    private static final long serialVersionUID = 5371873002192022977L;
    
    private int style;
    
    private JLabel label;
    
    private FileItem file;
    
    private FileItemModel model;
    
    public static int height = 120, width = 120;
    
    private static Boolean first = true;
    
    private static Image borderRoll, borderSelect;
    
    public String getToolTipText() {
	return file.getPath();
    }
    
    public JToolTip createToolTip() {
	JToolTip tip = new JToolTipEx();
	return tip;
    }
    
    public JFileItem(FileItem file, int style) {
	Debug.DebugStdout.assume(style == JFileViewer.THUMBNAILS
	    || style == JFileViewer.TILES);
	this.style = style;
	this.file = file;
	this.model = new FileItemModel(this);
	initBorder();
	
	Icon ico=null;
	if (this.style == JFileViewer.THUMBNAILS)
	    if (file.getType()==FileItem.ON_LOCAL&&file.isFile())
		ico=file.makeIcon(64,64);
	if (ico==null) ico=file.getIcon();
	this.add(label = new JLabel(file.getName(), ico,
	    JLabel.CENTER));
	label.setVerticalTextPosition(JLabel.BOTTOM);
	label.setHorizontalTextPosition(JLabel.CENTER);
	label.setFont(Explorer.UltraExplorer.msyh
	    .deriveFont(Font.PLAIN, 12));
	label.setSize(width * 4 / 5, height * 4 / 5);
	label.setLocation((width - label.getSize().width) / 2,
	    (height - label.getSize().height) / 2);
	
	ToolTipManager ttm = ToolTipManager.sharedInstance();
	ttm.setInitialDelay(500);
	ttm.setReshowDelay(10);
	ttm.registerComponent(this);
	
	this.setFocusable(true);
	this.setPreferredSize(new Dimension(width, height));
	this.addFocusListener(model);
	this.addMouseListener(model);
    }
    
    private void initBorder() {
	if (first) {
	    try {
		borderSelect = ImageIO.read(new File("Icons//border.png"));
		borderRoll = createImage(new FilteredImageSource(borderSelect
		    .getSource(), new TransparentFilter()));
	    } catch (Exception e) {
		borderRoll = borderSelect = null;
	    } finally {
		first = false;
	    }
	}
    }
    
    public FileItemModel getModel() {
	return model;
    }
    
    public FileItem getFile() {
	return file;
    }
    
    protected void paintComponent(Graphics g) {
	if (model.isSelected()) {
	    g.drawImage(borderSelect, 0, 0, this.getWidth(), this.getHeight(),
		null);
	} else if (model.hasFocus() || model.isRollover()) {
	    g.drawImage(borderRoll, 0, 0, this.getWidth(), this.getHeight(),
		null);
	}
    }
    
}
