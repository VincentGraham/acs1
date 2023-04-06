package org.acs.parser;

import java.io.PrintStream;
import java.util.List;

import org.acs.journal.Journal;

/**
 * 
 * @author I00057
 *
 */
public class Test extends Thread {
	
	//testing mains:
	//multithreading try
	//works ok with aamick
	
	static PrintStream PS = System.out;
	
	public static void main(String[] args) {
		int x = 1;
		int y = 10;
		System.out.println((double) x/y); // ? forgot to remove?
	}
	
	public static void Tmain(String[] args) {
		double i = 1;
		int c = 0;
		while(i!=0) {
			i = i/2;
			System.out.print(" " + i);
			c++;
		}
		System.out.println("end i is" + i + ", number of tries: " + c);
		
	}
	public static void tmain(String[] args) {
		NASPATHS nas = new NASPATHS();
		Journal Journal = new Journal();
		Journal.setCoden("aamick"); //testing with aamick
		for (int i = 2009; i < 2017; i++) {
			List<String> issues = nas.issues(Journal, i);
			for (String issue : issues) {
				int sub = issue.indexOf("issue-");
				int IN = Integer.parseInt(issue.substring(sub+6));
				String[] param = {"aamick", i+"", IN+""};
				Main M = new Main(PS, param);
				M.start();
			}
		}
	}
}