package org.acs.parser;

import java.util.ArrayList;
import java.util.List;

import org.acs.journal.*;

import com.ximpleware.NavException;
import com.ximpleware.VTDNav;
import com.ximpleware.XPathEvalException;
import com.ximpleware.XPathParseException;

public class ACS_Meta extends Library {

	public ACS_Meta(VTDNav D) {
		super(D);
	}
	
	protected final String ACS_JOURNAL = "//document/metadata/journal-meta";
	protected final String ACS_DOCUMENT = "//document/metadata/document-meta";
	protected final String ACS_PROCESSING = "//document/metadata/processing-meta";
	
	public Metadata get() throws XPathParseException, XPathEvalException, NavException {
		Metadata Final = new Metadata();
		//Journal-meta first
		Final.setJournalId(getText(ACS_JOURNAL, 0, "/journal-id"));
		Final.setJournalTitle(getText(ACS_JOURNAL, 0, "/journal-title"));
		List<Issn> issns = new ArrayList<Issn>();
		for (int i = 1; i <= indexes(ACS_JOURNAL, 0, "/issn"); i++) { 
			String ACS_ISSN = ACS_JOURNAL + "/issn";
			Issn issn = new Issn();
			issn.setNumber(getText(ACS_ISSN, i, ""));
			issn.setType(getAttribute(ACS_ISSN, i, "", "issn-type"));
			issns.add(issn);
		}
		Final.setIssn(issns);
		Final.setAbrevTitle(getText(ACS_JOURNAL, 0, "/abbrev-journal-title"));
		Final.setCoden(getText(ACS_JOURNAL, 0, "/coden"));
		Final.setPublisher(getText(ACS_JOURNAL, 0, "/publisher/publisher-name"));
		Final.setUri(getText(ACS_JOURNAL, 0, "/journal-uri"));
		
		
		//document-meta
		Final.setDoi(getText(ACS_DOCUMENT, 0, "/doi"));
		Final.setArticleTitle(getText(ACS_DOCUMENT, 0, "/document-title"));
		Date pubDate = new Date(getText(ACS_DOCUMENT, 0, "/pub-date/day"), getText(ACS_DOCUMENT, 0, "/pub-date/month"), getText(ACS_DOCUMENT, 0, "/pub-date/year"));
		pubDate.setType("pub-date");
		Final.setPubDate(pubDate);
		Final.setVolume(getText(ACS_DOCUMENT, 0, "/volume"));
		Final.setIssue(getText(ACS_DOCUMENT, 0, "/issue"));
		Final.setFpage(getText(ACS_DOCUMENT, 0, "/fpage"));
		Final.setLpage(getText(ACS_DOCUMENT, 0, "/lpage"));
		List<Date> history = new ArrayList<Date>();
		
		for (int i = 1; i <= indexes("//document/metadata/document-meta/history/date", 0, ""); i++) {
			String ACS_DATE = ACS_DOCUMENT + "/history/date";
			Date date = new Date(getText(ACS_DATE, i, "/day"), getText(ACS_DATE, i, "/month"), getText(ACS_DATE, i, "/year"));
			if(getAtts(ACS_DATE, i, "").size() > 0) { //null check
				date.setType(getAtts(ACS_DATE, i, "").get(0));
			}
			history.add(date);                                    
		}
		
		Final.setHistory(history);
		Final.setCopyrightHolder(getText(ACS_DOCUMENT, 0, "/permissions/copyright-holder"));
		Final.setCopyrightYear(getText(ACS_DOCUMENT, 0, "/permissions/copyright-year"));
		
		//processing-meta
		Final.setDocumentType(getText(ACS_PROCESSING, 0, "/document-type-name"));
		return Final;
		
	}
	
}
