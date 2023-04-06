package org.acs.parser;


import java.io.IOException;
import java.util.Arrays;
import java.util.Scanner;

import org.acs.journal.Global;

public class Prompt {
	Scanner in = new Scanner(System.in);
	String[] options = {"delete", "setdtd", "setlog", "+coden", "-coden", "codens", "help"};
	public void CloseStream() {
		this.in.close();
	}
	
	/**
	 * 
	 * @return args for Main.run() from console input
	 */
	public String[] input() {
		String[] result = new String[4];
		System.out.println(Main.ANSI_BLUE + "Enter -1 for all years or issues."  + Main.ANSI_RESET);
		while(true) {
			System.out.println("Coden: ");
			result[0] = in.nextLine();
			if(Arrays.asList(Global.CODENS).contains(result[0]) || Arrays.asList(options).contains(result[0])) {
				result[3] = "y";
				break;
			}
			Main.clear(System.out);
			System.out.println("Enter a 6 letter Coden");
		}
		if (!Arrays.asList(options).contains(result[0])) {
			while(true) {
				System.out.println("Year: ");
				result[1] = in.nextLine();
				if(result[1].length() == 4 || result[1].contains("-1")) {
					result[2] = "-1"; //parse all issues
					break; //no need for else stmnt
				}
				Main.clear(System.out);
				System.out.println("Enter a more valid year");
				
			}
			if (!result[1].contains("-1")) {
				while(true) {
					System.out.println("Issue: ");
					result[2] = in.nextLine();
					if(result[2].length() >= 1) {
						System.out.println(result[2].length());
						break;
					}
					Main.clear(System.out);
					System.out.println("Enter a more valid issue");
				}
			}
		} else if (result[0].contains("delete")) {
			System.out.println(Main.ANSI_RED + "Are you sure?" + Main.ANSI_RESET);
			if (in.nextLine().toLowerCase().contains("y")) {
				return result;
			} else {
				result[0] = "reset";
			}
		} else if (result[0].contains("setdtd")) {
			System.out.println(Main.ANSI_RED + "DTD Location Defaults to: " + Global.dtd1 + Main.ANSI_RESET);
			System.out.println(Main.ANSI_RED + "Enter new DTD folder path" + Main.ANSI_RESET);
			result[1] = in.nextLine();

		} else if (result[0].contains("setlog")) {
			System.out.println(Main.ANSI_RED + "Log Location Defaults to: " + Global.logPath1 + Main.ANSI_RESET);
			System.out.println(Main.ANSI_RED + "Enter new Log folder path" + Main.ANSI_RESET);
			result[1] = in.nextLine();

		} else if (result[0].contains("+coden")) {
			System.out.println(Main.ANSI_RED + "Enter Coden to Add" + Main.ANSI_RESET);
			result[1] = in.nextLine();

		} else if (result[0].contains("-coden")) {
			System.out.println(Main.ANSI_RED + "Enter Coden to Remove" + Main.ANSI_RESET);
			result[1] = in.nextLine();
		
		} else if (result[0].contains("codens")) {
			//do nothing
			//wait for return at bottom
		} else {
			String outputText = "";
			for (String s : Arrays.asList(options)) {
				outputText += (", " + s);
			}
			String text = (Main.ANSI_PURPLE + "Options are: CODEN" + outputText + Main.ANSI_RESET);
			result[0] = "reset";
			result[1] = text;
		}
		
		
		return result;
	}
	
	public static void main(String[] args) throws IOException, InterruptedException {
		Prompt p = new Prompt();
		p.input();
		System.out.println("test");
	}
}
