package AdvancedView;

import java.awt.*;

public class FlowLayoutEx extends FlowLayout {

	private static final long serialVersionUID = -8638424357341621986L;

	public FlowLayoutEx(int p) {
		super(p);
	}
	
    public void layoutContainer(Container target) {
    	super.layoutContainer(target);
    	if (target.getComponentCount()>0) {
	    	Component tmp=target.getComponent(target.getComponentCount()-1);
	   		int height=tmp.getY()+tmp.getHeight();
	    	Dimension d=target.getPreferredSize();
	    	d.height=Math.max(height,target.getSize().height);
	    	target.setSize(d);
	    	target.setPreferredSize(d);
    	}
    }
}
