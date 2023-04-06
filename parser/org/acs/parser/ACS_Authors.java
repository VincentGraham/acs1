package org.acs.parser;

import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

import org.acs.journal.Affiliation;
import org.acs.journal.Author;

import com.ximpleware.NavException;
import com.ximpleware.VTDNav;
import com.ximpleware.XPathEvalException;
import com.ximpleware.XPathParseException;


public class ACS_Authors extends Library{

	public ACS_Authors(VTDNav D) {
		super(D);
	}
	
	
	boolean isId(List<String> ids, String id) {
		//returns false if it already in the list
		boolean Final = false;
		for (String a : ids) {
			if (a.contains(id)) {
				Final = true;
				break;
			}
		}
		return Final;
	}
	protected final String ACS_CONTRIBG = "//document/metadata/document-meta/contrib-group";
	protected final String ACS_COR = "//document/metadata/document-meta/author-notes/corresp";

	public List<Author> contrib() throws XPathParseException, XPathEvalException, NavException { 
		List<Author> authors = new ArrayList<Author>();
		for (int b = 1; b <= indexes(ACS_CONTRIBG, 0, ""); b++) { 
			String ACS_CONTRIB = makePath(ACS_CONTRIBG, b, "/contrib");
			String ACS_AFF = makePath(ACS_CONTRIBG, b, "/aff");
			for (int i = 1; i<= indexes(ACS_CONTRIB, 0, ""); i++) {
				Author author = new Author();
				String name = unAccent(getText(ACS_CONTRIB, i, "/name/given-names") + " " + getText(ACS_CONTRIB, i, "/name/surname"));
				author.setName(name);
				author.setRole(getText(ACS_CONTRIB, i, "/role"));
				author.setOrcid(getText(ACS_CONTRIB, i, "/contrib-id"));
				List<String> ids = new ArrayList<String>();
				
				for (int a = 1; a <= indexes(ACS_CONTRIB, i, "/xref"); a++) {
					String id = getRid(ACS_CONTRIB, i, "/xref[" + a + "]");
					if(!id.contains("note")) {
						ids.add(id);
					}
				}
				if (indexes(ACS_AFF, 0, "") == 1) {
					ids.add("aff" + b);
				} 
				Set<String> hs = new HashSet<>(); //clear duplicates
				hs.addAll(ids);
				ids.clear();
				ids.addAll(hs);
				author.setIds(ids); //no longer using XREF object in author
				authors.add(author);
			}
		}
		return authors;
	}

	public List<Affiliation> affiliations() throws XPathParseException, XPathEvalException, NavException { 
		List<Affiliation> Final = new ArrayList<Affiliation>();
		for (int b = 1; b <= indexes(ACS_CONTRIBG, 0, ""); b++) { 
			String ACS_AFF = makePath(ACS_CONTRIBG, b, "/aff");
			for (int i = 1; i <= indexes(ACS_AFF , 0, ""); i++) {
				Affiliation Aff = new Affiliation();
				Aff.setId(getAid(ACS_AFF, i, ""));
				if (Aff.getId().trim().isEmpty()) {
					Aff.setId("aff1");
				}
				Aff.setDepartment(getText(ACS_AFF, i, ""));
				Aff.setInstitution(getText(ACS_AFF, i, "/institution"));
				Aff.setCountry(getText(ACS_AFF, i, "/country"));
				List<String> Tags = new ArrayList<String>();
				for (int a = 1; a <= indexes(ACS_AFF, i, "/sup"); a++) {
					String ACS_SUP = makePath(ACS_AFF, i, "/sup[" + a + "]");
					Tags.add(getText(ACS_SUP, 0, ""));
				}
				Aff.setLabel(getText(ACS_AFF, i, "/label"));
				Aff.setTags(Tags);
				Final.add(Aff);
			}
			for (int i = 1; i <= indexes(ACS_COR, 0, ""); i++) {
				Affiliation Cor = new Affiliation();
				Cor.setId(getAid(ACS_COR, i, ""));
				if (Cor.getId().trim().isEmpty()) {
					Cor.setId("cor1");
				}
				List<String> Emails = new ArrayList<String>();
				for (int a = 1; a <= indexes(ACS_COR, i, "/email"); a++) {
					Emails.add(getText(ACS_COR, i, "/email[" + a + "]"));
				}
				
				List<String> Faxes = new ArrayList<String>();
				for (int a = 1; a <= indexes(ACS_COR, i, "/fax"); a++) {
					Faxes.add(getText(ACS_COR, i, "/fax[" + a + "]"));
				}
				
				List<String> Phones = new ArrayList<String>();
				for (int a = 1; a <= indexes(ACS_COR, i, "/phone"); a++) {
					Phones.add(getText(ACS_COR, i, "/phone[" + a + "]"));
				}
				List<String> Labels = new ArrayList<String>();
				for (int a = 1; a <= indexes(ACS_COR, i, "/phone"); a++) {
					Labels.add(getText(ACS_COR, i, "/label[" + a + "]"));
				}
				Cor.setPhone(Phones);
				Cor.setEmail(Emails);
				Cor.setFax(Faxes);
				Cor.setTags(Labels);
				Final.add(Cor);
			}
		}
		return Final;
	}

	public Author Match(Author auth, List<Affiliation> affs) {
		for (int i = 0; i < auth.getIds().size(); i++) {
			if (auth.getIds().get(i).contains("cor")) {
			auth.setCor(auth.getIds().get(i).contains("cor"));
			}
		}
		for (int i = 0; i < auth.getIds().size(); i++) {
			for (int a = 0; a < affs.size(); a++) {
				//index i for author ID, index a for affiliation list
				if (auth.getIds().get(i).contains(affs.get(a).getId()) && !auth.getIds().get(i).contains("cor")) {
					//isnt corresp
					auth.setInstitution(affs.get(a).getInstitution());
					auth.setCountry(affs.get(a).getCountry());
					auth.setDepartment(affs.get(a).getDepartment());
				} if (auth.getIds().get(i).contains(affs.get(a).getId()) && auth.getIds().get(i).contains("cor")) {
					//is corresp, nullcheck each string to not over-write
					if (affs.get(a).getCountry() != null) {
						auth.setCountry(affs.get(a).getCountry());
					}
					if (affs.get(a).getInstitution() != null) {
						auth.setInstitution(affs.get(a).getInstitution());
					}
					if (affs.get(a).getDepartment() != null) {
						auth.setDepartment(affs.get(a).getDepartment());
					}
					auth.setEmail(affs.get(a).getEmail());
					auth.setFax(affs.get(a).getFax());
					auth.setPhone(affs.get(a).getPhone());
				}
			}
		}
		return auth;
	}

	public List<Author> get() throws XPathParseException, XPathEvalException, NavException {
		List<Author> Final = new ArrayList<Author>();
		List<Author> initial = contrib();
		for (Author author : initial) {
			Final.add(Match(author, affiliations()));
		}
		return Final;
	}
	
	
}
