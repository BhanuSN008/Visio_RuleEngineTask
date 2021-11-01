public without sharing class InterestRateCalculator {

    public class CalculatorException extends Exception {}
    private static final Double BASE_INTEREST_RATE = 5.0;



    public static void calculate(Account acc) {
        
        //Load rules
        List<Interest_Rule__mdt> rulesList = [select Id, Disqualified__c, Interest_Rate__c, 
                                   (select  Field_Name__c, Operator__c, Value__c 
                                   from Interest_Rule_Criterias__r) 
                                   from Interest_Rule__mdt 
where IsActive__c = true order by Rule_Order__c asc];
        
        Double interestRateOffset = 0;
        Boolean isDisqualifed = false;
        for ( Integer idx=0; !isDisqualifed && idx < rulesList.size(); idx++ ) {
            Interest_Rule__mdt rule = rulesList.get(idx);
            if ( !isDisqualifed && evaluateRule(rule, acc) ) {
                //rule matched
                //apply actions
                isDisqualifed = rule.Disqualified__c;
                if ( rule.Interest_Rate__c != null) {
                    interestRateOffset = interestRateOffset + rule.Interest_Rate__c;
                }
            }
        }
        
        if ( !isDisqualifed ) {
        	acc.Interest_Rate__c = BASE_INTEREST_RATE + interestRateOffset;
            acc.Disqualified__c = false;
        }
        else {
            //TODO: set to 0
            acc.Interest_Rate__c = 0;
            acc.Disqualified__c = true;
        }
        
        
    }
    
    private static Boolean evaluateRule(Interest_Rule__mdt rule, Account acc) {
        
        if ( rule.Interest_Rule_Criterias__r.size() > 0) {
            
            //evaluate criteria
            Boolean criteriaResult = true;
            for ( Interest_Rule_Criteria__mdt criteria : rule.Interest_Rule_Criterias__r) {

                criteriaResult = criteriaResult && evaluateCriteria(criteria, acc);

                if (!criteriaResult) {
                    //criteria evaluated to false
                    return false;
                }

            }

            return criteriaResult;

        }
        else {
 			//not criterias found
            return false;
        }
        
       // return false;
    }
    
    private static Boolean evaluateCriteria(Interest_Rule_Criteria__mdt criteria, Account acc) {
        
        if( criteria.Operator__c == '=') {
            return (String.valueOf(acc.get(criteria.Field_Name__c)) == criteria.Value__c);
        }
        else if (criteria.Operator__c == '>') {
            return Double.valueOf(acc.get(criteria.Field_Name__c)) > Double.valueOf(criteria.Value__c);
        }
        else if (criteria.Operator__c == '>=') {
            return Double.valueOf(acc.get(criteria.Field_Name__c)) >= Double.valueOf(criteria.Value__c);
        }
        else if (criteria.Operator__c == '<') {
            return Double.valueOf(acc.get(criteria.Field_Name__c)) < Double.valueOf(criteria.Value__c);
        }
        else if (criteria.Operator__c == '<=') {
            return Double.valueOf(acc.get(criteria.Field_Name__c)) < Double.valueOf(criteria.Value__c);
        }
        else {
            System.debug('invalid operator');
        }
        
        return false;
    }

}