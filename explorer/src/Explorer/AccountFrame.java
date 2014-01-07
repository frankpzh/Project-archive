/*
 * AccountFrame.java
 *
 * Created on 2007年8月9日, 上午1:47
 */

package Explorer;

import FtpProcess.ServerUsers;
import java.awt.CardLayout;
import java.util.ArrayList;
import java.util.Vector;
import javax.swing.JOptionPane;
import javax.swing.ListModel;
import javax.swing.event.ListDataEvent;
import javax.swing.event.ListDataListener;

/**
 *
 * @author  Administrator
 */
public class AccountFrame extends javax.swing.JFrame {
    
	private static final long serialVersionUID = -3842482288461498025L;

	private class MapModel implements ListModel {
	
	ServerUsers user;
	ServerUsers.DirMap[] maps;
	private ArrayList<ListDataListener> listeners=new ArrayList<ListDataListener>();
	
	public MapModel(ServerUsers user) {
	    this.user=user;
	    if (user==null)
		maps=new ServerUsers.DirMap[0];
	    else
		maps=user.getMaps();
	}
	
	public int getSize() {
	    return maps.length;
	}
	
	public void rename(int index,String newName) {
	    user.rename(maps[index].getVirtual(),newName);
	}
	
	public Object getElementAt(int index) {
	    return maps[index].getActuralStr();
	}
	
	public void addListDataListener(ListDataListener l) {
	    listeners.add(l);
	}
	
	public void removeListDataListener(ListDataListener l) {
	    listeners.remove(l);
	}
	
	private void delete(int index) {
	    user.delete(maps[index].getVirtual());
	    maps=user.getMaps();
	    for (int i=listeners.size()-1;i>=0;i--)
		listeners.get(i).contentsChanged(new ListDataEvent(this,ListDataEvent.CONTENTS_CHANGED,0,maps.length));
	}
	
	private String getVirtual(int i) {
	    return maps[i].getVirtual();
	}
    }
    
    private class UserListModel implements ListModel {
	
	private Vector<ServerUsers> users;
	private ArrayList<ListDataListener> listeners=new ArrayList<ListDataListener>();
	
	public UserListModel() {
	    users=ServerUsers.listInsts();
	}
	
	public int getSize() {
	    return users.size();
	}
	
	public Object getElementAt(int index) {
	    return users.elementAt(index).getUser();
	}
	
	public ServerUsers getUser(int index) {
	    return users.elementAt(index);
	}
	
	public void addListDataListener(ListDataListener l) {
	    listeners.add(l);
	}
	
	public void removeListDataListener(ListDataListener l) {
	    listeners.remove(l);
	}
	
	private void delete(int index) {
	    users.remove(index);
	    for (int i=listeners.size()-1;i>=0;i--)
		listeners.get(i).intervalRemoved(new ListDataEvent(this,ListDataEvent.INTERVAL_REMOVED,index,index));
	}
	
	private void change() {
	    for (int i=listeners.size()-1;i>=0;i--)
		listeners.get(i).contentsChanged(new ListDataEvent(this,ListDataEvent.CONTENTS_CHANGED,0,users.size()));
	}
	
    }
    
    /** Creates new form AccountFrame */
    public AccountFrame() {
	initComponents();
	userList.setModel(new UserListModel());
    }
    
    /** This method is called from within the constructor to
     * initialize the form.
     * WARNING: Do NOT modify this code. The content of this method is
     * always regenerated by the Form Editor.
     */
    // <editor-fold defaultstate="collapsed" desc=" 生成的代码 ">//GEN-BEGIN:initComponents
    private void initComponents() {
        java.awt.GridBagConstraints gridBagConstraints;

        jPanel1 = new javax.swing.JPanel();
        jScrollPane1 = new javax.swing.JScrollPane();
        userList = new javax.swing.JList();
        jPanel3 = new javax.swing.JPanel();
        jButton1 = new javax.swing.JButton();
        jButton2 = new javax.swing.JButton();
        jButton3 = new javax.swing.JButton();
        jPanel2 = new javax.swing.JPanel();
        jLabel1 = new javax.swing.JLabel();
        jLabel2 = new javax.swing.JLabel();
        userName = new javax.swing.JTextField();
        jScrollPane2 = new javax.swing.JScrollPane();
        mapList = new javax.swing.JList();
        jPanel4 = new javax.swing.JPanel();
        jButton4 = new javax.swing.JButton();
        jButton5 = new javax.swing.JButton();
        jPanel5 = new javax.swing.JPanel();
        jButton6 = new javax.swing.JButton();
        jButton7 = new javax.swing.JButton();
        passWord = new javax.swing.JPasswordField();
        jPanel6 = new javax.swing.JPanel();
        jLabel3 = new javax.swing.JLabel();
        dirName = new javax.swing.JTextField();
        jPanel7 = new javax.swing.JPanel();
        jButton9 = new javax.swing.JButton();
        jButton8 = new javax.swing.JButton();

        getContentPane().setLayout(new java.awt.CardLayout());

        setTitle("\u8d26\u53f7\u8bbe\u7f6e");
        jPanel1.setLayout(new java.awt.BorderLayout());

        userList.setSelectionMode(javax.swing.ListSelectionModel.SINGLE_SELECTION);
        jScrollPane1.setViewportView(userList);

        jPanel1.add(jScrollPane1, java.awt.BorderLayout.CENTER);

        jButton1.setText("\u65b0\u5efa\u8d26\u53f7");
        jButton1.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                jButton1ActionPerformed(evt);
            }
        });

        jPanel3.add(jButton1);

        jButton2.setText("\u5220\u9664\u8d26\u53f7");
        jButton2.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                jButton2ActionPerformed(evt);
            }
        });

        jPanel3.add(jButton2);

        jButton3.setText("\u8bbe\u7f6e\u5e10\u53f7");
        jButton3.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                jButton3ActionPerformed(evt);
            }
        });

        jPanel3.add(jButton3);

        jPanel1.add(jPanel3, java.awt.BorderLayout.SOUTH);

        getContentPane().add(jPanel1, "cardUserList");

        jPanel2.setLayout(new java.awt.GridBagLayout());

        jLabel1.setText("\u8d26\u53f7\u540d:");
        gridBagConstraints = new java.awt.GridBagConstraints();
        gridBagConstraints.fill = java.awt.GridBagConstraints.BOTH;
        jPanel2.add(jLabel1, gridBagConstraints);

        jLabel2.setText("\u5bc6\u7801:");
        gridBagConstraints = new java.awt.GridBagConstraints();
        gridBagConstraints.gridx = 0;
        gridBagConstraints.gridy = 1;
        gridBagConstraints.fill = java.awt.GridBagConstraints.BOTH;
        jPanel2.add(jLabel2, gridBagConstraints);

        userName.setPreferredSize(new java.awt.Dimension(100, 21));
        gridBagConstraints = new java.awt.GridBagConstraints();
        gridBagConstraints.fill = java.awt.GridBagConstraints.HORIZONTAL;
        jPanel2.add(userName, gridBagConstraints);

        jScrollPane2.setMinimumSize(new java.awt.Dimension(258, 130));
        mapList.setSelectionMode(javax.swing.ListSelectionModel.SINGLE_SELECTION);
        jScrollPane2.setViewportView(mapList);

        gridBagConstraints = new java.awt.GridBagConstraints();
        gridBagConstraints.gridx = 0;
        gridBagConstraints.gridy = 2;
        gridBagConstraints.gridwidth = 2;
        gridBagConstraints.fill = java.awt.GridBagConstraints.BOTH;
        jPanel2.add(jScrollPane2, gridBagConstraints);

        jButton4.setText("\u7f16\u8f91\u5171\u4eab\u76ee\u5f55");
        jButton4.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                jButton4ActionPerformed(evt);
            }
        });

        jPanel4.add(jButton4);

        jButton5.setText("\u5220\u9664\u5171\u4eab\u76ee\u5f55");
        jButton5.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                jButton5ActionPerformed(evt);
            }
        });

        jPanel4.add(jButton5);

        gridBagConstraints = new java.awt.GridBagConstraints();
        gridBagConstraints.gridx = 0;
        gridBagConstraints.gridy = 3;
        gridBagConstraints.gridwidth = 2;
        gridBagConstraints.fill = java.awt.GridBagConstraints.BOTH;
        jPanel2.add(jPanel4, gridBagConstraints);

        jPanel5.setLayout(new java.awt.FlowLayout(java.awt.FlowLayout.RIGHT));

        jButton6.setText("\u786e\u5b9a");
        jButton6.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                jButton6ActionPerformed(evt);
            }
        });

        jPanel5.add(jButton6);

        jButton7.setText("\u53d6\u6d88");
        jButton7.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                jButton7ActionPerformed(evt);
            }
        });

        jPanel5.add(jButton7);

        gridBagConstraints = new java.awt.GridBagConstraints();
        gridBagConstraints.gridx = 0;
        gridBagConstraints.gridy = 4;
        gridBagConstraints.gridwidth = 2;
        gridBagConstraints.fill = java.awt.GridBagConstraints.BOTH;
        jPanel2.add(jPanel5, gridBagConstraints);

        passWord.setText("jPasswordField1");
        passWord.addFocusListener(new java.awt.event.FocusAdapter() {
            public void focusGained(java.awt.event.FocusEvent evt) {
                passWordFocusGained(evt);
            }
            public void focusLost(java.awt.event.FocusEvent evt) {
                passWordFocusLost(evt);
            }
        });

        gridBagConstraints = new java.awt.GridBagConstraints();
        gridBagConstraints.gridx = 1;
        gridBagConstraints.gridy = 1;
        gridBagConstraints.fill = java.awt.GridBagConstraints.HORIZONTAL;
        jPanel2.add(passWord, gridBagConstraints);

        getContentPane().add(jPanel2, "cardUserInfo");

        jPanel6.setLayout(new java.awt.GridBagLayout());

        jLabel3.setText("\u5171\u4eab\u540d:");
        gridBagConstraints = new java.awt.GridBagConstraints();
        gridBagConstraints.fill = java.awt.GridBagConstraints.BOTH;
        jPanel6.add(jLabel3, gridBagConstraints);

        gridBagConstraints = new java.awt.GridBagConstraints();
        gridBagConstraints.fill = java.awt.GridBagConstraints.HORIZONTAL;
        jPanel6.add(dirName, gridBagConstraints);

        jPanel7.setLayout(new java.awt.FlowLayout(java.awt.FlowLayout.RIGHT));

        jButton9.setText("\u786e\u5b9a");
        jButton9.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                jButton9ActionPerformed(evt);
            }
        });

        jPanel7.add(jButton9);

        jButton8.setText("\u53d6\u6d88");
        jButton8.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                jButton8ActionPerformed(evt);
            }
        });

        jPanel7.add(jButton8);

        gridBagConstraints = new java.awt.GridBagConstraints();
        gridBagConstraints.gridx = 0;
        gridBagConstraints.gridy = 1;
        gridBagConstraints.gridwidth = 2;
        jPanel6.add(jPanel7, gridBagConstraints);

        getContentPane().add(jPanel6, "cardShareName");

        pack();
    }// </editor-fold>//GEN-END:initComponents
    
    private void jButton5ActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_jButton5ActionPerformed
	if (mapList.getSelectionModel().isSelectionEmpty()) return;
	((MapModel)mapList.getModel()).delete(mapList.getSelectedIndex());
    }//GEN-LAST:event_jButton5ActionPerformed
    
    private void jButton2ActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_jButton2ActionPerformed
	if (userList.getSelectionModel().isSelectionEmpty()) return;
	((UserListModel)userList.getModel()).delete(userList.getSelectedIndex());
    }//GEN-LAST:event_jButton2ActionPerformed
    
    private void passWordFocusLost(java.awt.event.FocusEvent evt) {//GEN-FIRST:event_passWordFocusLost
	passWord.setText(ServerUsers.MD5(new String(passWord.getPassword())));
    }//GEN-LAST:event_passWordFocusLost
    
    private void passWordFocusGained(java.awt.event.FocusEvent evt) {//GEN-FIRST:event_passWordFocusGained
	passWord.setText("");
    }//GEN-LAST:event_passWordFocusGained
    
    private void jButton4ActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_jButton4ActionPerformed
	if (mapList.getSelectionModel().isSelectionEmpty()) return;
	dirName.setText(((MapModel)mapList.getModel()).getVirtual(mapList.getSelectedIndex()));
	((CardLayout)getContentPane().getLayout()).show(this.getContentPane(),"cardShareName");
    }//GEN-LAST:event_jButton4ActionPerformed
    
    private void jButton7ActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_jButton7ActionPerformed
	((CardLayout)getContentPane().getLayout()).show(this.getContentPane(),"cardUserList");
    }//GEN-LAST:event_jButton7ActionPerformed
    
    private void jButton6ActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_jButton6ActionPerformed
	if (userName.getText().equals("")) {
	    JOptionPane.showMessageDialog(this,"账号不能为空！");
	    return;
	}
	String str=new String(passWord.getPassword());
	if (str.equals("")) str=null;
	if (operUser==null) {
	    ServerUsers.getInst(userName.getText(),str);
	    ((UserListModel)userList.getModel()).change();
	}else {
	    operUser.setUser(userName.getText());
	    operUser.setPassMD5(str);
	    ((UserListModel)userList.getModel()).change();
	}
	((CardLayout)getContentPane().getLayout()).show(this.getContentPane(),"cardUserList");
    }//GEN-LAST:event_jButton6ActionPerformed
    
    private void jButton3ActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_jButton3ActionPerformed
	if (userList.getSelectionModel().isSelectionEmpty()) return;
	operUser=((UserListModel)userList.getModel()).getUser(userList.getSelectedIndex());
	userName.setText(operUser.getUser());
	passWord.setText(operUser.getPassMD5());
	mapList.setModel(new MapModel(operUser));
	((CardLayout)getContentPane().getLayout()).show(this.getContentPane(),"cardUserInfo");
    }//GEN-LAST:event_jButton3ActionPerformed
    
    private void jButton8ActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_jButton8ActionPerformed
	((CardLayout)getContentPane().getLayout()).show(this.getContentPane(),"cardUserInfo");
    }//GEN-LAST:event_jButton8ActionPerformed
    
    private void jButton9ActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_jButton9ActionPerformed
	if (dirName.getText().equals("")) {
	    JOptionPane.showMessageDialog(this,"共享名不能为空！");
	    return;
	}
	((MapModel)mapList.getModel()).rename(mapList.getSelectedIndex(),dirName.getText());
	((CardLayout)getContentPane().getLayout()).show(this.getContentPane(),"cardUserInfo");
    }//GEN-LAST:event_jButton9ActionPerformed
    
    private void jButton1ActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_jButton1ActionPerformed
	operUser=null;
	userName.setText("");
	passWord.setText("");
	mapList.setModel(new MapModel(null));
	((CardLayout)getContentPane().getLayout()).show(this.getContentPane(),"cardUserInfo");
    }//GEN-LAST:event_jButton1ActionPerformed
    
    /**
     * @param args the command line arguments
     */
   
    // 变量声明 - 不进行修改//GEN-BEGIN:variables
    private javax.swing.JTextField dirName;
    private javax.swing.JButton jButton1;
    private javax.swing.JButton jButton2;
    private javax.swing.JButton jButton3;
    private javax.swing.JButton jButton4;
    private javax.swing.JButton jButton5;
    private javax.swing.JButton jButton6;
    private javax.swing.JButton jButton7;
    private javax.swing.JButton jButton8;
    private javax.swing.JButton jButton9;
    private javax.swing.JLabel jLabel1;
    private javax.swing.JLabel jLabel2;
    private javax.swing.JLabel jLabel3;
    private javax.swing.JPanel jPanel1;
    private javax.swing.JPanel jPanel2;
    private javax.swing.JPanel jPanel3;
    private javax.swing.JPanel jPanel4;
    private javax.swing.JPanel jPanel5;
    private javax.swing.JPanel jPanel6;
    private javax.swing.JPanel jPanel7;
    private javax.swing.JScrollPane jScrollPane1;
    private javax.swing.JScrollPane jScrollPane2;
    private javax.swing.JList mapList;
    private javax.swing.JPasswordField passWord;
    private javax.swing.JList userList;
    private javax.swing.JTextField userName;
    // 变量声明结束//GEN-END:variables
    
    private ServerUsers operUser;
    
}
