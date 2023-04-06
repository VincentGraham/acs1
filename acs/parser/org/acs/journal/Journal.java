package org.acs.journal;

import java.io.File;
import java.util.Calendar;

public class Journal {
	


	private String Coden;
	private int FirstYear;
	private int CurrentYear = Calendar.getInstance().get(Calendar.YEAR);
	public void setCoden(String Coden) {
		this.Coden = Coden;
	}
	public String getCoden() {
		return Coden;
	}
	public void setFirstYear(int year) {
		FirstYear = year;
	}
	public int getFirstYear() {
		return FirstYear;
	}
	
	public int getCurrentYear() {
		return CurrentYear;
	}
	
	public int getOneYear(int x) {
		int Final = 0;
		
		//System.out.println(Global.PATHWAY);
		File folder = new File(Global.PATHWAY);
		File[] files = folder.listFiles();
		for (File file : files)  {
			//for each folder in the NAS system
			if (file.getName().equals(Coden)) {
				//System.out.println(file.getPath());
				File journal = new File(file.getPath());
				File[] years = journal.listFiles();
				//the 19** folder inside the coden. /Nas.../aamick/2011
				for (File year : years) {
					if (year.isDirectory() && year.getName().equals(String.valueOf(x))) {
						File[] issues = year.listFiles();
						String issueName = issues[0].getName();
						int dex = issueName.indexOf("issue-");
						String yearNum = issueName.substring(12, dex-1);
						Final = Integer.parseInt(yearNum);
						break;
					}
				}
			}
		}
		
		return Final;
	}
	
	
	public int getYears() {
		int Final = 0;
		
		//System.out.println(Global.PATHWAY);
		File folder = new File(Global.PATHWAY);
		File[] files = folder.listFiles();
		for (File file : files)  {
			//for each folder in the NAS system
			if (file.getName().equals(Coden)) {
				//System.out.println(file.getPath());
				File journal = new File(file.getPath());
				File[] years = journal.listFiles();
				//the 19** folder inside the coden. /Nas.../aamick/2011
				for (File year : years) {
					if (year.isDirectory() && year.getName().equals(String.valueOf(CurrentYear))) {
						File[] issues = year.listFiles();
						String issueName = issues[0].getName();
						int dex = issueName.indexOf("issue-");
						String yearNum = issueName.substring(12, dex-1);
						Final = Integer.parseInt(yearNum);
						break;
					}
				}
			}
		}
		
		return Final;
	}
	
	public static void main(String[] args) {
		Journal test = new Journal();
		test.setCoden("jacsat");
		int Final = test.getYears();
		System.out.println(Final);
		
	}

		
}
