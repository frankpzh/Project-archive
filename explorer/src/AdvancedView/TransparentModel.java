package AdvancedView;

import java.awt.image.*;

public class TransparentModel extends ColorModel {
	
	ColorModel sourceModel;
	
	public TransparentModel(ColorModel sourceModel) { 
		super(sourceModel.getPixelSize()); 
		this.sourceModel=sourceModel; 
	}
	
	public int getAlpha(int pixel) { 
		return (sourceModel.getAlpha(pixel)<=128)?0:sourceModel.getAlpha(pixel)-128; 
	}
	
	public int getRed(int pixel) { 
		return sourceModel.getRed(pixel); 
	} 
	
	public int getGreen(int pixel) { 
		return sourceModel.getGreen(pixel); 
	}
	
	public int getBlue(int pixel) { 
		return sourceModel.getBlue(pixel); 
	}
	
	public int getRGB(int pixel) { 
		return (getAlpha(pixel)<<24)+(getRed(pixel)<<16)+(getGreen(pixel)<<8)+getBlue(pixel); 
	} 
	
} 

