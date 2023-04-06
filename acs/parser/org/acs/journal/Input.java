package org.acs.journal;

public class Input {
	private int Year;
	private int Issue;
	private String Coden;
	private boolean Input;
	
	public void setYear(int Year) {
		this.Year = Year;
	}
	
	public int getYear() {
		return Year;
	}
	
	public void setIssue(int Issue) {
		this.Issue = Issue;
	}
	
	public int getIssue() {
		return Issue;
	}
	
	public void setCoden(String Coden) {
		this.Coden = Coden;
	}
	
	public String getCoden() {
		return Coden;
	}
	
	public void setInput(boolean a) {
		Input = a;
	}
	
	public boolean getInput() {
		return Input;
	}
}
