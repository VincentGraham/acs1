package org.acs.parser;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.StandardCopyOption;
import java.util.ArrayList;
import java.util.List;

import com.ximpleware.NavException;
import com.ximpleware.VTDNav;
import com.ximpleware.XPathEvalException;
import com.ximpleware.XPathParseException;

public class Contents  extends Library {
	
	public Contents(VTDNav doc) {
		super(doc);
	}

	String url = "";

	
	
	/**
	 * 
	 * @return all XMLS in a certain issue
	 * @throws XPathParseException
	 * @throws XPathEvalException
	 * @throws NavException
	 * @return list of xml file names
	 */
	public List<String> getXMLS() throws XPathParseException, XPathEvalException, NavException {
		List<String> xmls = new ArrayList<String>();
		//System.out.println(indexes("//toc-xml/toc/issue-subject-group", 2, "/issue-article-meta/aritcle-id"));
		for (int i = 1; i <= indexes("/toc-xml/toc/issue-subject-group", 0, ""); i++) {
			for (int a = 1; a<=indexes("/toc-xml/toc/issue-subject-group", i, "/issue-article-meta/article-id"); a++) {
				//removes '10.1021/'
				xmls.add(getText("//toc-xml/toc/issue-subject-group", i, "/issue-article-meta/article-id[" + a + "]").substring(8));
			}
		} 
		for (int i = 1; i <= indexes("/toc-xml/toc/issue-article-meta", 0, ""); i++) {
			for (int a = 1; a<=indexes("/toc-xml/toc/issue-article-meta", i, "/article-id"); a++) {
				xmls.add(getText("//toc-xml/toc/issue-article-meta", i, "/article-id[" + a + "]").substring(8));
			}
		}
		return xmls;
	}
	
	public void copyFile(File from, File to) throws IOException {
		Files.copy(from.toPath(), to.toPath(), StandardCopyOption.REPLACE_EXISTING);
	}
	
}
