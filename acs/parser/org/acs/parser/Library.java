/**
 * 
 * 
 * @author i00057
 */
package org.acs.parser;

import java.text.Normalizer;
import java.util.ArrayList;
import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import org.apache.commons.text.StringEscapeUtils;

import com.ximpleware.*; // hmmm 


public class Library {
	AutoPilot ap = new AutoPilot();
	VTDNav vn;
	
	public Library (VTDNav vn) {
	this.vn  = vn;
	ap.bind(vn);
	}
	
	
	@Deprecated //why did i write this
	final protected String BLANK = "";
	final protected String JATS_REF = "/article/back/ref-list/ref";
	final protected String ACS_REF = "/document/back/ref-list/ref";
	@Deprecated //more types than i thought
	final protected String[] SOURCE_TYPES = {"journal", "book", "web", "patent", "computer-program", "gov", "note", "report"};
	final protected Pattern TAGS = Pattern.compile("<.+?>");
	
	/**
	 * 
	 * @param string
	 * @return the string without xml tags
	 */
	public String removeTags(String string) {
	    if (string == null || string.length() == 0) {
	        return string;
	    }
	    Matcher m = TAGS.matcher(string);
	    String Final = m.replaceAll("");
	    return Final;
	}
	
	public String removeDots(String str) {
		String Final = str.replaceAll(".", "");
		return Final;
	}
	
	public String removeCommas(String Name) {

		String Final = "";
		Final = Name.replaceAll(",", "");
		return Final;
		
	}

	public   String unAccent(String string) {
		if (string == null) {
			string = "";
		}
		String normalString = Normalizer.normalize(string, Normalizer.Form.NFD);
		Pattern pattern = Pattern.compile("\\p{InCombiningDiacriticalMarks}+");
		String Final = pattern.matcher(normalString).replaceAll("");
		return Final;
		
	}
	
	/**
	 * 
	 * @param string
	 * @return string with(out?/only?) numbers
	 */
	public String getNumber(String string) {
		string = string == null ? "" : string;
		String Final = string.replaceAll("[^0-9]+", "");
		return Final;
	}
	
	/**
	 * 
	 * @param path1
	 * @param index
	 * @param path2
	 * @return Xpath from params using StringBuffer instead of concatenation
	 */
	public String makePath(String path1, int index, String path2) {
		String Final = "";
		if (index != 0) {
			 path1 = path1.contains("//") ? path1.substring(1) : path1;
			StringBuffer sb = new StringBuffer(path1);
			sb.append("[");
			sb.append(index);
			sb.append("]");
			sb.append(path2);
			Final = sb.toString();
		} if (index==0) { 
			StringBuffer sb = new StringBuffer(path1);
			sb.append(path2);
			Final = sb.toString();
		}
		return Final;
	}
	
	/**
	 * @param path1
	 * @param index
	 * @param path2
	 * @return the text of path1[index]path2 element
	 */
	public String getText(String path1, int index, String path2) throws XPathParseException, XPathEvalException, NavException {
		String Final = "";
		String path = makePath(path1, index, path2);
        ap.selectXPath(path);
        Final = ap.evalXPathToString().replaceAll("\n", " ").replaceAll("\r", " ");
        Final = Final.replaceFirst("^[^a-zA-Z0-9]+", "");
//        while((i=ap.evalXPath())!=-1) {
//        	int C = vn.getAttrCount();
//        	//Final = vn.toNormalizedString(i); //text of a single node
//        	//System.out.println(vn.toRawString(i+1));
//        	Final = StringEscapeUtils.unescapeXml(vn.toRawString(i+2*C+1));
//        }
		Final = Final.replaceAll("\u2019", "'").replaceAll("\u2013", "-").replaceAll("\u2018", "'"); 
        //Final = StringEscapeUtils.unescapeJava(Final);
        ap.resetXPath();
		return Final;
	}
	
	/**
	 * 
	 * @param path1
	 * @param index
	 * @param path2
	 * @return all attributes of a element in a list
	 * @throws NavException 
	 * @throws XPathEvalException 
	 */
	public List<String> getAtts(String path1, int index, String path2) throws XPathParseException, XPathEvalException, NavException {
		List<String> Final = new ArrayList<String>();
		String path = makePath(path1, index, path2) + "/@*";
        ap.selectXPath(path);
        int i=-1;
        while((i=ap.evalXPath())!=-1) {
        	Final.add(vn.toString(i+1));
        }
        ap.resetXPath();
        return Final;
	}
	
	/**
	 * 
	 * @param path1
	 * @param index
	 * @param path2
	 * @return how many of an element
	 */
	public int indexes(String path1, int index, String path2) throws XPathParseException, XPathEvalException, NavException {
		int Final = 0;
		String path = makePath(path1, index, path2);
		ap.selectXPath("count(" + path + ")");
		Final = (int) ap.evalXPathToNumber();
		ap.resetXPath();
		return Final;
	}

	/**
	 * 
	 * @param path1
	 * @param index
	 * @param path2
	 * @return the -@rid attribute value
	 */
	public String getRid(String path1, int index, String path2) throws XPathParseException, XPathEvalException, NavException {
		String Final = "";
		String path = makePath(path1, index, path2) + "/@rid";
        ap.selectXPath(path);
        ap.bind(vn);
        int i=-1;
        while((i=ap.evalXPath())!=-1) {
        	Final = (vn.toString(i+1));
        }
        ap.resetXPath();
		return Final;
	}
	
	/**
	 * Get an attribute by its '@name'
	 * @param path1
	 * @param index
	 * @param path2
	 * @param att
	 * @return attribute text by name
	 */
	public String getAttribute(String path1, int index, String path2, String attributeName) throws XPathParseException, XPathEvalException, NavException {
		String Final = "";
		String path = makePath(path1, index, path2) + "/@" + attributeName;
        ap.selectXPath(path);
        ap.bind(vn);
        int i=-1;
        while((i=ap.evalXPath())!=-1) {
        	Final = (vn.toString(i+1));
        }
        ap.resetXPath();
		return Final;
	}
	/**
	 * 
	 * @param path1
	 * @param index
	 * @param path2
	 * @return the '@id' attribute value
	 */
	public String getAid(String path1, int index, String path2) throws XPathEvalException, NavException, XPathParseException {
		String Final = "";
		String path = makePath(path1, index, path2) + "/@id";
		ap.selectXPath(path);
		ap.bind(vn);
		int i =-1;
        while((i=ap.evalXPath())!=-1) {
        	Final = (vn.toString(i+1));
        }
        ap.resetXPath();
        return Final;
	}

	/**
	 * misleading method name will not fix later
	 * @param path1
	 * @param index
	 * @param path2
	 * @return the '@citation-type' value
	 *
	 */
	public String getAtt(String path1, int index, String path2) throws XPathParseException, XPathEvalException, NavException  {
		String Final = "";
		String path = makePath(path1, index, path2) + "/@citation-type";
		ap.selectXPath(path);
		ap.bind(vn);
		int i =-1;
        while((i=ap.evalXPath())!=-1) {
        	Final = (vn.toString(i+1));
        }
        ap.resetXPath();
        return Final;
	}

	/**
	 * 
	 * @param path1
	 * @param index
	 * @param path2
	 * @return the text of an element with XML tags intact
	 */
	public String getXML(String path1, int index, String path2) throws XPathParseException, XPathEvalException, NavException {
		String Final = "";
		String path = makePath(path1, index, path2);
		ap.selectXPath(path);
		ap.bind(vn);
		@SuppressWarnings("unused")
		int i = -1;
		if ((i=ap.evalXPath())!=-1) {
            long l = vn.getElementFragment();
            Final = StringEscapeUtils.unescapeHtml4(vn.toRawString((int) l, (int) (l>>32)));
		}
		ap.resetXPath();
		return Final;	
	}

	/**
	 * 
	 * @param path1
	 * @param index
	 * @param path2
	 * @return the direct child node of a given element
	 * @throws XPathEvalException 
	 */
	public String getFirstChild(String path1, int index, String path2) throws XPathParseException, NavException, XPathEvalException {
		String Final = "";
		String path = makePath(path1, index, path2);
		ap.selectXPath(path + "/*[1]");
		ap.bind(vn);
		int i = -1;
		while((i=ap.evalXPath())!=-1){
			Final = vn.toString(i);
		}
		ap.resetXPath();
		return Final;
	}
	
	
	/**
	 * 
	 * @param path1
	 * @param index
	 * @param path2
	 * @param num
	 * @return the name of the nth child node of a given element
	 */
	public String getChild(String path1, int index, String path2, int n) throws XPathParseException, XPathEvalException, NavException {
		String Final = "";
		String path = makePath(path1, index, path2);
		ap.selectXPath(path + "/*["+ n + "]");
		ap.bind(vn);
		int i = -1;		while((i=ap.evalXPath())!=-1){
			Final = vn.toString(i);
		}
		ap.resetXPath();
		return Final;
	}
	
}
