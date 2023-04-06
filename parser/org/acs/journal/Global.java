package org.acs.journal;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.nio.file.StandardOpenOption;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.Scanner;

import org.acs.parser.Main;
/**
 * 
 * @author I00057
 * 
 *  
 *	PATHWAY is the location of all the xmls
 *	If XML file structure changes, change the NASPATHS class.
 * 	@see NASPATHS
 */
public class Global {
	public final static String PATHWAY = "/NAS/journals";
	public final static String Directory = "/iapps/users/vincent"; 
	
	//initial logs
	public final static String logPath1 = Directory + "/output";

	
	public String logPath = Directory + "/output";
	
	public String getLog() {
		return logPath;
	}
	public void setLog(String L) {
		this.logPath = L;
	}
	
	public File LOG(String Coden, int Year) throws IOException { //creates a new log file for testing
		File logFile = new File(logPath + "/output." + Coden + "." + Year + ".txt");
		logFile.createNewFile();
		return logFile;
	}
	public static String[] getCodens() {
		Scanner myScanner;
		List<String> codenList = new ArrayList<String>();
		try {
			myScanner = new Scanner(new File(Directory + "/Resources/codens.txt"));
			String line;
			while (myScanner.hasNextLine()) {
			    line = myScanner.nextLine();
			    codenList.add(line);
			}
		} catch (FileNotFoundException e) {
			e.printStackTrace();
		}
		return 	codenList.stream().toArray(String[]::new);
	}

	public static String[] CODENS = getCodens();
	
	//public  String ACS_DTD = "C:/Users/I00057/Desktop/ACS-DTD";

	public final static String dtd1 = Directory + "/ACS-DTD";
	public final static String JATS_DtTD = Directory + "/JATS-DTD";
	public final static String ACS = "/source/";
	
	public String ACS_DTD = Directory + "/ACS-DTD";
	
	
	
	public void setDtd(String Dtd) {
		this.ACS_DTD = Dtd;
	}
	
	//appends a coden to the list
	public void addCoden(String Coden) {
		if (!Arrays.asList(getCodens()).contains(Coden)) {
			Coden = "\r\n" + Coden;
			try {
				Files.write(Paths.get(Directory + "/Resources/codens.txt"), Coden.getBytes(), StandardOpenOption.APPEND);
			} catch (IOException e) {
				e.printStackTrace();
			}	
		} else {
			System.out.println(Main.ANSI_RED + "Already Exists" + Main.ANSI_RESET);
		}
	}
	
	//deletes and remakes files
	public void removeCoden(String Coden) {
		File codens = new File(Directory + "/Resources/codens.txt");
		if (Arrays.asList(getCodens()).contains(Coden)) {
			try {
				Scanner contentScan = new Scanner(codens);
				String content = contentScan.useDelimiter("\\Z").next();
				content = content.replace("\r\n" + Coden, "");
				codens.delete();
				new File(Directory + "/Resources/codens.txt").createNewFile();
				Files.write(Paths.get(Directory + "/Resources/codens.txt"), content.getBytes(), StandardOpenOption.APPEND);
				contentScan.close();
			} catch (FileNotFoundException e) {
				System.out.println("File not found");
			} catch (IOException e) {
				e.printStackTrace();
			}
		} else {
			System.out.println("Coden not found");
		}
	}	
}




