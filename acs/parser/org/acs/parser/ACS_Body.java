package org.acs.parser;

import java.util.ArrayList;
import java.util.List;

import org.acs.journal.Body;

import com.ximpleware.NavException;
import com.ximpleware.VTDNav;
import com.ximpleware.XPathEvalException;
import com.ximpleware.XPathParseException;

public class ACS_Body extends Library {
	
	public ACS_Body(VTDNav D) {
		super(D);
	}

	Body get() throws XPathParseException, XPathEvalException, NavException {
		
		List<String> Caps = new ArrayList<String>();
		List<String> Tags = new ArrayList<String>();
		
		
		Body Final = new Body();
		StringBuffer P = new StringBuffer(); //paragraphs for sectionless articles
		for (int i = 1; i <= indexes("/document/body/p", 0, ""); i++) {
			P.append(unAccent(removeTags(getXML("//document/body/p", i, ""))).replaceAll("\r", " ").replaceAll("\n", " "));
			P.append("\r\n");
		}
		//captions and figure types:
		//figs
		for (int i = 1; i <= indexes("/document/body/fig", 0, ""); i++) {
			Caps.add(unAccent(removeTags(getXML("//document/body/fig[" + i + "]/caption/p", 0, ""))).replaceAll("\r", " ").replaceAll("\n", " "));
			Tags.add("fig");
		}
		//tables
		for (int i = 1; i <= indexes("/document/body/table-wrap", 0, ""); i++) {
			Caps.add(unAccent(removeTags(getXML("//document/body/table-wrap[" + i + "]/caption", 0, ""))).replaceAll("\r", " ").replaceAll("\n", " "));
			Tags.add("table");
		}
		//schemes
		for (int i = 1; i <= indexes("/document/body/scheme", 0, ""); i++) {
			Caps.add(unAccent(removeTags(getXML("//document/body/scheme[" + i + "]/caption", 0, ""))).replaceAll("\r", " ").replaceAll("\n", " "));
			Tags.add("scheme");
		}
		
		
		//find sec; S buffer for body 
		StringBuffer S = new StringBuffer();
		//i is parent section, x is first child sec, y is second child sec
		for (int i = 1; i <= indexes("/document/body/sec", 0, ""); i++) {
			String Section = "/document/body/sec";
			String Section2 = "//document/body/sec[" + i + "]/sec";
			S.append(getText("//document/body/sec", i, "/head") + ": ");
			for (int a = 1; a <= indexes(Section, i, "/p"); a++) {
				S.append(unAccent(removeTags(getXML(Section, i, "/p[" + a + "]"))).replaceAll("\r", " ").replaceAll("\n", " "));
				S.append("\r\n");
			}
			for (int x = 1; x <= indexes("/document/body/sec", i, "/sec"); x++) {
				S.append(getText(Section2, x, "/head") + ": ");
				for (int a = 1; a <= indexes(Section2, x, "/p"); a++) {
					S.append(unAccent(removeTags(getXML(Section2, x, "/p[" + a + "]"))).replaceAll("\r", " ").replaceAll("\n", " "));
					S.append("\r\n");
				}
				String Section3 = Section2 + "[" + x  + "]/sec"; //couldve used makePath() ._.
				for (int y = 1; y <= indexes(Section2, x, "/sec"); y++) {
					S.append(getText(Section3, y, "/head"));
					for (int a = 1; a <= indexes(Section3 , y, "/p"); a++) {
						S.append(unAccent(removeTags(getXML(Section3, y, "/p[" + a + "]"))).replaceAll("\r", " ").replaceAll("\n", " "));
						S.append("\r\n");
					}
				}
			}
				
			//figs and stuff:
			//figs
			for (int a = 1; a <= indexes(Section, i, "/fig"); a++) {
				Caps.add(unAccent(removeTags(getXML("/document/body/sec", i, "/fig[" + a + "]/caption/p"))).replaceAll("\r", " ").replaceAll("\n", " "));
				Tags.add("fig");
			}
			//tables
			for (int a = 1; a <= indexes(Section, i, "/table-wrap"); a++) {
				Caps.add(unAccent(removeTags(getXML("/document/body/sec", i, "/table-wrap[" + a + "]/caption"))).replaceAll("\r", " ").replaceAll("\n", " "));
				Tags.add("table");
			}
			//schemes
			for (int a = 1; a <= indexes(Section, i, "/scheme"); a++) {
				Caps.add(unAccent(removeTags(getXML("/document/body/sec", i, "/scheme[" + a + "]/caption"))).replaceAll("\r", " ").replaceAll("\n", " "));
				Tags.add("scheme");
			}
			
			
			
			//nested sections fix:
			for (int x = 1; x <= indexes("/document/body/sec", i, "/sec"); x++) {
				for (int a = 1; a <= indexes(Section2, x, "/fig"); a++) {
					Caps.add(unAccent(removeTags(getXML(Section2, x, "/fig[" + a + "]/caption/p"))).replaceAll("\r", " ").replaceAll("\n", " "));
					Tags.add("fig");
				}
			}
			//nested tables:
			for (int x = 1; x <= indexes("/document/body/sec", i, "/sec"); x++) {
				for (int a = 1; a <= indexes(Section2, x, "/table-wrap"); a++) {
					Caps.add(unAccent(removeTags(getXML(Section2, x, "/table-wrap[" + a + "]/caption"))).replaceAll("\r", " ").replaceAll("\n", " "));
					Tags.add("table");
				}
			}
			//nested schemes
			for (int x = 1; x <= indexes("/document/body/sec", i, "/sec"); x++) {
				for (int a = 1; a <= indexes(Section2, x, "/scheme"); a++) {
					Caps.add(unAccent(removeTags(getXML(Section2, x, "/scheme[" + a + "]/caption"))).replaceAll("\r", " ").replaceAll("\n", " "));
					Tags.add("scheme");
				}
			}
		}
			Final.setText(P.toString() + S.toString()); //1 of these blank
			Final.setCaptions(Caps); //index of caption and tags are the same.
			Final.setTags(Tags); 
		return Final;
	}
	
}
