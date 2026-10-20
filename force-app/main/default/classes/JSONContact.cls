/**
 * @description       : JSON CLASS FOR OBJECT CONTACT CSSM
 * @author            : RKA
 * @group             : 
 * @last modified on  : 07-05-2024
 * @last modified by  : RKA
**/
public without sharing class JSONContact {
    public Boolean allOrNone;
	public List<Records> records;

	public class Attributes {
		public String type;
	}

	public class Records {
		public Attributes attributes;
		public String RecordTypeId;
		public String External_Id_Z;
        public String FirstName;
        public String LastName;
        public String AccountId;
        public String Title;
        public String Email;
        public String Phone;
        public String MobilePhone;
        public String Originally_Reports_to_Z;
        public String Department;
        public String Fax;
	}
	
	public static JSONContact parse(String json) {
		return (JSONContact) System.JSON.deserialize(json, JSONContact.class);
	}
}