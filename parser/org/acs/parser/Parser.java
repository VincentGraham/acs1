package org.acs.parser;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.NoSuchFileException;
import java.nio.file.StandardCopyOption;
import java.sql.Connection;
import java.sql.SQLException;
import java.util.List;

import org.acs.journal.Abstract;
import org.acs.journal.Article;
import org.acs.journal.Author;
import org.acs.journal.Body;
import org.acs.journal.Citation;
import org.acs.journal.Global;
import org.acs.journal.Metadata;

import com.ximpleware.NavException;
import com.ximpleware.VTDGen;
import com.ximpleware.VTDNav;
import com.ximpleware.XPathEvalException;
import com.ximpleware.XPathParseException;

public class Parser {
	
	
	VTDGen vg = new VTDGen();

	/**
	 *  
	 * @param a vtdnav, doc
	 * @return and article from a specific vtd navigator
	 * @throws XPathParseException
	 * @throws XPathEvalException
	 * @throws NavException
	 */
	public Article ACS(VTDNav doc) throws XPathParseException, XPathEvalException, NavException {
		Article Final = new Article();
		/**********************************************************************************
		 * Metadata				
		 * Author
		 * Abstract
		 * Body
		 * Citations
		 * 
		 * 
		 * Same for JATS Format (Incomplete)
		 * 
		 * JATS is called .2% of times. Fails ~0.001% of times due to oasis:table exceptions.
		 * 
		 * 
		 ********************************************************************************************/
		ACS_Meta Ameta = new ACS_Meta(doc);
		ACS_Authors Aauth = new ACS_Authors(doc);
		ACS_Abstract Aabstracts = new ACS_Abstract(doc);
		ACS_Body Abody = new ACS_Body(doc);
		ACS_Citations Acitations = new ACS_Citations(doc); 
		
		Metadata M = Ameta.get();
		List<Author> listA = Aauth.get();
		Abstract A = Aabstracts.get();
		Body B = Abody.get();
		List<Citation> list = Acitations.get();

		Final.setAbstract(A);
		Final.setAuthors(listA);
		Final.setBody(B);
		Final.setCitations(list);
		Final.setMetadata(M);
		
//		M.Out(M);
//		System.out.println("\r\n");
//		for (Author author : listA) {
//			author.Out(author);
//		}
//		System.out.println("\r\n");
//		A.Out(A); //why does this take itself as param?
//		System.out.println("\r\n");
//		B.Out(B);
//		System.out.println("\r\n");
//		for (Citation citation : list) {
//			citation.Out(citation);
//		}
		return Final;
	}
	
	
	
	public void parse(String URL, String article, Global g) throws IOException, XPathParseException, XPathEvalException, NavException {
		SQLWriter w = new SQLWriter(); 
		Connection Connect = w.getConnection();
		try {
			Connect.setAutoCommit(false);
			String ExtraFolder = "";
			File temp = new File(URL + "/" + article);
			//finds the folder with the xml might be 20170111 or production
			if (temp.exists() && temp.isDirectory()) {
				for (int i = 0; i < temp.listFiles().length; i++) {
					if (!(temp.listFiles()[i].listFiles().length < 2)) { //non empty folder with xml and source images
						ExtraFolder = temp.listFiles()[i].getName();
						break;
					}
				}
			}
			//change to invalid path to force JATS parsing
			File file = new File(URL + "/" + article +  "/" + ExtraFolder + "/source/" + article + ".xml");
			if (file.length() != 0) {
				File to = new File(g.ACS_DTD + "/"  + article + ".xml");
				Files.copy(file.toPath(), to.toPath(), StandardCopyOption.REPLACE_EXISTING);
				String url = to.getAbsolutePath();
				if(vg.parseFile(url, true)) { //xmlns validation?, what to do if article doesnt exist?
					VTDNav vn = vg.getNav();
					w.write(ACS(vn), Connect);
					//ACS(vn);
					}
				Connect.close();
				to.delete();
			}
		} catch (NoSuchFileException e) { 
			System.out.println("JATSFORMAT");
			//not parsing it but JATS(VTDNAV) would go here
			try {
				Connect.close();
			} catch (SQLException e1) {
				e.printStackTrace();
			}
			//will put the other code later if jats is desired but atypon:xxxxxx is unbound
		} catch (SQLException e) {
			e.printStackTrace();
		}
	}
}
