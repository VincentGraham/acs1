package org.acs.journal;

public class Date {
	private String Day;
	private String Month;
	private String Year;
	private String Type;
	//this should be converted to SQLDate
	public Date(String string, String string2, String string3) {
		this.Day = string;
		this.Month = string2;
		this.Year = string3;
	}

	/**
	 * @return the day
	 */
	public String getDay() {
		return Day;
	}

	/**
	 * @param day the day to set
	 */
	public void setDay(String day) {
		Day = day;
	}

	/**
	 * @return the month
	 */
	public String getMonth() {
		return Month;
	}

	/**
	 * @param month the month to set
	 */
	public void setMonth(String month) {
		Month = month;
	}

	/**
	 * @return the year
	 */
	public String getYear() {
		return Year;
	}

	/**
	 * @param year the year to set
	 */
	public void setYear(String year) {
		Year = year;
	}

	/**
	 * @return the type
	 */
	public String getType() {
		return Type;
	}

	/**
	 * @param type the type to set
	 */
	public void setType(String type) {
		Type = type;
	}


	@Override
	public String toString() {
		StringBuilder builder = new StringBuilder();
		builder.append(Year);
		builder.append(".");
		builder.append(Month);
		builder.append(".");
		builder.append(Day);
		builder.append("   ");
		if (getType() != null)
			builder.append("Type: ");
			builder.append(getType());
		return builder.toString();
	}
}
