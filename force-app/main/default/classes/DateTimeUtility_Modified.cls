// Created by Carl Vescovi on 27/03/2021
// https://unofficialsf.com/flow-datetime-methods/
// Modified by Mike Liu on 18/03/2022 for FSA-584 POC

global class DateTimeUtility_Modified {
    
    public class DateTimeUtilityException extends Exception{}

    @InvocableMethod(label='Date, time and Business Hours methods_Modified'
                     description='Exposes date,datetime and business hours methods available in Apex to Flow. See Apex documentation for method details.'
                     category='Uncategorized')
    public static List<DateTimeRequestResponse> methods(List<DateTimeRequest> requests) {
        // The datetime input should use the standard flow datetime string format “dd/mm/yy hh:mm a” in the local time zone.
        // TODO regex to confirm input format
        List<DateTimeRequestResponse> results = new List<DateTimeRequestResponse>();
        for(DateTimeRequest dtr : requests){
            Datetime dt;
            Date dd;

            if((dtr.dateTimeString == null || dtr.dateTimeString == '') && dtr.methodName != 'Date.today'){ 
                throw new DateTimeUtilityException('Datetime string cannot be null error');
            } else {
                dd = Date.today(); dt = Datetime.now(); // avoid null error handling
            }
      system.debug(Datetime.now());
            system.debug(dt);
            system.debug(dtr.dateTimeString);
            Boolean ISDATEMETHOD = (dtr.methodName.left(5) == 'Date.') ? true : false;
            if(dtr.returnFormat == null || dtr.returnFormat == ''){
                dtr.returnFormat = (ISDATEMETHOD) ? 'yyyy-MM-dd' : 'yyyy-MM-dd HH:mm:ss';
            } 
            
            if(dtr.methodName != 'Date.today'){ // set initial datetime or date values
                if(ISDATEMETHOD) {
                    dd = Date.parse(dtr.dateTimeString); // expecting only date portion to parse
                } else {
                      if(userinfo.getName() =='Eloqua Marketing'){
                        dt = Datetime.now();
                          system.debug(dt);
                    }else{
                    dt = Datetime.parse(dtr.dateTimeString);
                    }
                }
            }
             system.debug(dt);

            DateTimeRequestResponse result = new DateTimeRequestResponse();
            result.result = ''; // default
          
            
            // process by method
            switch on dtr.methodName {
                when 'Datetime.addDays' {
                    dt = dt.addDays(dtr.increment);
                }
                when 'Datetime.addHours' {
                    dt = dt.addHours(dtr.increment);
                }
                when 'Datetime.addMinutes' {
                    dt = dt.addMinutes(dtr.increment);
                }
                when 'Datetime.addSeconds' {
                    dt = dt.addSeconds(dtr.increment);
                }
                when 'Datetime.addMonths' {
                    dt = dt.addMonths(dtr.increment);
                }
                when 'Datetime.addYears' {
                    dt = dt.addYears(dtr.increment);
                }
                when 'Datetime.formatGmt' {
                    result.result = dt.formatGmt(dtr.returnFormat); 
                }
                when 'Datetime.format' {
                    // multiple signatures to consider
                    result.result = (dtr.timezone > '') ? 
                        dt.format(dtr.returnFormat, dtr.timeZone) : dt.format(dtr.returnFormat);
                }
                when 'Datetime.formatLong' {
                    result.result = dt.formatLong(); 
                }
                when 'Datetime.getTime' {
                    result.result = String.valueOf(dt.getTime());
                }
                when 'Datetime.hour' {
                    result.result = String.valueOf(dt.hour());
                }
                when 'Datetime.hourGmt' {
                    result.result = String.valueOf(dt.hourGmt());
                }
                when 'Datetime.millisecond' {
                    result.result = String.valueOf(dt.millisecond());
                }
                when 'Datetime.millisecondGmt' {
                    result.result = String.valueOf(dt.millisecondGmt());
                }
                when 'Datetime.minute' {
                    result.result = String.valueOf(dt.minute());
                }
                when 'Datetime.minuteGmt' {
                    result.result = String.valueOf(dt.minuteGmt());
                }
                when 'Datetime.month' {
                    result.result = String.valueOf(dt.month());
                }
                when 'Datetime.monthGmt' {
                    result.result = String.valueOf(dt.monthGmt());
                }
                when 'Datetime.second' {
                    result.result = String.valueOf(dt.second());
                }
                when 'Datetime.secondGmt' {
                    result.result = String.valueOf(dt.secondGmt());
                }
                when 'Datetime.time' {
                    result.result = String.valueOf(dt.time());
                }
                when 'Datetime.timeGmt' {
                    result.result = String.valueOf(dt.timeGmt());
                }
                when 'Datetime.year' {
                    result.result = String.valueOf(dt.year());
                }
                when 'Datetime.yearGmt' {
                    result.result = String.valueOf(dt.yearGmt());
                }
                when 'Datetime.day' {
                    result.result = String.valueOf(dt.day());
                }
                when 'Datetime.dayGmt' {
                    result.result = String.valueOf(dt.dayGmt());
                }
                when 'Datetime.now' {
                    dt = datetime.now(); // will be formatted to user preference later
                }
                // additional business hours specific methods
                when 'BusinessHours.add' {
                    dt = BusinessHours.add(dtr.BizHrId, 
                                            dt, 
                                            (Long)dtr.increment);
                }
                when 'BusinessHours.addGmt' {
                    dt = BusinessHours.addGmt(dtr.BizHrId, 
                                            dt, 
                                            (Long)dtr.increment);
                    result.result = dt.format(dtr.returnFormat);
                }
                when 'BusinessHours.diff'{
                    if(dtr.secondDateString == null)
                        throw new DateTimeUtilityException('Diff method requires secondDateString error');
                    result.result = String.valueOf(BusinessHours.diff(dtr.BizHrId,
                                            dt,
                                            Datetime.parse(dtr.secondDateString)));
                    
                }
                when 'BusinessHours.isWithin'{
                    result.result = BusinessHours.isWithin(dtr.BizHrId,
                                                    dt) ? 'true' : 'false';
                }
                when 'BusinessHours.nextStartDate'{
                    dt = BusinessHours.nextStartDate(dtr.BizHrId, dt);
                }
                when 'Date.addDays' {
                    dd = dd.addDays(dtr.increment);
                }
                when 'Date.addMonths' {
                    dd = dd.addMonths(dtr.increment);
                }
                when 'Date.addYears' {
                    dd = dd.addYears(dtr.increment);
                }
                when 'Date.day' {
                    result.result = String.valueOf(dd.day());
                }
                when 'Date.dayOfYear' {
                    result.result = String.valueOf(dd.dayOfYear());
                }
                when 'Date.daysBetween' {
                    result.result = 
                        String.valueOf(dd.daysBetween(Date.parse(dtr.secondDateString)));
                }
                when 'Date.daysInMonth' {
                    // uses the date passed in for its year and month inputs
                    result.result = 
                        String.valueOf(Date.daysInMonth(dd.year(), dd.month()));
                }
                when 'Date.isLeapYear' {
                    // uses the date passed in for its year value
                    result.result = String.valueOf(Date.isLeapYear(dd.year()));
                }
                when 'Date.month' {
                    result.result = String.valueOf(dd.month());
                }
                when 'Date.monthsBetween' {
                    result.result = 
                        String.valueOf(dd.monthsBetween(Date.parse(dtr.secondDateString)));
                }
                when 'Date.today'{
                    result.result = Date.today().format();
                }
                when 'Date.toStartOfMonth'{
                    result.result = dd.toStartOfMonth().format();
                }
                when 'Date.toStartOfWeek'{
                    result.result = dd.toStartOfWeek().format();
                }
                when 'Date.year'{
                    result.result = String.valueOf(dd.year());
                }
                when else {
                    throw new DateTimeUtilityException('No method called '+dtr.methodName+' found.');  
                }
            }
            if(result.result == '' && !ISDATEMETHOD) {
                result.result = (dtr.timeZone > '') 
                    ? dt.format(dtr.returnFormat, dtr.timeZone) : dt.format(dtr.returnFormat);
            } else 
            if(result.result == ''){
                result.result = dd.format();
            }
      //result.resultdatetime = DateTime.parse(result.result);
      result.resultdatetime =  datetime.valueOf(result.result);
            system.debug(result.result);
            system.debug(result.resultdatetime);
            results.add(result);
            system.debug(results);
        }
        return results;
    }

    public class DateTimeRequest {
        @InvocableVariable(label='Apex Datetime method to apply' required=true) public string methodName;
        @InvocableVariable(label='Business Hours ID' required=true) public string BizHrId;
        @InvocableVariable(label='Datetime input (First Date)' description='expecting local timezone datetime input variable' required=true) public string dateTimeString;
        @InvocableVariable(label='Additional days, hours, minutes, months, years or seconds (increment time add to First Date)' description='see add methods' required=false) public integer increment;
        @InvocableVariable(label='Returned datetime format' description='see java see Java SimpleDateFormat spec for patterns' required=false) public string returnFormat;
        @InvocableVariable(label='Timezone to convert to' description='see java spec for patterns' required=false ) public string timeZone;
        @InvocableVariable(label='Second Date for BusinessHours.diff calculation.' description='see java spec for patterns' required=false ) public string secondDateString;
        
    }

    public class DateTimeRequestResponse {
        @InvocableVariable(label='error' ) public boolean errorOccured;
        @InvocableVariable(label='error Message' ) public string errorMessage;
        @InvocableVariable(label='result' ) public string result;
        @InvocableVariable(label='resultdatetime' ) public datetime resultdatetime;
        
        public DateTimeRequestResponse(){
            this.errorOccured = false;
            this.errorMessage = '';
            this.result = '';
            
        }
    }    
}