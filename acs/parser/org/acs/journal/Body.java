package org.acs.journal;


import java.util.List;

public class Body {
	private String XML;
	private String Text;
	private List<String> Captions;
	private List<String> tags;
	
	public void setText(String Text) {
		if (Text == null) {
			Text = "";
			this.Text = Text;
		} else {
			this.Text = Text;
		}
	}
	
	public String getText() {
		return Text;
	}
	
	public void setXML(String XML) {
		this.XML = XML;
	}
	
	public String getXML() {
		return XML;
	}
	
	public void setCaptions(List<String> Captions) {
		this.Captions = Captions;
	}
	
	public List<String> getCaptions() {
		return this.Captions;
	}
	
	public void setTags(List<String> tags) {
		this.tags = tags;
	}
	
	public List<String> getTags() {
		return this.tags;
	}

	public void Out(Body B) {
		String str = B.getText();
		str = str.replace("\n", " ").replace("\r", " ");
		str = str.replaceAll("\\P{Print}", "");
		System.out.println(str);
		System.out.println("\r\n");
		for (String str1 : B.getCaptions()) {
			str1 = str1.replace("\n", " ").replace("\r", " ");
			str1 = str1.replaceAll("\\P{Print}", "");
			System.out.println(str1);
		}
//		for (String str1 : B.getTags()) {
//			str1 = str1.replace("\n", " ").replace("\r", " ");
//			str1 = str1.replaceAll("\\P{Print}", "");
//			System.out.println(str1);
//		}
                 
	}
}
