/*
 * PlayServer.java
 *
 * Created on 2007年8月9日, 下午1:25
 *
 * To change this template, choose Tools | Template Manager
 * and open the template in the editor.
 */

package Player;

import java.io.File;
import java.util.Vector;
import javax.media.*;

public class PlayServer implements Runnable {
    
    private static PlayServer inst;
    
    private Thread playServer;
    private Vector<File> list=new Vector<File>();
    
    private PlayServer() {
    }
    
    public static synchronized PlayServer getInst() {
	if (inst==null)
	    inst=new PlayServer();
	return inst;
    }
    
    public synchronized void addToList(File f) {
	list.add(f);
    }
    
    public synchronized void clearList() {
	stop();
	list.clear();
	play();
    }
    
    public synchronized void next() {
	if (alive()&&!list.isEmpty()) {
	    stop();
	    list.remove(0);
	    play();
	}
    }
    
    public synchronized void insertToList(File f) {
	if (alive())
	    stop();
	list.add(0,f);
	play();
    }
    
    public synchronized boolean alive() {
	return (playServer!=null&&playServer.isAlive());
    }
    
    public synchronized boolean listEmpty() {
	return list.isEmpty();
    }
    
    public synchronized void play() {
	if (alive()) return;
	playServer=new Thread(this);
	playServer.start();
    }
    
    public synchronized void stop() {
	if (alive())
	    playServer.interrupt();
	playServer=null;
    }
    
    public void run() {
	Player p=null;
	try {
	    while(true) {
		while (list.isEmpty())
		    Thread.sleep(100);
		try {
		    p=Manager.createRealizedPlayer(list.elementAt(0).toURI().toURL());
		}catch(Exception e) {
		    list.remove(0);
		    continue;
		}
		p.start();
		while(p.getState()!=Player.Prefetched)
		    Thread.sleep(1000);
		list.remove(0);
		p.stop();
		p.close();
	    }
	}catch(Exception e){
	}finally {
	    if (p!=null) {
		p.stop();
		p.close();
	    }
	}
    }
    
}
