/**
 * @description       : JSON CLASS FOR ACCOUNT CSSM
 * @author            : RKA
 * @group             : 
 * @last modified on  : 07-05-2024
 * @last modified by  : RKA
**/
public without sharing class JSONAccount {
    public Boolean allOrNone;
	public List<Records> records;

	public class Attributes {
		public String type;
	}

	public class Records {
		public Attributes attributes;
        public String RecordTypeId;
        public String External_Id_Z;
		public String Name;
        public String Account_Type_Z;
        public String Website;
        public String Phone;
        public String Email_Z;
        public String Telephone_2_Z;
        public String Fax;
        public String Fax_Number_2_Z;
        public String BP_Number_Z;
        public String LOB_Z;
        public String User_ID_Z;
        public String Kategori_Bisnis_Z;
        public String Account_Category_Z;
        public String Registrasi_Status_Z;
        public String No_PKS_Z;
        public Date Active_Contract_Start_Date_Z;
        public Date Active_Contract_End_Date_Z;
        public String ContractId_Z;
        public String Ext_Partner_Id_Z;
        public String Merchant_Id_Z;
        public String Description;
        public String Legal_Name_Z;
        public String NPWP_Z;
        public String NPWP_Address_Z;
        public String Email_Address_Tax_Z;
        public String Email_Address_Payment_Z;
        public String Email_Address_Finance_or_A_P_Z;
        public String Email_Address_Marketing_Z;
        public Double Balance_Top_Up_Voucher_Z;
        public Double Balance_Top_Up_Invoice_Z;
        public Double Total_Balance_Z;
        public Double Balance_Terpakai_Z;
        public Double Balance_Remaining_Z;
        public Double Total_Revenue_Z;
        public Date Tanggal_Approval_Z;
        public Date Tanggal_Daftar_Z;
	}

	
	public static JSONAccount parse(String json) {
		return (JSONAccount) System.JSON.deserialize(json, JSONAccount.class);
	}
}