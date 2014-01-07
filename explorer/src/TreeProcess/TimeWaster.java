package TreeProcess;

import java.awt.*;
import java.awt.image.*;

public class TimeWaster implements Runnable {
    
    Component base;
    
    public void run() {
	if (base==null) return;
	try {
	    Graphics g=base.getGraphics().create();
	    Component tmp=base;
	    int x=base.getX(),y=base.getY();
	    while ((tmp=tmp.getParent())!=null) {
		x+=tmp.getX();
		y+=tmp.getY();
	    }
	    Rectangle rect=new Rectangle(x,y,base.getWidth(),base.getHeight());
	    BufferedImage screen=new Robot().createScreenCapture(rect);
	    Graphics g1=screen.getGraphics();
	    g1.setColor(new Color(0.5f,0.6f,0.75f,0.7f));
	    g1.fillRect(0,0,base.getWidth(),base.getHeight());
	    int l=base.getWidth()/2-50;
	    int t=base.getHeight()/2-10;
	    int i=0,dir=1;
	    for (;;) {
		for (int j=0;j<2;j++) {
		    i+=dir;
		    if (i==74) dir=-1;
		    if (i==0) dir=1;
		}
		g1.setColor(new Color(0.5f,0.6f,0.75f,1f));
		g1.drawRect(l,t,100,20);
		g1.setColor(new Color(1f,1f,1f,1f));
		g1.fillRect(l+1,t+1,98,18);
		g1.setColor(new Color(0.5f,0.6f,0.75f,1f));
		g1.fillRect(l+i+1,t+1,25,18);
		Thread.sleep(30);
		g.drawImage(screen,0,0,null);
	    }
	}catch(Exception e){
	    base.repaint();
	}
    }
    
    public TimeWaster(Component base) {
	this.base=base;
    }
    
}
