package org.acs.journal;

public class Abstract {
	private String Text;
	private String XML;
	
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

	/* (non-Javadoc)
	 * @see java.lang.Object#toString()
	 */
	@Override
	public String toString() {
		StringBuilder builder = new StringBuilder();
		if (getText() != null) {
			String str = getText();
			str = str.replace("\n", " ").replace("\r", " ");
			builder.append(getText());
		}
		return builder.toString();
	}

	public void Out(Abstract ABS) {
		String str = ABS.getText();
		str = str.replace("\n", " ").replace("\r", " ");
		String clean = str.replaceAll("\\P{Print}", "");
		System.out.println(clean);
	}
}
