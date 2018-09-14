public class CHUKController extends nFORCE.TemplateController{
    
    public String searchText { 
        get { if (searchText == null) {
            
            List<Account> findNameList = [SELECT Name
                                          FROM Account
                                          WHERE Id = :contextObjectId LIMIT 1];
            
            searchText = findNameList[0].Name;
        }
             return searchText;
            }   
        set; }
    
    public String temp { get; set; }
    public superItemMapOne[] dataSetOne { get; set; }
    public Integer rowChosen {get; set;}
    public String searchTextEncoded {get; set;}
    public Integer itemsPerPage {get; set;}
    public Integer startIndex {get; set;}
    public Integer totalResults {get; set;}
    public Integer currentPageNumber {get; set;}
    public Integer totalPages {get; set;}
    
    
    public CHUKController(nFORCE.TemplateController controller) { }
    
    public boolean getHasNext() {
        
        return currentPageNumber == totalPages;
    }
    
    public boolean getHasPrevious() {
        
        return currentPageNumber <= 1;
    }
    
    public PageReference nextPage() {
        searchTextEncoded = EncodingUtil.urlEncode(searchText, 'UTF-8');
        itemsPerPage = 10;
        startIndex = startIndex + 10;
        String temp = makeCallout(searchTextEncoded, itemsPerPage, startIndex);
        handleResponse(temp);
        
        return null;
    }
    
    public PageReference previousPage() {
        searchTextEncoded = EncodingUtil.urlEncode(searchText, 'UTF-8');
        itemsPerPage = 10;
        startIndex = startIndex - 10;
        String temp = makeCallout(searchTextEncoded, itemsPerPage, startIndex);
        handleResponse(temp);
        
        return null;
    }
    
    public String makeCallout(String searchTextEncoded, Integer itemsPerPage, Integer startIndex) {
        
        
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://api.companieshouse.gov.uk/search/companies?q='+searchTextEncoded+'&items_per_page='+itemsPerPage+'&start_index='+startIndex);
        req.setMethod('GET');
        
        // Specify the required user name and password to access the endpoint
        // As well as the header and header information
        
        String username = 'n_NfEzHFlOIgv3caHja2UphCQgsHN2aAer7EkRcq';
        
        Blob headerValue = Blob.valueOf(username);
        String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
        req.setHeader('Authorization', authorizationHeader);
        
        Http http = new Http();
        HTTPResponse res = http.send(req);
        
        temp = res.getBody();
        
        return temp;
    }
    
    public Integer calculatePages() {
        Integer thing = totalResults / itemsPerPage;
        if (math.mod(totalResults,itemsPerPage) > 0) {
            thing++;
        }
        return thing;
    }
    
    public void handleResponse(String temp) {
        dataSetOne = new superItemMapOne[]{};
            
            
        CHUKResp.resp CHresponse = CHUKResp.parse(temp);
        system.debug(CHresponse);
        
        totalResults = CHresponse.total_results;
        currentPageNumber = CHresponse.page_number;
        totalPages = calculatePages();
        for(Integer i=0;i<CHresponse.items.size();i++){
            //                dataSetOne.add(new superItemMapOne(CHresponse.items[i].title,CHresponse.items[i].address_snippet,CHresponse.items[i].company_number, i));
            dataSetOne.add(new superItemMapOne(i,
                                               CHresponse.items[i].address.premises+' '+CHresponse.items[i].address.address_line_1,
                                               CHresponse.items[i].address.locality,
                                               CHresponse.items[i].address.region,
                                               CHresponse.items[i].address.country,
                                               CHresponse.items[i].address.postal_code,
                                               CHresponse.items[i].title,
                                               CHresponse.items[i].address_snippet,
                                               CHresponse.items[i].date_of_creation,
                                               CHresponse.items[i].company_number,
                                               CHresponse.items[i].company_type,
                                               CHresponse.items[i].company_status,
                                               'https://beta.companieshouse.gov.uk'+CHresponse.items[i].links.self));
        }
    }
    
    
    public PageReference SearchCompanyName() {
        searchTextEncoded = EncodingUtil.urlEncode(searchText, 'UTF-8');
        itemsPerPage = 10;
        startIndex = 0;
        String temp = makeCallout(searchTextEncoded, itemsPerPage, startIndex);
        
        handleResponse(temp);
        
        return null;
        
    }
    
    
    public class superItemMapOne{
        public Integer listOrder {get; set;}
        public string addressLine1 {get; set;}
        public string locality {get; set;}
        public string region {get; set;}
        public string country {get; set;}
        public string postalCode {get; set;}
        public string companyTitle {get; set;}
        public string addressSnippet {get; set;}
        public string dateOfCreation {get; set;}
        public string companyNumber {get; set;}
        public string companyType {get; set;}
        public string companyStatus {get; set;}
        public string link {get; set;}
        
        
        
        
        public superItemMapOne(Integer fc1, String fc2, String fc3, String fc4, String fc5, String fc6, String fc7, String fc8, String fc9, String fc10, String fc11, String fc12, String fc13) {
            listOrder = fc1;
            addressLine1 = fc2;
            locality = fc3;
            region = fc4;
            country = fc5;
            postalCode = fc6;
            companyTitle = fc7;
            addressSnippet = fc8;
            dateOfCreation = fc9;
            companyNumber = fc10;
            companyType = fc11;
            companyStatus = fc12;
            link = fc13;
            
            
        }
        
    }
    
    
    
    public pageReference selectCompany() {
        
        
        List<Account> accList = [SELECT Id, Name
                                 FROM Account
                                 WHERE Id = :contextObjectId LIMIT 1];
        
        
        
        List<Account> updateAccs = new List<Account>();
        
        if(accList.size() > 0){
            for(Account a : accList){
                a.name = dataSetOne[rowchosen].companyTitle ;
                a.shippingStreet = dataSetOne[rowchosen].addressLine1 ;
                a.shippingCity = dataSetOne[rowchosen].locality ;
                a.shippingState = dataSetOne[rowchosen].region;
                a.shippingPostalCode = dataSetOne[rowchosen].postalCode ;
                a.shippingCountry = dataSetOne[rowchosen].country ;
                
                
                a.billingStreet = dataSetOne[rowchosen].addressLine1 ;
                a.billingCity = dataSetOne[rowchosen].locality ;
                a.billingState = dataSetOne[rowchosen].region;
                a.billingPostalCode = dataSetOne[rowchosen].postalCode ;
                a.billingCountry = dataSetOne[rowchosen].country ;
                
                /////////////////////
                
                a.AccountNumber = dataSetOne[rowchosen].companyNumber;
                a.Type = dataSetOne[rowchosen].companyType;
                a.LLC_BI__Status__c = dataSetOne[rowchosen].companyStatus;
                a.Website = dataSetOne[rowchosen].link;
                
                
                updateAccs.add(a);
            }
            update updateAccs;
        }
        
        return getNextHref();
        
    }
    
    
    
    
    
}