package org.acs.parser;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.PrintStream;
import java.text.DecimalFormat;
import java.util.List;


import org.acs.journal.Global;
import org.acs.journal.Journal;

import com.ximpleware.NavException;
import com.ximpleware.XPathEvalException;
import com.ximpleware.XPathParseException;

/**
 * 
 * this can be multithreaded (see Test.java) but might run out of connections to database
 * @author I00057
 *
 */
public class Main extends Thread {
	
	public Main() {
	}
	public Main(PrintStream ps) {
		this.log = ps;
	}
	public Main(String[] args) {
		this.args = args;
	}
	public Main(PrintStream ps, String[] args) {
		this.args = args;
		this.log = ps;
	}
	
	private String[] args;
	private PrintStream log = System.out;
	public final static String ANSI_RESET = "\u001B[0m";
	public final static String ANSI_BLACK = "\u001B[30m";
	public final static String ANSI_RED = "\u001B[31m";
	public final static String ANSI_GREEN = "\u001B[32m";
	public final static String ANSI_YELLOW = "\u001B[33m";
	public final static String ANSI_BLUE = "\u001B[34m";
	public final static String ANSI_PURPLE = "\u001B[35m";
	public final static String ANSI_CYAN = "\u001B[36m";
	public final static String ANSI_WHITE = "\u001B[37m";
	public final static String[] COLORS = {ANSI_RED, ANSI_GREEN, ANSI_YELLOW, ANSI_BLUE, ANSI_PURPLE, ANSI_CYAN, ANSI_WHITE};

	/**
	 * 
	 * @param PrintStream ps.
	 * @return Void. 
	 *  Resets a printstream CLI removes color and makes text go to top.
	 */
	public static void clear(PrintStream ps) {
	    ps.println(ANSI_RESET);
	    ps.print("\033[H\033[2J");
	    ps.flush();  
	}
	
	public String t(long L) {
		DecimalFormat df = new DecimalFormat("#.00");
		String Time = df.format((System.currentTimeMillis()-L)/1000.0);
		String Result = ANSI_CYAN + "Time Elapsed: " + Time + " Seconds" + ANSI_RESET;
		return Result;
	}
	
	public String Time(long L) {
		
		DecimalFormat df = new DecimalFormat("#.00");
		String Time = df.format((System.currentTimeMillis()-L)/1000.0);
		String Result = " | " + ANSI_CYAN + Time + " Seconds" + ANSI_RESET;
		return Result;
	}
	
	//same as main but only counts total articles.
	@SuppressWarnings("unused")
	public int Count(String[] args) throws XPathParseException, XPathEvalException, NavException {
		int Final = 0;
		Prompt prompt = new Prompt();
		NASPATHS nas = new NASPATHS();
		Main t = new Main(System.out, args);
		
		String encoding = "UTF-8"; //change later? Log File encoding
		
		
		String Coden = "aamick";  //initial args
		int Year = 2017;
		int Issue = 1;
		int Year2 = 0;
		int LoopCheck = 0;
		long newStartTime = 0;
		
		
		if (args.length == 1) {
			Coden = args[0];
			Year = 2017; //current year
			Issue = -1; //all issues
		} else if (args.length == 2) {
			Coden = args[0];
			Year = Integer.parseInt(args[1]);
			Issue = -1; //all issues
		} else if (args.length == 3 || args.length == 4) { 
			Coden = args[0];
			Year = Integer.parseInt(args[1]);
			Issue = Integer.parseInt(args[2]);
		}
		
		Journal Journal = new Journal();
		Journal.setCoden(Coden);

		if (Year == -1) {
			Year = Journal.getCurrentYear()-Journal.getYears() + 1;
			Year2 = Journal.getCurrentYear();
		} if (Year2 != 0) {
			for (int i = Year; i <= Year2; i++) {
				List<String> issues = nas.issues(Journal, i);
				for (String issue : issues) { //not in order fix this?
					int sub = issue.indexOf("issue-");
					int IN = Integer.parseInt(issue.substring(sub+6));
					for (String DOI : nas.TableOfContents(Coden, i, IN)) {
						Final++;
					}
				}
			}
		} else if (Issue == -1) {
			List<String> issues = nas.issues(Journal, Year);
			for (String issue : issues) {
				int sub = issue.indexOf("issue-");
				int IN = Integer.parseInt(issue.substring(sub+6));
				for (String DOI : nas.TableOfContents(Coden, Year, IN)) {
					Final++;
				}
			}
		} else {
			for (String DOI : nas.TableOfContents(Coden, Year, Issue)) {
				Final++;
			}
		}
		return Final;
	}
	
	public String toString(Long L, int I, int Y, String C , String D, int Total, int Current) {
		
		DecimalFormat df = new DecimalFormat("#.00");
		String percent = df.format(((double) Current/Total)*100.0);
		String roundOff = percent + "%";
		String doi = D;
		StringBuffer sb = new StringBuffer();
		sb.append(ANSI_GREEN);
		sb.append(C);
		sb.append(ANSI_RESET);
		sb.append(" | ");
		sb.append(ANSI_GREEN);
		sb.append(Y);
		sb.append(ANSI_RESET);
		sb.append(" | ");
		sb.append(ANSI_GREEN);
		sb.append(I);
		sb.append(ANSI_RESET);
		if (I <10) {
			sb.append("  | "); 
		} else {
			sb.append(" | ");
		}
		sb.append(ANSI_GREEN);
		sb.append(doi);
		sb.append(ANSI_RESET);
		sb.append(" | ");
		sb.append(t(L));
		sb.append(ANSI_RESET);
		sb.append(" | ");
		sb.append(ANSI_RED);
		sb.append(roundOff);
		sb.append(ANSI_RESET);
		return sb.toString();
	}
	
	public static void main(String[] args) throws XPathParseException, XPathEvalException, NavException, IOException, InterruptedException {
		PrintStream init = System.out;
		int dex = 15; 
		String[] newCodens = new String[Global.CODENS.length-dex];
		if (args.length != 0) {
			//starting on acscii
			for (int i = dex; i < Global.CODENS.length; i++) {
				newCodens[i-dex] = Global.CODENS[i];
			}
			for	(String string : newCodens) {
				for (int i = 2009; i <= 2017; i++) {
					String[] arg = {string, i+"", "-1"};
					Main M = new Main(init, arg);
					M.run(); 
				}
			}
		} else {
			args = null;
			Main M = new Main(init, args);
			M.run();
		}
	}
	
	//does this make a new thread each time? hope not
	public void run() {
		//keeping track of time/uses the class args
		String[] args = this.args;
		long startTime = System.currentTimeMillis();

		
		String options = "delete, setdtd, setlog, +coden, -coden, codens, reset"; //this is not a list
		Global Global = new Global();
		Prompt prompt = new Prompt();
		NASPATHS nas = new NASPATHS();
		Main t = new Main(System.out, args);
		
		String encoding = "UTF-8"; //change later? Log File encoding also doesn't seem to work.
		clear(log);
		
		// //unused on server
		//GUI gui = new GUI();
		//Input in = gui.main();
		
		String Coden = "aamick"; // default a coden for testing (aamick is first alphabetically)
		int Year = 2017;
		int Issue = 1;
		int Year2 = 0;
		int LoopCheck = 0;
		long newStartTime = 0;
		int CurrentValue = 0;
		

		if (args == null || args.length == 0) {
			 args = prompt.input();
		}
		
		clear(log);
		
		//cleanup files
		while (options.contains(args[0])) {
			if (args[0].contains("delete")) {
				log.print(ANSI_RED + "Deleting all Rows and Log files"  + ANSI_RESET);
				File[] logs = new File(org.acs.journal.Global.Directory + "/output").listFiles();
				for (File f : logs) {
					f.delete();
				}
				SQLWriter w = new SQLWriter();
				w.Clear(); //??
				clear(log); //clears console
				args = prompt.input();
			}
			//new dtd folder
			if (args[0].contains("setdtd")) {
				log.print(ANSI_RED  + "Setting DTD Location To: " + args[1] + ANSI_RESET);
				Global.setDtd(args[1]);
				clear(log);
				args = prompt.input();
			}
			//new log folder, must be directory
			if (args[0].contains("setlog")) {
				log.print(ANSI_RED  + "Setting Log Folder To: " + args[1] + ANSI_RESET);
				Global.setLog(args[1]);
				clear(log);
				args = prompt.input();
			}
			if (args[0].contains("+coden")) {
				StringBuffer C = new StringBuffer();
				log.println(ANSI_GREEN + "Adding Coden: " + args[1] + ANSI_RESET);
				Global.addCoden(args[1]);
				for (int i = 0; i < org.acs.journal.Global.getCodens().length; i++) {
					if (i%5!=0) {
						C.append(org.acs.journal.Global.getCodens()[i] + " ");
					} else {
						C.append("\r\n" +org.acs.journal.Global.getCodens()[i] + " ");
					}
				}
				log.println(C.toString());
				args = prompt.input();
			}
			if (args[0].contains("-coden")) {
				log.println(ANSI_GREEN + "Removing Coden: " + args[1] + "..." + ANSI_RESET);
				Global.removeCoden(args[1]);
				args = prompt.input();
			}
			if (args[0].contains("codens")) {
				StringBuffer Sb = new StringBuffer();
				log.println(Main.ANSI_CYAN + "Displaying Codens..." + Main.ANSI_RESET);
				for (int i = 0; i < org.acs.journal.Global.getCodens().length; i++) {
					if (i%5!=0) {
						Sb.append(org.acs.journal.Global.getCodens()[i] + " ");
					} else {
						Sb.append("\r\n" +org.acs.journal.Global.getCodens()[i] + " ");
					}
				}
				log.println(Sb.toString());
				args = prompt.input();
			}
			if (args[0].contains("reset")) {
				if (args[1] != null)
					log.println(args[1]);
				args = prompt.input();
			}
		}
		prompt.CloseStream();
		
		//look at args
		if (args.length == 1) {
			Coden = args[0];
			Year = 2017; //current year
			Issue = -1; //all issues
		} else if (args.length == 2) {
			Coden = args[0];
			Year = Integer.parseInt(args[1]);
			Issue = -1; //all issues
		} else if (args.length == 3 || args.length == 4) {
			Coden = args[0];
			Year = Integer.parseInt(args[1]);
			Issue = Integer.parseInt(args[2]);
		} 
		System.out.println(args.length + args[0] + args[1]+ args[2]);
		//set the global args again
		this.args = args;
		clear(log);
		
		int Total = 0;
		try {
			Total = t.Count(args);
			log.println(ANSI_GREEN + "Total: " + Total + ANSI_RESET);
			log.println(ANSI_GREEN + "Time Estimate: " + Total*2.8/60 + ANSI_RESET);
	//		for gui
	//		while(in.getInput() == false) {
	//			Thread.sleep(1000);
	//		}
	//		
			Journal Journal = new Journal();
			Parser parser = new Parser();
	//		Coden = in.getCoden();
	//		Year = in.getYear();
	//		Issue = in.getIssue();
			Journal.setCoden(Coden);
			System.out.println(ANSI_BLUE + Coden + " "+ Year + " "+Issue +ANSI_RESET + "\r\n\r\n");
			log.println(ANSI_GREEN + "Connecting..." + ANSI_RESET);
			//every year of a journal
			if (Year == -1) {
				Year = Journal.getCurrentYear()-Journal.getYears() + 1; 
				Year2 = Journal.getCurrentYear();
			} if (Year2 != 0) {
				for (int i = Year; i <= Year2; i++) {
	
					FileOutputStream fos = new FileOutputStream(Global.LOG(Coden, i));
					PrintStream printStream = new PrintStream(fos, false, encoding);
					System.setOut(printStream);
					List<String> issues = nas.issues(Journal, i);
					System.out.println(issues);
					for (String issue : issues) { //not in order fix this?
						int sub = issue.indexOf("issue-");
						int IN = Integer.parseInt(issue.substring(sub+6));
						for (String DOI : nas.TableOfContents(Coden, i, IN)) {
							System.out.println("@@@@@@@@@@@@@@@@@" + DOI + "@@@@@@@@@@@@@@@@@");
							parser.parse(nas.IssueArea, DOI, Global); //calls parse
							if (LoopCheck == 0) {
								log.println(ANSI_GREEN + "Connected in " + ANSI_RESET + t.Time(startTime));
								newStartTime = System.currentTimeMillis();
								LoopCheck = 5;
							}
							System.out.println("\r\n\r\n\r\n\r\n");
							log.println(t.toString(newStartTime, IN, i, Coden, DOI, Total, CurrentValue));
							CurrentValue++;
						}
					}
				}
			} else if (Issue == -1) {
				FileOutputStream fos = new FileOutputStream(Global.LOG(Coden, Year));
				PrintStream printStream = new PrintStream(fos, false, encoding);
				System.setOut(printStream);
				List<String> issues = nas.issues(Journal, Year);
				System.out.println(issues);
				for (String issue : issues) {
					int sub = issue.indexOf("issue-");
					int IN = Integer.parseInt(issue.substring(sub+6));
					for (String DOI : nas.TableOfContents(Coden, Year, IN)) {
						System.out.println("@@@@@@@@@@@@@@@@@" + DOI + "@@@@@@@@@@@@@@@@@");
						parser.parse(nas.IssueArea, DOI, Global);
						if (LoopCheck == 0) {
							log.println(ANSI_GREEN + "Connected in " + ANSI_RESET + t.Time(startTime));
							newStartTime = System.currentTimeMillis();
							LoopCheck = 5;
						}
						System.out.println("\r\n\r\n\r\n\r\n");
						log.println(t.toString(newStartTime, IN, Year, Coden, DOI, Total, CurrentValue));
						CurrentValue++;
					}
				}
			} else {
				FileOutputStream fos = new FileOutputStream(Global.LOG(Coden, Year));
				PrintStream printStream = new PrintStream(fos, false, encoding);
				System.setOut(printStream);
				for (String DOI : nas.TableOfContents(Coden, Year, Issue)) {
					System.out.println("@@@@@@@@@@@@@@@@@" + DOI + "@@@@@@@@@@@@@@@@@");
					parser.parse(nas.IssueArea, DOI, Global);
					if (LoopCheck == 0) {
						log.println(ANSI_GREEN + "Connected in " + ANSI_RESET + t.Time(startTime));
						newStartTime = System.currentTimeMillis();
						LoopCheck = 5;
					}
					System.out.println("\r\n\r\n\r\n\r\n");
					log.println(t.toString(newStartTime, Issue, Year, Coden, DOI, Total, CurrentValue));
					CurrentValue++;
				}
			}
		} catch (XPathParseException | XPathEvalException | NavException | IOException e) {
			e.printStackTrace();
		}
		long endTime   = System.currentTimeMillis();
		long totalTime = endTime - startTime;
		log.println("Time: " + totalTime/1000.0/60.0 + " Minutes");
		//gui.no = false;
		//JOptionPane.showMessageDialog(null, "Done, " + totalTime/1000/60 + " Minutes");
		//return Final;
	}
}
