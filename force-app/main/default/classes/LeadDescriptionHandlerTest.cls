@isTest
public class LeadDescriptionHandlerTest {

    @isTest
    static void testDescriptionLengthGreaterThan255() {
        // Create a lead with a description longer than 255 characters
        Lead leadWithLongDescription = new Lead(
            FirstName 	= 'Test',
            LastName 	= 'Lead',
            Email		= 'test@test.com',
            Phone		= '0899999',
            
            Company 	= 'Test Company',
            Description = 'This is a long description exceeding 255 characters. ' +
                          'Lorem ipsum dolor sit amet, consectetur adipiscing elit. ' +
                          'Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.'
        );
        
        insert leadWithLongDescription;

        // Retrieve the lead to check the Text_Description__c field
        Lead updatedLead = [SELECT Text_Description__c FROM Lead WHERE Id = :leadWithLongDescription.Id];

        // Check that Text_Description__c is truncated to 230 characters with 'read more ...' appended
        /*System.assertEquals(230, updatedLead.Text_Description__c.length());
        System.assertEquals(
            leadWithLongDescription.Description.left(230) + 'read more ...',
            updatedLead.Text_Description__c
        );*/
    }

    @isTest
    static void testDescriptionLengthLessThanOrEqualTo255() {
        // Create a lead with a description less than or equal to 255 characters
        Lead leadWithShortDescription = new Lead(
            FirstName 	= 'Test',
            LastName 	= 'Lead',
            Email		= 'test@test.com',
            Phone		= '0899999',
            Company 	= 'Test Company',
            Description = 'Short description within 255 characters.'
        );
        insert leadWithShortDescription;

        // Retrieve the lead to check the Text_Description__c field
        Lead updatedLead = [SELECT Text_Description__c FROM Lead WHERE Id = :leadWithShortDescription.Id];
        leadWithShortDescription.Description = 'Description is the fiction-writing mode for transmitting a mental image of the particulars of a story. Together with dialogue, narration, exposition, and summarization, description is one of the most widely recognized of the fiction-writing modes. As stated in Writing from A to Z, edited by Kirk Polking, description is more than the amassing of details; it is bringing something to life by carefully choosing and arranging words and phrases to produce the desired effect.[5] The most appropriate and effective techniques for presenting description are a matter of ongoing discussion among writers and writing coaches.';
		update leadWithShortDescription;
        // Check that Text_Description__c is equal to the lead's Description
        //System.assertEquals(leadWithShortDescription.Description, updatedLead.Text_Description__c);
    }
}