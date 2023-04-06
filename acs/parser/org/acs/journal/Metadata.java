package org.acs.journal;

import java.util.List;

public class Metadata {

	private String JournalId;
	private String JournalTitle;
	private String AbrevTitle;
	private List<Issn> Issn;
	private String Coden;
	private String Publisher;
	private String Uri;
	private String Doi;
	private String ArticleTitle;
	private Date PubDate;
	private String Volume;
	private String Issue;
	private String Fpage;
	private String Lpage;
	private List<Date> History;
	private String CopyrightYear;
	private String CopyrightHolder;
	private String DocumentType;
	public Metadata meta;
	
	
	
	/**
	 * @return the journalId
	 */
	public String getJournalId() {
		return JournalId;
	}
	/**
	 * @param journalId the journalId to set
	 */
	public void setJournalId(String journalId) {
		JournalId = journalId;
	}
	/**
	 * @return the journalTitle
	 */
	public String getJournalTitle() {
		return JournalTitle;
	}
	/**
	 * @param journalTitle the journalTitle to set
	 */
	public void setJournalTitle(String journalTitle) {
		JournalTitle = journalTitle;
	}
	/**
	 * @return the abrevTitle
	 */
	public String getAbrevTitle() {
		return AbrevTitle;
	}
	/**
	 * @param abrevTitle the abrevTitle to set
	 */
	public void setAbrevTitle(String abrevTitle) {
		AbrevTitle = abrevTitle;
	}
	/**
	 * @return the issn
	 */
	public List<Issn> getIssn() {
		return Issn;
	}
	/**
	 * @param issn the issn to set
	 */
	public void setIssn(List<Issn> issn) {
		Issn = issn;
	}
	/**
	 * @return the coden
	 */
	public String getCoden() {
		return Coden;
	}
	/**
	 * @param coden the coden to set
	 */
	public void setCoden(String coden) {
		Coden = coden;
	}
	/**
	 * @return the publisher
	 */
	public String getPublisher() {
		return Publisher;
	}
	/**
	 * @param publisher the publisher to set
	 */
	public void setPublisher(String publisher) {
		Publisher = publisher;
	}
	/**
	 * @return the uri
	 */
	public String getUri() {
		return Uri;
	}
	/**
	 * @param uri the uri to set
	 */
	public void setUri(String uri) {
		Uri = uri;
	}
	/**
	 * @return the doi
	 */
	public String getDoi() {
		return Doi;
	}
	/**
	 * @param doi the doi to set
	 */
	public void setDoi(String doi) {
		Doi = doi;
	}
	/**
	 * @return the articleTitle
	 */
	public String getArticleTitle() {
		return ArticleTitle;
	}
	/**
	 * @param articleTitle the articleTitle to set
	 */
	public void setArticleTitle(String articleTitle) {
		ArticleTitle = articleTitle;
	}
	/**
	 * @return the pubDate
	 */
	public Date getPubDate() {
		return PubDate;
	}
	/**
	 * @param pubDate the pubDate to set
	 */
	public void setPubDate(Date pubDate) {
		PubDate = pubDate;
	}
	/**
	 * @return the volume
	 */
	public String getVolume() {
		return Volume;
	}
	/**
	 * @param volume the volume to set
	 */
	public void setVolume(String volume) {
		Volume = volume;
	}
	/**
	 * @return the issue
	 */
	public String getIssue() {
		return Issue;
	}
	/**
	 * @param issue the issue to set
	 */
	public void setIssue(String issue) {
		Issue = issue;
	}
	/**
	 * @return the fpage
	 */
	public String getFpage() {
		return Fpage;
	}
	/**
	 * @param fpage the fpage to set
	 */
	public void setFpage(String fpage) {
		Fpage = fpage;
	}
	/**
	 * @return the lpage
	 */
	public String getLpage() {
		return Lpage;
	}
	/**
	 * @param lpage the lpage to set
	 */
	public void setLpage(String lpage) {
		Lpage = lpage;
	}
	/**
	 * @return the history
	 */
	public List<Date> getHistory() {
		return History;
	}
	/**
	 * @param history the history, multiple dates of history changes
	 */
	public void setHistory(List<Date> history) {
		History = history;
	}
	/**
	 * @return the copyrightYear
	 */
	public String getCopyrightYear() {
		return CopyrightYear;
	}
	/**
	 * @param copyrightYear the copyrightYear to set
	 */
	public void setCopyrightYear(String copyrightYear) {
		CopyrightYear = copyrightYear;
	}
	/**
	 * @return the copyrightHolder
	 */
	public String getCopyrightHolder() {
		return CopyrightHolder;
	}
	/**
	 * @param copyrightHolder the copyrightHolder to set
	 */
	public void setCopyrightHolder(String copyrightHolder) {
		CopyrightHolder = copyrightHolder;
	}
	/**
	 * @return the documentType
	 */
	public String getDocumentType() {
		return DocumentType;
	}
	/**
	 * @param documentType the documentType to set
	 */
	public void setDocumentType(String documentType) {
		DocumentType = documentType;
	}
	
	public static void main(String[] args) {
		
	}

	public String Out(Metadata M) {
		this.meta = M;
		StringBuilder builder = new StringBuilder();
		if (getJournalId() != null) {
			builder.append(getJournalId());
			builder.append(System.getProperty("line.separator"));
		}
		if (getJournalTitle() != null) {
			builder.append(getJournalTitle());
			builder.append(System.getProperty("line.separator"));
		}
		if (getAbrevTitle() != null) {
			builder.append(getAbrevTitle());
			builder.append(System.getProperty("line.separator"));
		}
		if (getIssn() != null) {
			for (int i = 0; i < getIssn().size(); i++ ){
				builder.append(getIssn().get(i).toString());
				builder.append(System.getProperty("line.separator"));
			}
		}
		if (getCoden() != null) {
			builder.append(getCoden());
			builder.append(System.getProperty("line.separator"));
		}
		if (getPublisher() != null) {
			builder.append(getPublisher());
			builder.append(System.getProperty("line.separator"));
		}
		if (getUri() != null) {
			builder.append(getUri());
			builder.append(System.getProperty("line.separator"));
		}
		if (getDoi() != null) {
			builder.append(getDoi());
			builder.append(System.getProperty("line.separator"));
		}
		if (getArticleTitle() != null) {
			builder.append(getArticleTitle());
			builder.append(System.getProperty("line.separator"));
		}
		if (getPubDate() != null) {
			builder.append(getPubDate().toString());
			builder.append(System.getProperty("line.separator"));
		}
		if (getVolume() != null) {
			builder.append(getVolume());
			builder.append(System.getProperty("line.separator"));
		}
		if (getIssue() != null) {
			builder.append(getIssue());
			builder.append(System.getProperty("line.separator"));
		}
		if (getFpage() != null) {
			builder.append(getFpage());
			builder.append(System.getProperty("line.separator"));
		}
		if (getLpage() != null) {
			builder.append(getLpage());
			builder.append(System.getProperty("line.separator"));
		}
		if (getHistory() != null) {
			for (Date date : History) {
				builder.append(date.toString());
				builder.append(System.getProperty("line.separator"));
			}
		}
		if (getCopyrightYear() != null) {
			builder.append(getCopyrightYear());
			builder.append(System.getProperty("line.separator"));
		}
		if (getCopyrightHolder() != null) {
			builder.append(getCopyrightHolder());
			builder.append(System.getProperty("line.separator"));
		}
		if (getDocumentType() != null)
			builder.append(getDocumentType());
		System.out.println(builder.toString());
		return builder.toString();
	}

	


}
