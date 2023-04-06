package org.acs.parser;

import java.awt.BorderLayout;
import java.awt.Color;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.util.Random;

import javax.swing.BorderFactory;
import javax.swing.JButton;
import javax.swing.JComboBox;
import javax.swing.JFrame;
import javax.swing.JLabel;
import javax.swing.JPanel;
import javax.swing.JTextField;
import javax.swing.WindowConstants;

import org.acs.journal.Global;
import org.acs.journal.Input;

public class GUI {
	public static String Coden = "";
	public static int Year = 0;
	public static int Issue = 0;
	boolean no = false;
	public void Load() {
		boolean B = no;
		JFrame frame = new JFrame("Loading...");
		frame.setSize(400,400);
		frame.setDefaultCloseOperation(WindowConstants.EXIT_ON_CLOSE);
		frame.setVisible(true);
		Random random = new Random();
		while (B) {
			float hue = random.nextFloat();
			// Saturation between 0.1 and 0.3
			float saturation = (random.nextInt(2000) + 1000) / 10000f;
			float luminance = 0.9f;
			 Color color = Color.getHSBColor(hue, saturation, luminance);
			JPanel panel = new JPanel();
			panel.setSize(1800,1800);
			panel.setOpaque(true);
			panel.setBackground(color);
			panel.setVisible(true);
			frame.add(panel);
			frame.revalidate();
			frame.repaint();
		}
		
	}
	
	
	
	public Input main() {
		Input input = new Input();
		JFrame frame = new JFrame("TEST");
		frame.setDefaultCloseOperation(WindowConstants.EXIT_ON_CLOSE);
		int X = 1200;
		int Y = 200;
		frame.setSize(X, Y);
		JPanel panel = new JPanel();
		panel.setLayout(new BorderLayout(5, 5));
		panel.setVisible(true);
		JLabel label = new JLabel("CODEN: ");
		label.setVisible(true);
		String[] choices = Global.CODENS;
		final JComboBox<String> box = new JComboBox<String>(choices);	
		box.setVisible(true);
		JTextField InYear = new JTextField(40);
		InYear.setBorder(BorderFactory.createLineBorder(Color.black));
		JTextField InIssue = new JTextField(40);
		InIssue.setBorder(BorderFactory.createLineBorder(Color.red));
		JButton btn = new JButton("Year, Coden, Issue");
		panel.add(box, BorderLayout.CENTER);
		panel.add(InIssue, BorderLayout.EAST);
		panel.add(InYear, BorderLayout.WEST);
		panel.add(btn, BorderLayout.PAGE_END);
		btn.addActionListener(new ActionListener() {
			public void actionPerformed(ActionEvent e1) {
				Year = Integer.parseInt(InYear.getText());
				Issue = Integer.parseInt(InIssue.getText());
		        Coden = box.getSelectedItem().toString();
		        input.setInput(true);
		        input.setYear(Year);
		        input.setIssue(Issue);
		        input.setCoden(Coden);
				//System.out.println(Year + " " + Issue + " " + Coden);
		        frame.setVisible(false);
			}
		});
		InYear.setVisible(true);
		InIssue.setVisible(true);
		frame.add(panel);
		frame.setVisible(true);
		return input;
	}
	
	public static void main(String[] args) throws InterruptedException {

		GUI g = new GUI();
		g.main();
		
	}
	
}
