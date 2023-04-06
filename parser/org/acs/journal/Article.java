
package org.acs.journal;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.List;

//pass from parser to SQL writer 
public class Article {
	
	private Metadata Metadata;
	private List<Author> Authors;
	private Abstract Abstract;
	private Body Body;
	private List<Citation> Citations;
	
	public Metadata getMetadata() {
		return Metadata;
	}
	public void setMetadata(Metadata metadata) {
		Metadata = metadata;
	}
	public List<Author> getAuthors() {
		return Authors;
	}
	public void setAuthors(List<Author> authors) {
		Authors = authors;
	}
	public Abstract getAbstract() {
		return Abstract;
	}
	public void setAbstract(Abstract abstract1) {
		Abstract = abstract1;
	}  
	public Body getBody() {
		return Body;
	}
	public void setBody(Body body) {
		Body = body;
	}
	public List<Citation> getCitations() {
		return Citations;
	}
	public void setCitations(List<Citation> citations) {
		Citations = citations;
	}
	
	
	public static void main(String[] args) throws ParseException {
		String date = "2011-1-16";
		java.util.Date utilDate = new SimpleDateFormat("yyyy-MM-dd").parse(date);
		java.sql.Date sqlDate = new java.sql.Date(utilDate.getTime()); 
		Calendar c = Calendar.getInstance();
		c.setTimeInMillis(sqlDate.getTime()); //why did i do this?
		System.out.println(c.get(Calendar.YEAR));
		System.out.println(c.get(Calendar.MONTH));
		System.out.println(c.get(Calendar.DAY_OF_MONTH));
	}
	

	public java.sql.Date makeDate(Date d) throws ParseException {
		//why did i make a format?
		String date = d.getYear() + "-" + d.getMonth() + "-" + d.getDay();
		java.util.Date utilDate = new SimpleDateFormat("yyyy-MM-dd").parse(date);
		java.sql.Date sqlDate = new java.sql.Date(utilDate.getTime());
		return sqlDate;
	}
	
	public int getCitId(Connection conn, int Mid) {
		int Final = 0;
		//String look = "select CITATION_ID from CITATION where MANUSCRIPT_ID =  ?";
		try {
//			PreparedStatement s = conn.prepareStatement(look);
//			s.setInt(1, Mid);
//			ResultSet rs = s.executeQuery();
//			while(rs.next()) {
//				Final = rs.getInt("CITATION_ID"); 
//			}
//			rs.close();
			if (Final == 0) {
				Statement st = conn.createStatement();
				//at  87, too many cursors
				ResultSet rst = st.executeQuery("select MSPUBS.SQ_CITATION_ID.nextval from dual");
				while(rst.next()) {
					Final = rst.getInt(1);
				}
				rst.close();
				st.close();
				conn.commit();
			}
		} catch (SQLException e) {
			e.printStackTrace();
		}
		return Final;
	}
	
	public int getAuthId(Connection conn, int Mid) {
		int Final = 0;
		String look = "select AUTHOR_ID from AUTHOR where MANUSCRIPT_ID = ?";
		try {
			if (Final == 0) { //search and replace authID instead of querying nextval?
				PreparedStatement st = conn.prepareStatement(look);
				ResultSet rst = st.executeQuery("select MSPUBS.SQ_AUTHOR_ID.nextval from dual");
				while(rst.next()) {
					Final = rst.getInt(1);
				}
				st.close();
			}
		} catch (SQLException e) {
			e.printStackTrace();
		}
		return Final;
	}
	
	public int getManuId(Connection conn, String doi) {
		int Final = 0;
		String look = "select MANUSCRIPT_ID from MANUSCRIPT where DOI = ?";
		try {
		PreparedStatement s = conn.prepareStatement(look);
		s.setString(1, doi);
		ResultSet rs = s.executeQuery();
		while(rs.next()) {
			Final = rs.getInt("MANUSCRIPT_ID");
		}
		if (Final == 0) {
			PreparedStatement st = conn.prepareStatement(look);
			ResultSet rst = st.executeQuery("select MSPUBS.SQ_MANUSCRIPT_ID.nextval from dual");
			while(rst.next()) {
				Final = rst.getInt(1);
			}
		}
		} catch (SQLException e) {
			e.printStackTrace();
		}
		return Final;
	}
	
	public int getMultiMediaId(Connection conn, int Mid) {
		int Final = 0;
		try {
			if (Final == 0) {
				Statement st = conn.createStatement();	
				ResultSet rst = st.executeQuery("select MSPUBS.SQ_MULTIMEDIA_ID.nextval from dual");
				while(rst.next()) {
					Final = rst.getInt(1);
				}
				rst.close();
				st.close();
				conn.commit();
			}
		} catch (SQLException e) {
			e.printStackTrace();
		}
		return Final;
	}
	
	public PreparedStatement getManuscript(int mid, Connection conn, Metadata M, List<Author> As, Abstract A, Body B) {
		StringBuffer Buffer = new StringBuffer("insert into MANUSCRIPT("
				+ "MANUSCRIPT_ID, DOI, type, CODEN, TITLE, ABSTRACT, FULL_TEXT, VOLUME, ISSUE, YEAR)"
				+ "values(?, ?, ?, ?, ?, ?, ?, ?, ?, ?)"); 
		String query = Buffer.toString(); //why did i do this with a buffer
		PreparedStatement Final = null;
		String CopyYear = (M.getCopyrightYear().trim().isEmpty() || M.getCopyrightYear() == null) ? "0" : M.getCopyrightYear();
		String Volume = (M.getVolume().trim().isEmpty() || M.getVolume() == null) ? "0" : M.getVolume();
		String Issue = (M.getIssue().trim().isEmpty() || M.getIssue() == null) ? "0" : M.getIssue();
		try {
			Final = conn.prepareStatement(query);
			Final.setInt(1, mid); //FIXME for manuscript id query the sequence
			Final.setString(2, M.getDoi()); 
			Final.setString(3, M.getDocumentType());
			Final.setString(4, M.getCoden());
			Final.setString(5, M.getArticleTitle());
			Final.setString(6, A.getText()); //abstract
			Final.setString(7, B.getText()); //Full text
			Final.setInt(8, Integer.parseInt(Volume));
			Final.setInt(9, Integer.parseInt(Issue));
			Final.setInt(10, Integer.parseInt(CopyYear));
			//FIXME PUT BACK Final.setDate(11, makeDate(M.getPubDate()));
			
	//		Final.setDate(13, makeDate()); //current time
	//		Final.setDate(14, makeDate()); //modified time
		} catch (SQLException e) {
			e.printStackTrace();
		}
//		catch (ParseException e) {
//			e.printStackTrace();
//		}
		return Final;
	}
	
	public PreparedStatement getMultiMedia(int mid, Connection conn, Body B, int index) {
		String query = "insert into MULTIMEDIA("
				+ "MULTIMEDIA_ID, MANUSCRIPT_ID, CAPTION, TYPE) "
				+ "values(?,?,?,?)";
		PreparedStatement stmnt = null;
		int mmid = getMultiMediaId(conn, mid);
		try {
			stmnt = conn.prepareStatement(query);
			stmnt.setInt(1, mmid);
			stmnt.setInt(2, mid);
			stmnt.setString(3, B.getCaptions().get(index));
			stmnt.setString(4, B.getTags().get(index));
		} catch (SQLException e) {
			e.printStackTrace();
		}
		return stmnt;
	}
	
	public PreparedStatement getCitation(int mid, Connection conn, Citation C) {
		String query = "insert into CITATION("
				+ "CITATION_ID, MANUSCRIPT_ID, JOURNAL_NAME, TITLE, AUTHOR_1, AUTHOR_2, AUTHOR_3, VOLUME, ISSUE, YEAR, REF_DOI )"
				+ "values(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
		PreparedStatement Final = null;
		int cid = getCitId(conn, mid);
		String vol = (C.getVolume().trim().isEmpty() || C.getVolume() == null) ? "0" : C.getVolume();
			vol = vol.length() > 8 ? vol.substring(0,4) : vol;
			vol = Long.parseLong(vol) > 1000 ? "0" : vol; //too large for int... 10x
		String issue = (C.getIssue().trim().isEmpty() || C.getIssue() == null) ? "0" : C.getIssue();
			issue = issue.length() > 8 ? issue.substring(0,4) : issue;
			issue = Long.parseLong(issue) > 1000 ? "0" : issue;
		String year = (C.getYear().trim().isEmpty() || C.getYear() == null) ? "0" : C.getYear();
			year = year.length() > 8 ? year.substring(0,4) : year;
			year = Long.parseLong(year) > 100000 ? "0" : year;
		try {
			Final = conn.prepareStatement(query);
			List<String> newNames = C.getNames();
			newNames.add(""); //incase of empty list add blank names
			newNames.add("");
			newNames.add(""); 
			C.setNames(newNames);
			//int Ref = Integer.parseInt(C.getId().substring(3));
			Final.setInt(1, cid); 
			Final.setInt(2, mid); //query sequence
			Final.setString(3, C.getSource()); //journal name
			Final.setString(4,C.getTitle()); //article title
			Final.setString(5, C.getNames().get(0)); //author 1
			Final.setString(6, C.getNames().get(1));
			Final.setString(7, C.getNames().get(2));
			Final.setInt(8, Integer.parseInt(vol));
			Final.setInt(9, Integer.parseInt(issue));
			Final.setInt(10, Integer.parseInt(year));
			Final.setString(11, C.getDoi());
		} catch (SQLException e) {
			e.printStackTrace();
		}
		
		return Final;
	}
	
	public PreparedStatement getAuthor(int mid, Connection conn, Author A) {
		String query = "insert into AUTHOR("
				+ "AUTHOR_ID, MANUSCRIPT_ID, FIRST_NAME, LAST_NAME, "
				+ "PHONE, FAX, EMAIL, CORRESPONDING_AUTHOR_FLAG, "
				+ "INSTITUTION_DEPT, COUNTRY_NAME, ORC_ID)"
				+ "values(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)"; //most columns dont exist in xml
	List<String> newEmails = new ArrayList<String>();
	if (A.getEmail() != null) newEmails.addAll(A.getEmail());
	newEmails.add(" ");
	A.setEmail(newEmails);
	String ORCID = A.getOrcid().trim().isEmpty() ? " " : A.getOrcid();
	List<String> newPhone = new ArrayList<String>();
	if(A.getPhone() != null) newPhone.addAll(A.getPhone());
	newPhone.add(" ");
	A.setEmail(newPhone);
	
	List<String> newFax = new ArrayList<String>();
	if (A.getFax() != null) newFax.addAll(A.getFax());
	newFax.add(" ");
	A.setFax(newFax);
	
	int aid = getAuthId(conn, mid);
	String flag = A.getCor() ? "y" : "n";
	String[] names = A.getName().split(" ");
	if (names.length < 2) {
		String[] newNames = {"", ""}; 
		names = newNames;
	}
	PreparedStatement stmnt = null;
	try {
		stmnt = conn.prepareStatement(query);
		stmnt.setInt(1, aid); 
		stmnt.setInt(2, mid);
		stmnt.setString(3, names[0]);
		stmnt.setString(4, names[1]);
		stmnt.setString(7, newEmails.get(0)); 
		stmnt.setString(8, flag);
		stmnt.setString(6, newFax.get(0));
		stmnt.setString(5, newPhone.get(0));
		stmnt.setString(9, A.getDepartment());
		stmnt.setString(10, A.getCountry());
		stmnt.setString(11, ORCID);
	} catch (SQLException e) { 
		e.printStackTrace();
	}
	return stmnt;
	}
}
