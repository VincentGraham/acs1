package org.acs.parser;

import java.io.File;
import java.util.ArrayList;
import java.util.List;

import org.acs.journal.Global;
import org.acs.journal.Journal;

import com.ximpleware.NavException;
import com.ximpleware.VTDGen;
import com.ximpleware.VTDNav;
import com.ximpleware.XPathEvalException;
import com.ximpleware.XPathParseException;

public class NASPATHS {

	public int yearNumber(Journal Journal, int Year) {
		
		int Final = Journal.getYears() - Year;
		if (Final <= 0) {
			Final = 1;
		}		
		return Final;
	}
	
	//returns pathways of all issues from a given year and journal
	public List<String> issues(Journal Journal, int Year) {
		List<String> Final = new ArrayList<String>();
		File folder = new File(Global.PATHWAY + "/" + Journal.getCoden() + "/" + Year);
		File[] files = folder.listFiles();
		if (files != null) {
			for (File file : files) {
				if (file.getPath().contains("issue") && !file.getPath().contains("current")) {
					Final.add(Global.PATHWAY + "" + Journal.getCoden() + "/" + Year + "/" + file.getName());
					}
				}
		} 
		
		return Final;
	}
	// :(
	public String IssueArea = "";
	public String ExtraFolder = "";
	
	public List<String> TableOfContents(String Coden, int Year, int Issue) throws XPathParseException, XPathEvalException, NavException {
		List<String> XMLS = new ArrayList<String>();
		Journal Journal = new Journal();
		Journal.setCoden(Coden);
		int YearNumber = Journal.getYears() - (Journal.getCurrentYear() - Year);
		//int YearNumber = 9;
		String IssueFolder = Coden + "." + Year + "." + YearNumber + ".issue-" + Issue;
		IssueArea = Global.PATHWAY + Coden + "/" + Year + "/" + Coden + "." + Year + "." + YearNumber + ".issue-" + Issue;
		File[] TOCFolder = new File(IssueArea + "/" + IssueFolder).listFiles();
		File[] DateFolder = null;
		if (TOCFolder != null) {
			for (int i = 0; i < TOCFolder.length; i++) {
				if (TOCFolder[i].isDirectory()) {
					if ((TOCFolder[i].listFiles().length > 1)) {
						DateFolder = TOCFolder[i].listFiles();
						break;
					}
				}
			}
		} else {
			YearNumber = Journal.getOneYear(Year);
			IssueFolder = Coden + "." + Year + "." + YearNumber + ".issue-" + Issue;
			IssueArea = Global.PATHWAY + Coden + "/" + Year + "/" + Coden + "." + Year + "." + YearNumber + ".issue-" + Issue;
			TOCFolder = new File(IssueArea + "/" + IssueFolder).listFiles();
			for (int i = 0; i < TOCFolder.length; i++) {
				if (TOCFolder[i].isDirectory()) {
					if ((TOCFolder[i].listFiles().length > 1)) {
						DateFolder = TOCFolder[i].listFiles();
						break;
					}
				}
			}
		}
		for (File F : DateFolder) {
			if (F.getName().contains("toc") && F.getName().contains(".xml")) {
				VTDGen vg = new VTDGen();
				if(vg.parseFile(F.getAbsolutePath(), true)) {
					VTDNav vn = vg.getNav();
					Contents Contents = new Contents(vn);
					XMLS = Contents.getXMLS();
				}
			}
		}
		return XMLS;
	}
	
	

}
