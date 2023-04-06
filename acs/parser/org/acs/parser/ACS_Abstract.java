package org.acs.parser;

import org.acs.journal.Abstract;
import com.ximpleware.NavException;
import com.ximpleware.VTDNav;
import com.ximpleware.XPathEvalException;
import com.ximpleware.XPathParseException;

public class ACS_Abstract extends Library{
	
	public ACS_Abstract(VTDNav D) {
		super(D);
	}

	Abstract get() throws XPathParseException, XPathEvalException, NavException {
		Abstract Final = new Abstract(); 
		
		Final.setText(removeTags(getXML("//document/metadata/document-meta/abstract-group/abstract", 0, "")));
		
		return Final;
	}
}
