@isTest
private class ChartHelperTest {
	
    @isTest
    private static void testGetInventory(){
      TestDataFactory.InsertTestData(2);
      List<ChartHelper.ChartData> lChartData = ChartHelper.GetInventory();
      System.assertEquals(lChartData[0].name,'Entree' );
      System.assertEquals(lChartData[0].val, 10.0);
      System.assertEquals(lChartData[1].name,'Side' );
      System.assertEquals(lChartData[1].val,10.0 );
    }
}