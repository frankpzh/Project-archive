package AdvancedView;

import java.awt.image.*; 

public class TransparentFilter extends RGBImageFilter { 
	public TransparentFilter() { 
		canFilterIndexColorModel=true; 
	}
	
	public void setColorModel(ColorModel cm) { 
		substituteColorModel(cm,new TransparentModel(cm)); 
	}
	
	public int filterRGB(int x,int y,int pixel) { 
		return pixel; 
	}
}
