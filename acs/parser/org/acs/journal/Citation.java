package org.acs.journal;

import java.util.ArrayList;
import java.util.List;


public class Citation {
	private String Type = "";
	private String Id = "";
	private String Label = "";
	private List<String> Names = new ArrayList<String>();
	private String Source = "";
	private String Year = "";
	private String Volume = "";
	private String Fpage = "";
	private String Lpage = "";
	private String Doi = "";
	private String Publisher = "";
	private String Location = "";
	private String Title = "";
	private String Collab = "";
	private String Uri = "";
	private String Issue = "";
	private String Text = "";
	private String SubNote = "";
	private String PatentNumber = "";
	
//test object for citations/refs
	//no long test
	
	
	public void setType(String Type) {
		this.Type = Type;
	}

	public String getType() {
		return Type;
	}

	public void setId(String Id) {
		this.Id = Id;
	}
	
	public String getId() {
		return Id;
	}
	
	public void setLabel(String Label) {
		this.Label = Label;
	}
	
	public String getLabel() {
		return Label;
	}

	public void setNames(List<String> Names) {
		this.Names = Names;
	}

	public List<String> getNames() {
		return Names;
	}

	public void setSource(String Source) {
		this.Source = Source;
	}
	
	public String getSource() {
		return Source;
	}
	
	public void setYear(String Year) {
		this.Year = Year;
	}
	
	public String getYear() {
		return Year;
	}
	
	public void setVolume(String Volume) {
		this.Volume = Volume;
	}

	public String getVolume() {
		return Volume;
	}

	public void setFpage(String Fpage) {
		this.Fpage = Fpage;
	}
	
	public String getFpage() {
		return Fpage;
	}

	public void setDoi(String Doi) {
		this.Doi = Doi;
	}
	
	public String getDoi() {
		return Doi;
	}
	
	public void setLpage(String L) {
		this.Lpage = L;
	}
	
	public String getLpage() {
		return Lpage;
	}
	
	public void setPublisher(String Publisher) {
		this.Publisher = Publisher;
	}
	
	public String getPublisher() {
		return Publisher;
	}
	
	public void setLocation(String Location) {
		this.Location = Location;
	}
	
	public String getLocation() {
		return Location;
	}
	
	public void setTitle(String Title) {
		this.Title = Title;
	}
	
	public String getTitle() {
		return Title;
	}
	
	public void setCollab(String Collab) {
		this.Collab = Collab;
	}
	
	public String getCollab() {
		return Collab;
	}
	
	public void setUri(String Uri) {
		this.Uri = Uri;
	}
	
	public String getUri() {
		return Uri;
	}
	
	public String Info() {
		String Final = Source + "\n" + "Volume: " + Volume + ". Page: " + Fpage + ". Year: " + Year + ".";
		return Final;
	}
	
	public void setIssue(String Issue) {
		this.Issue = Issue;
	}
	
	public String getIssue() {
		return Issue;
	}
	
	public void setText(String Text) {
		this.Text = Text;
	}
	
	public String getText() {
		return Text;
	}
	
	public void setSubNote(String note) {
		this.SubNote = note;
	}
	
	public String getSubNote(String note) {
		return SubNote;
	}
	
	public void setPatentNumber(String PatentNumber) {
		this.PatentNumber = PatentNumber;
	}
	
	public String getPatentNumber() {
		return PatentNumber;
	}
	
	public String toString() {
		StringBuilder builder = new StringBuilder();
		if (getType() != null) {
			builder.append(getType());
			builder.append(System.getProperty("line.separator"));
		}
		if (getId() != null) {
			builder.append(getId());
			builder.append(System.getProperty("line.separator"));
		}
		if (getLabel() != null) {
			builder.append(getLabel());
			builder.append(System.getProperty("line.separator"));
		}
		if (getNames() != null) {
			builder.append(getNames());
			builder.append(System.getProperty("line.separator"));
		}
		if (getSource() != null) {
			builder.append(getSource());
			builder.append(System.getProperty("line.separator"));
		}
		if (getYear() != null) {
			builder.append(getYear());
			builder.append(System.getProperty("line.separator"));
		}
		if (getVolume() != null) {
			builder.append(getVolume());
			builder.append(System.getProperty("line.separator"));
		}
		if (getFpage() != null) {
			builder.append(getFpage());
			builder.append(System.getProperty("line.separator"));
		}
		if (getDoi() != null) {
			builder.append(getDoi());
			builder.append(System.getProperty("line.separator"));
		}
		if (getLpage() != null) {
			builder.append(getLpage());
			builder.append(System.getProperty("line.separator"));
		}
		if (getPublisher() != null) {
			builder.append(getPublisher());
			builder.append(System.getProperty("line.separator"));
		}
		if (getLocation() != null) {
			builder.append(getLocation());
			builder.append(System.getProperty("line.separator"));
		}
		if (getTitle() != null) {
			builder.append(getTitle());
			builder.append(System.getProperty("line.separator"));
		}
		if (getCollab() != null) {
			builder.append(getCollab());
			builder.append(System.getProperty("line.separator"));
		}
		if (getUri() != null) {
			builder.append(getUri());
			builder.append(System.getProperty("line.separator"));
		}
		if (Info() != null) {
			builder.append(Info());
			builder.append(System.getProperty("line.separator"));
		}
		if (getIssue() != null) {
			builder.append(getIssue());
			builder.append(System.getProperty("line.separator"));
		}
		if (getText() != null) {
			builder.append(getText());
			builder.append(System.getProperty("line.separator"));
		}
		if (getPatentNumber() != null)
			builder.append(getPatentNumber());
		return builder.toString();
	}

	//for printing outputs
	public void Out(Citation citation) {
		if (citation.getNames() == null) {
			List<String> newNames = new ArrayList<String>();
			newNames.add("");
			citation.setNames(newNames);
		}
		System.out.println(citation.toString());
		System.out.println("\r\n\r\n");
	}
	
	public String	oldOut(Citation citation) { //only test never call
		String names = null;
		String Final = null;
		//fix names list for null
		if (citation.getNames() == null) {
			List<String> newNames = new ArrayList<String>();
			newNames.add(" ");
			citation.setNames(newNames);
		}
		//type sorting
		if(citation.getType().equals("web")) {
			for (int i = 0; i < Names.size(); i++) {
				names+=Names.get(i) + System.getProperty("line.separator");
			}
			Final = Source + System.getProperty("line.separator") + Collab + System.getProperty("line.separator") + Uri + System.getProperty("line.separator") + Year;

		} else if (citation.getType().equals("book")) {
			for (int i = 0; i < Names.size(); i++) {
				names+=Names.get(i) + ", ";
			}
			Final = Source + System.getProperty("line.separator") + Publisher + " " + Location + System.getProperty("line.separator") + Year + System.getProperty("line.separator") + Fpage + System.getProperty("line.separator") + names;
			
		} else if (citation.getType().equals("journal")) {
			for (int i = 0; i < Names.size(); i++) {
				names+=Names.get(i) + ", ";
			}
			Final = Title + System.getProperty("line.separator") + Source + System.getProperty("line.separator") + Doi + System.getProperty("line.separator") + Year + System.getProperty("line.separator") + "Volume " + Volume + ", Page " + Fpage + System.getProperty("line.separator") + names;
			
		} else if (citation.getType().equals("patent")) {
			for (int i = 0; i < Names.size(); i++) {
				names+=Names.get(i) + ", ";
			}
			Final = Source + System.getProperty("line.separator") + Year + System.getProperty("line.separator") + names;
					
		} else if (citation.getType().equals("gov")) {
			for (int i = 0; i < Names.size(); i++) {
				names+=Names.get(i) + ", ";
			}
			Final = Source + System.getProperty("line.separator") + Location + System.getProperty("line.separator") +  Year + System.getProperty("line.separator") + Collab + System.getProperty("line.separator") + names;	
			
		} else if (citation.getType().equals("computer-program")) {
			for (int i = 0; i < Names.size(); i++) {
				names+=Names.get(i) + ", ";
			}
			Final = Source + System.getProperty("line.separator") + Publisher + System.getProperty("line.separator") + Location + System.getProperty("line.separator") +  Year + System.getProperty("line.separator") + names;	
		} else if (citation.getType().equals("report")) {
			for (int i = 0; i < Names.size(); i++) {
				names+=Names.get(i) + ", ";
			}
			Final = Title + System.getProperty("line.separator") + Source + System.getProperty("line.separator") + Publisher + System.getProperty("line.separator") + Location + System.getProperty("line.separator") + Year + System.getProperty("line.separator") + names;
		} else if (citation.getType().equals("note")) {
			Final = Text;
		} else {
			Final = Type + " not parsed";
		}
		return Final;
		//for testing below
		//String Final = Source + "       " + "Volume: " + Doi + "     " + Volume + ". Page: " + Fpage + ". Year: " + Year + "      "  + names; 
		//return Final;
	}
}

