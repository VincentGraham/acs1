package org.acs.journal;

import java.util.List;

public class Affiliation {
    private String Id;
    private String Label;
    private String Name;
    private List<String> Phone_numbers;
    private List<String> Fax;
    private List<String> Emails;
    private String Institution;
    private String Department;
    private String Country;
    private List<String> Tags;


    public void setId(String id) {
        this.Id = id;
    }
    public String getId() {
        return Id;
    }


    public void setLabel(String label) {
        this.Label = label;
    }
    public String getLabel() {
        return Label;
    }

    public void setName(String name) {
        this.Name = name;
    }
    public String getName() {
        return Name;
    }

    
    public void setFax(List<String> fax) {
    	this.Fax = fax;
    }
    public List<String> getFax() {
    	return Fax;
    }
    
    public void setPhone(List<String> phone_numbers) {
    	this.Phone_numbers = phone_numbers;
    }
    public List<String> getPhone() {
    	return Phone_numbers;
    }
    
    public void setEmail(List<String> emails) {
    	this.Emails = emails;
    }
    public List<String> getEmail() {
    	return Emails;
    }
    public void setInstitution(String I) {
    	this.Institution = I;
    }
    public String getInstitution() {
    	return this.Institution;
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
    public void setTags(List<String> T) {
    	this.Tags = T;
    }
    public List<String> getTags() {
    	return this.Tags;
    }
}
