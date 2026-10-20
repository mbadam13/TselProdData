/**
 * @description       : JSON FOR OBJECT LEAD
 * @author            : RKA
 * @group             : 
 * @last modified on  : 07-05-2024
 * @last modified by  : RKA
**/
public without sharing class JSONLead {
	public Boolean allOrNone;
	public List<Records> records;

	public class Attributes {
		public String type;
	}

	public class Records {
		public Attributes attributes;
		public String id;
		public Integer NumberOfEmployees;
        public String Company;
        public String Account_Type_Z;
        public String Legal_Name_Z;
        public String Status;
        public String LeadSource;
        public String Regional_Z;
        public String Rating;
        public String LastName;
        public String Description;
        public String Email;
        public String Phone;
		public Boolean isConverted_Z;
	}

	
	public static JSONLead parse(String json) {
		return (JSONLead) System.JSON.deserialize(json, JSONLead.class);
	}
}