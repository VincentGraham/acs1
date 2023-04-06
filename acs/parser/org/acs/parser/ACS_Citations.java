package org.acs.parser;

import java.util.ArrayList;
import java.util.List;

import org.acs.journal.Citation;

import com.ximpleware.NavException;
import com.ximpleware.VTDNav;
import com.ximpleware.XPathEvalException;
import com.ximpleware.XPathParseException;

public class ACS_Citations extends Library {
	
	
	public ACS_Citations(VTDNav D) {
		super(D);
	}

	List<String> names(String path, int i) throws XPathParseException, XPathEvalException, NavException { 
		List<String> Final = new ArrayList<String>();
		if (getAtt(path, i, "").contains("journal")) {
			//everything but journal
			if (getText(ACS_REF, i, "/note") != null && getText(ACS_REF, i, "/note").trim().length()>1) {
				//notes are different
				//no names for notes
				Final.add("");
			}
			//for patent,book,web,program,gov,  etc
			for (int a = 1; a <= indexes(path, i, "/person-group/name"); a++) {
				StringBuffer sb = new StringBuffer(getText(path, i, "/person-group/name[" + a + "]/initials"));
				sb.append(" ");
				sb.append(getText(path, i, "/person-group/name[" + a  + "]/surname"));
				String name = removeCommas((sb.toString()));
				Final.add(name);
			}
		} else if (getAtt(path, i, "").contains("journal")) { 
			//this is a journal, no person-group
			List<String> names = new ArrayList<String>();;
			for (int a = 1; i <= indexes(path, i, "/acs-cite-author"); a++) {
				StringBuffer sb = new StringBuffer(getText(path, i, "/acs-cite-author[" + a + "]/initials"));
				sb.append(" ");
				sb.append(getText(path, i, "/acs-cite-author[" + a  + "]/surname"));
				String name = removeCommas((sb.toString()));
				names.add(name);
				Final.add(name);
			}
		} else {
			
		} 
		return Final;
	}
	


	boolean hasNote(String path, int i) throws XPathParseException, XPathEvalException, NavException {
		return getText(path, i, "/note/p") != null; 
	}
	
	Citation note(int i) throws XPathParseException, XPathEvalException, NavException {
		Citation Final = new Citation();
		Final.setType("note");
		Final.setText(removeTags(getXML(ACS_REF, i, "/note/p")));
		return Final;
	}
	
	String subNote(String path, int i) throws XPathParseException, XPathEvalException, NavException {
		String Final = "";
		Final = removeTags(getXML(path, i, "/citation/note/p"));
		return Final;
	}
	
	List<Citation> get() throws XPathParseException, NavException, XPathEvalException {
		List<Citation> FinalList = new ArrayList<Citation>();
		for (int i = 1; i <= indexes(ACS_REF, 0, ""); i++ ) {
			//check if its a note
			if (getText(ACS_REF, i, "/note") != null && getText(ACS_REF, i, "/note").trim().length()>1) {
				//its a note 
				//System.out.println("NOTE");
				FinalList.add(note(i));
			} else  {
				String titles = "/" + getFirstChild(ACS_REF, i, "");
				//String titles = "/acs-titles"; //fixed for acs-biochem ...
				//System.out.println("ASDF: " + titles);
//				for (int a = 1; a <= indexes(ACS_REF, i, titles); a++) { //maybe this exists UPDATE: it does
//					Citation Final = new Citation();
//					String ACS_TITLES = makePath(ACS_REF, i, titles); //ref[i]/acs-titles this could be different
//					Final.setType("journal");
//					Final.setTitle(getText(ACS_TITLES, a, "/article-title"));
//					Final.setSource(getText(ACS_TITLES, a, "/source"));
//					Final.setFpage(getText(ACS_TITLES, a, "/fpage")); 
//					Final.setLpage(getText(ACS_TITLES, a, "/lpage"));
//					
//					if (hasNote(ACS_TITLES, a)) {
//						Final.setSubNote(subNote(ACS_TITLES, a));
//					}
//					
//					List<String> names = new ArrayList<String>();

//					Final.setNames(names);
//					//System.out.println(getText(ACS_TITLES, a, "/acs-cite-author/initials"));
//					Final.setDoi(getText(ACS_TITLES, a, "/doi"));
//					Final.setIssue(getText(ACS_TITLES, a, "/issue"));
//					Final.setId(getAid(ACS_REF, i, ""));
//					Final.setVolume(getText(ACS_TITLES, a, "/volume"));
//					Final.setYear(getText(ACS_TITLES, a, "/year"));
//					FinalList.add(Final);
//				}
				for (int a = 1; a <= indexes(ACS_REF, i, titles); a++) { //multiple articles in a single citation.
					Citation Final = new Citation();
					String ACS_CITATION = makePath(ACS_REF, i, titles);
					if (getAtts(ACS_REF, i, "/citation").size()>0) {
						if (!getAtts(ACS_REF, i, "/citation").get(0).contains("cit")) {
							Final.setType(getAtts(ACS_REF, i, "/citation").get(0));
						} else {
							Final.setType("journal");
						}
					} else {
						Final.setType("journal");
					}
					Final.setPatentNumber(getText(ACS_CITATION, a, "/patent"));
					Final.setLocation(getText(ACS_CITATION, a, "/publisher-loc"));
					Final.setPublisher(getText(ACS_CITATION, a, "/publisher-name"));
					Final.setTitle(getText(ACS_CITATION, a, "/article-title"));
					Final.setSource(getText(ACS_CITATION, a, "/source"));
					Final.setFpage(getNumber(getText(ACS_CITATION, a, "/fpage"))); 
					Final.setLpage(getNumber(getText(ACS_CITATION, a, "/lpage")));
					if (hasNote(ACS_CITATION, a)) {
						Final.setSubNote(subNote(ACS_CITATION, a));
					}
					List<String> names = new ArrayList<String>();
					for (int d = 1; d <= indexes(ACS_CITATION, a, "/person-group"); d++) {
						for (int c = 1; c <= indexes(ACS_CITATION, a, "/person-group[" + d + "]/name"); c++) {
							String name = removeCommas(getText(ACS_CITATION, a, "/person-group[" + d + "]/name[" + c + "]/initials") + " " + getText(ACS_CITATION, a, "/person-group/name[" + c  + "]/surname"));
							names.add(unAccent(name));
						}
					}
					for (int c = 1; c <= indexes(ACS_CITATION, a, "/acs-cite-author"); c++) {
						StringBuffer sb = new StringBuffer(getText(ACS_CITATION, a, "/acs-cite-author[" + c + "]/initials"));
						sb.append(" ");
						sb.append(getText(ACS_CITATION, a, "/acs-cite-author[" + c + "]/surname"));
						names.add(unAccent(sb.toString()));
					}
					
					Final.setNames(names);
					Final.setDoi(getText(ACS_CITATION, a, "/doi"));
					Final.setIssue(getNumber(getText(ACS_CITATION, a, "/issue")));
					Final.setId(getAid(ACS_REF, i, ""));
					Final.setVolume(getNumber(getText(ACS_CITATION, a, "/volume")));
					Final.setYear(getNumber(getText(ACS_CITATION, a, "/year")));
					FinalList.add(Final);
				}
			}
		}
		return FinalList;
	}
}


