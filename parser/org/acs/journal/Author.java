package org.acs.journal;

import java.util.List;

public class Author {
	private String Name;
	private List<String> Email;
	private List<String> Phone;
	private String Institution;
    private List<String> Fax;
    private boolean Cor;
    private List<String> Ids;
    private String Department;
    private String Country;
    private String Orcid;
    private String Role;
    
    public void setIds(List<String> Ids) {
    	this.Ids = Ids;
    }
    public List<String> getIds() {
    	return this.Ids;
    }
    public void setName(String Name) {
    	this.Name = Name;
    }
    public String getName() {
    	return this.Name;
    }
    
    public void setEmail(List<String> Email) {
    	this.Email = Email;
    }
    public List<String> getEmail() {
    	return this.Email;
    }
    
    public void setPhone(List<String> Phone) {
    	this.Phone = Phone;
    }
    public List<String> getPhone() {
    	return this.Phone;
    }
    
    public void setFax(List<String> Fax) {
    	this.Fax = Fax;
    }
    public List<String> getFax() {
    	return this.Fax;
    }
    
    public void setInstitution(String I) {
    	this.Institution = I;
    }
    public String getInstitution() {
    	return this.Institution;
    }
    
    public void setCor(boolean B) {
    	this.Cor = B;
    }
    public boolean getCor() {
    	return this.Cor;
    }
    
    public void setDepartment(String D) {
    	this.Department = D;
    }
    public String getDepartment() {
    	return this.Department;
    }
    
    public void setCountry(String C) {
    	this.Country = C;
    }
    public String getCountry() {
    	return this.Country;
    }
    public void setOrcid(String Id) {
    	this.Orcid = Id;
    }
    public String getOrcid() {
    	return this.Orcid;
    }
    public void setRole(String R) {
    	this.Role = R;
    }
    public String getRole() {
    	return this.Role;
    }
    public void Out(Author author) {
    	System.out.println(author.Name);
    	if (author.getRole().length()>2) System.out.println(author.getRole());
    	if (author.getOrcid() != null) {
    		System.out.println(author.getOrcid());
    	}
    	System.out.println(author.Department);
    	System.out.println(author.Institution);
    	System.out.println(author.Country);
    	if (author.Email!=null) {
	    	for (int i = 0; i < author.Email.size(); i++) {
	    		System.out.println(author.getEmail().get(i));
	    	}
    	}
    	if (author.Phone!=null) {
	    	for (int i = 0; i <	author.Phone.size(); i++) {
	    		System.out.println(author.getPhone().get(i));
	    	}
    	}
    	if (author.Fax!=null) {
	    	for (int i = 0; i < author.Fax.size(); i++) {
	    		System.out.println(author.getFax().get(i));
	    	}
    	}
    	System.out.println(author.Cor);
    	System.out.println("\r\n\r\n");
    }
}
