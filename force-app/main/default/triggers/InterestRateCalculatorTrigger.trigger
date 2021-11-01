trigger InterestRateCalculatorTrigger on Account (before insert, before update) {
    
    for ( Account acc : Trigger.new) {
        
        //if record is created or edited
        if ( Trigger.isBefore && 
            ( Trigger.isInsert || Trigger.isUpdate)
           ) 
        {
               InterestRateCalculator.calculate(acc);
            
        }
    }



}