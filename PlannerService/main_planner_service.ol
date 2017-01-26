include "string_utils.iol"
include "console.iol"
include "database.iol"
include "xml_utils.iol"
include "./public/interfaces/PlannerInterface.iol"


execution{ concurrent }

main{
  [createPlan(request)(response){
    scope (createPlanScope){
      install (default=> valueToPrettyString@StringUtils(createPlanScope)(s);
            println@Console(s)());
       q.statement[0] = "insert into plan_header ( mrn , doctor , date ) values ()( mrn , doctor , to_date(:date, 'dd/MM/yyyy' )";
       q.statement[0].name = request.name;
       q.statement[0].doctor = request.doc;
       q.statement[0].date = request.date;
       q.statement[1] = "select currval('plan_sequence') as cur_val";
       executeTransaction@Database(q)(resultQ);
       valueToPrettyString@StringUtils(resultQ)(s);
       println@Console(s)();
       response.plan_id = resultQ.result[1].row.cur_val
      }
    }]
  [deletePlan(request)(response){
    scope (deletePlanScope){
      install (default=> valueToPrettyString@StringUtils(deletePlanScope)(s);
            println@Console(s)());
           q.statament[0]= "delete from plan_step where plan_id = :plan_id";
           q.statement[0].plan_id = plan_id;
           q.statament[1]= "delete from plan_header where plan_id = :plan_id";
           q.statement[1].plan_id = plan_id;
           executeTransaction@Database(q)(resultQ);
           valueToPrettyString@StringUtils(resultQ)(s);
           println@Console(s)()
     }
    }]

    [addStepToPlan(request)(response){
      scope (addStepToPlanScope){
        install (default=> valueToPrettyString@StringUtils(addStepToPlanScope)(s);
              println@Console(s)());
              valueToXmlRequest.root = request;
              valueToXml@XmlUtils(valueToXmlRequest)(responseToXmlResponse);
              q.statament[0]= "insert into plan_step (plan_id , function , data)";
              q.statement[0].plan_id = request.plan_id;
              q.statement[0].function = request.function;
              q.statement[0].data =  responseToXmlRespone;
              q.statament[1] = "select currval('plan_step_sequence') as cur_val";
              for (counter=0 , counter<#request.prerequisit, counter++ ){
                q.statament[2+counter] = "insert into plan_step_pre (plan_id, step_id , prereq ) values (currval('plan_step_sequence'), :prereq )";
                q.statament[2+counter].prereq = request.prerequisit[counter]
              };
              valueToPrettyString@StringUtils(q)(s);
              println@Console(s)();
              executeTransaction@Database(q)(resultQ);
              valueToPrettyString@StringUtils(resultQ)(s);
              println@Console(s)()
        }
    }]

}
