public without sharing class ChartHelper {
	
    @AuraEnabled
    public static List<chartData> GetInventory(){
        List<chartData> cht = new List<chartData>();
        AggregateResult[] productResults = [SELECT Family,SUM(Quantity_Remaining__c)qr FROM Product2 
                                          									where IsActive = true And 
                                           									Quantity_Remaining__c > 0 Group By Family];
        for(AggregateResult result : productResults){
            String productFamily = (String)result.get('Family');
            Decimal quantityRemaining = (Decimal)result.get('qr');
            cht.add(new ChartData(productFamily,quantityRemaining));
        }
        return cht;
    }

    public class ChartData {
        public String name {get;set;}
        public Decimal val {get;set;}

        public ChartData(String name, Decimal val){
            this.name = name;
            this.val = val;
        }
    }
}