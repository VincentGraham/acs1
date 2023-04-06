package org.acs.journal;

public class Issn {
	
	private String Number;
	private String type;
	
	public String getNumber() {
		return Number;
	}
	public void setNumber(String number) {
		Number = number;
	}
	public String getType() {
		return type;
	}
	public void setType(String type) {
		this.type = type;
	}
	/* (non-Javadoc)
	 * @see java.lang.Object#toString()
	 */
	@Override
	public String toString() {
		StringBuilder builder = new StringBuilder();
		if (getNumber() != null) {
			builder.append(getNumber());
			builder.append(". Type: ");
		}
		if (getType() != null && !getType().isEmpty())
			builder.append(getType());
		return builder.toString();
	}
	
	
	
	
}
