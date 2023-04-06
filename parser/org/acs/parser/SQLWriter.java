package org.acs.parser;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import org.acs.journal.Article;
import org.acs.journal.Author;
import org.acs.journal.Citation;

/**
 * 
 * @author I00057
 *
 */
public class SQLWriter {
	
	/**
	 * 
	 * @return  a connection to address at blank/blank
	 */
	public Connection getConnection() {
		String dbDriver = "oracle.jdbc.driver.OracleDriver";
		try { 
			Class.forName(dbDriver).newInstance();
			Connection conn = DriverManager.getConnection
						("jdbc:oracle:thin:@acs-ip-address:8080/test.url", "blank", "blank");
			return conn;
			} catch (SQLException e) {
				e.printStackTrace();
			} catch (InstantiationException e) {
				e.printStackTrace();
			} catch (IllegalAccessException e) {
				e.printStackTrace();
			} catch (ClassNotFoundException e) {
				e.printStackTrace();
			}
		return null;
		
		}
	public void Clear() {
		int id = 0;
		try {
		Connection conn = getConnection();
		String query = "delete from AUTHOR where MANUSCRIPT_ID > ?";
		PreparedStatement stmt = conn.prepareStatement(query);
		stmt.setInt(1,  id);
		stmt.execute();

		String query1 = "delete from MANUSCRIPT where MANUSCRIPT_ID >  ?"; 
		PreparedStatement stmt1 = conn.prepareStatement(query1);
		stmt1.setInt(1,  id);
		stmt1.execute();
		
		String query2 = "delete from CITATION where MANUSCRIPT_ID > ?"; 
		PreparedStatement stmt2 = conn.prepareStatement(query2);
		stmt2.setInt(1,  id);
		stmt2.execute();
		conn.close();
		} catch (SQLException e) {
			e.printStackTrace();
		}
	}
	/**
	 * 
	 * @param conn 
	 * @param table
	 * @return deletes the already parsed row if it is parsing again hopefully this is void (ignore type)
	 */ 
	public void Delete(Connection conn, int id) {
		try {
		String query = "delete from AUTHOR where MANUSCRIPT_ID = ?";
		PreparedStatement stmt = conn.prepareStatement(query);
		stmt.setInt(1,  id);
		stmt.execute();

		String query1 = "delete from MANUSCRIPT where MANUSCRIPT_ID =  ?"; 
		PreparedStatement stmt1 = conn.prepareStatement(query1);
		stmt1.setInt(1,  id);
		stmt1.execute();
		
		String query2 = "delete from CITATION where MANUSCRIPT_ID = ?"; 
		PreparedStatement stmt2 =	 conn.prepareStatement(query2);
		stmt2.setInt(1,  id);
		stmt2.execute();
		
		String query3 = "delete from MULTIMEDIA where MANUSCRIPT_ID = ?"; 
		PreparedStatement stmt3 =	 conn.prepareStatement(query3);
		stmt3.setInt(1,  id);
		stmt3.execute();
		
		} catch (SQLException e) {
			e.printStackTrace();
		}
	}
	
	/**
	 * @param Article
	 * @param Conn
	 */
	public void write(Article Article, Connection Conn) {
		//all singular GET methods return an sql prepared statement
		String DOI = Article.getMetadata().getDoi();
		//remove already parsed articles from tables for multiple parsings 
		//drop whole table or just row?
		int m = Article.getManuId(Conn, DOI);
		Delete(Conn, m); //deletes already parsed if DOI matches current parsing
		try {
			//write in the parsed article to Db
			for (int i = 0;  i < Article.getCitations().size(); i++) {
				Citation Citation = Article.getCitations().get(i);
				PreparedStatement pst = Article.getCitation(m, Conn, Citation);
				pst.execute();
				
				pst.close();
				if(i%5 == 0 || i == Article.getCitations().size()-1) Conn.commit();
			}
			for (Author Author : Article.getAuthors()) {
				Article.getAuthor(m, Conn, Author).execute();
				Article.getAuthor(m, Conn, Author).close();
			}
			
			Article.getManuscript(m, Conn, Article.getMetadata(), Article.getAuthors(), Article.getAbstract(), Article.getBody()).execute();
			
			for (int i = 0; i < Article.getBody().getCaptions().size(); i++) {
				Article.getMultiMedia(m, Conn, Article.getBody(), i).execute();
				Article.getMultiMedia(m, Conn, Article.getBody(), i).close();
				if(i%5 == 0 || i == Article.getBody().getCaptions().size()-1) Conn.commit();
			}
			
			Conn.commit();
		} catch (SQLException e) {
			e.printStackTrace();
		}
	}
}
