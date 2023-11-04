SET SERVEROUTPUT ON;
SET VERIFY OFF;

Accept X CHAR prompt "source="
Accept Y CHAR prompt "destination="
Accept Z NUMBER prompt "COMPANYid="


create table travel(routeID int,companyID int,source varchar2(20),destination varchar2(20),Amount number );

Begin
    for R in (select route1.routeID,route1.companyID,route1.source,route1.destination,busfare.amount from route1 @site1 inner join busfare @site1 on busfare.routeID=route1.routeID union select route2.routeID,route2.companyID,route2.source,route2.destination,busfare.amount from route2 @site1 inner join busfare @site1 on busfare.routeID=route2.routeID union select route3.routeID,route3.companyID,route3.source,route3.destination,busfare.amount from route3 @site1 inner join busfare @site1 on busfare.routeID=route3.routeID)loop
		insert into travel values(R.routeID,R.companyID,R.source,R.destination,R.amount);
	end loop;
end;
/

CREATE OR REPLACE PACKAGE pack AS

	FUNCTION F1(A1 IN INT)
   	RETURN INT;

    PROCEDURE P1(B1 IN travel.source%TYPE,B2 IN travel.destination%TYPE);
END pack;
/



CREATE OR REPLACE PACKAGE BODY pack AS

	FUNCTION F1(A1 IN INT)
   	RETURN INT
   	IS 

   	A INT;

   	BEGIN
        	select COUNT(*) into A from TRAVEL where COMPANYID=A1;
        	RETURN A;
    END F1;

	PROCEDURE P1(B1 IN travel.source%TYPE,B2 IN travel.destination%TYPE)
	IS
	U travel.amount%TYPE:=NULL;
	Mins Number:=9999;
	onemIn Number:=9999;
	flag int:=0;
	
	
	
	BEGIN
		
            select min(amount) into U from travel where source=B1 and destination=B2;
			if U IS NOT NULL then
				for a in(select * from travel inner join Buscompany @site1 on travel.companyID=Buscompany.companyID where amount=U and source=B1 and destination=B2) loop
					dbms_output.put_Line('BEST ROUTE: '||a.source||' -> '||a.destination||' using '||a.companyName || ' costs in taka: ' ||a.amount);
					Onemin:=a.amount;
					exit;
				END LOOP;
			ELSE
				DBMS_OUTPUT.PUT_lINE('nO DIRECT pATH');
				flag:=flag+1;
			
			END if;
			
			for R in(select t1.routeID as fr, t1.companyID as fc,b.CompanyName as bn ,t1.source as fs, t1.destination as fd, t1.amount as fa,
						t2.routeID as mr, t2.companyID as mc, v.CompanyName as vn, t2.source as ms, t2.destination as md, t2.amount as ma
						from travel t1 inner join travel t2 on t1.destination=t2.source inner join Buscompany b on t1.companyID=b.companyID 
						inner join Buscompany v on t2.companyID=v.companyID where t1.source=B1 and t2.destination=B2 )loop
						
					
						if (R.fa+R.ma)<mins then
							mins:=R.fa+R.ma;
						end if;
					
			end loop;
			
			if mins<9999 then
			
				for R in(select t1.routeID as fr, t1.companyID as fc,b.CompanyName as bn ,t1.source as fs, t1.destination as fd, t1.amount as fa,
							t2.routeID as mr, t2.companyID as mc, v.CompanyName as vn, t2.source as ms, t2.destination as md, t2.amount as ma
							from travel t1 inner join travel t2 on t1.destination=t2.source inner join Buscompany b on t1.companyID=b.companyID 
							inner join Buscompany v on t2.companyID=v.companyID where t1.source=B1 and t2.destination=B2 )loop
							if mins=R.fa+R.ma then
							dbms_output.put_Line('BEST ROUTE USing two bus:');
								dbms_output.put_Line(R.fs||' -> '||R.fd||' using '||R.bn || ' costs in taka: ' ||R.fa);
								dbms_output.put_Line(R.ms||' -> '||R.md||' using '||R.vn || ' costs in taka: ' ||R.ma);
								exit;
							end if;
						
						
				end loop;
			else
				DBMS_output.put_line('NO two bus route');
				flag:=flag+1;
			
			end if;
			
			if flag!=2 then
			if(mins>=Onemin) then
				DBMS_output.put_line('Take the one bus route');
			else
				
				DBMS_output.put_line('Take the two bus route');
					
				
			end if;
			else
				DBMS_output.put_line('There is no route');
			end if;
			
		
	
	END P1;

	
END pack;
/
DECLARE
	
	C VARCHAR2(20);
	d VARCHAR2(20);
	T INT;
	M INT;
	
BEGIN
	
	C:='&X';
	D:='&y';
	T:=&Z;
	
	pack.P1(C,d);
	M:=PACK.F1(t);
	DBMS_output.put_line('number of routes for company ='||T||' :'||m);
	
END;
/
drop table travel;
BEGIN
  NULL;
END;
 

/
