USE FDA;
select *  from application;
 select * from appdoc;
 select * from regactiondate WHERE ACTIONTYPE<>"AP";
 select * from application where APPLTYPE="N";
 
##Task 1: Identifying Approval Trends 
 
#1. Determine the number of drugs approved each year and provide insights into the yearly 
#trends. 
SELECT count(a.applno) ,year(r.actiondate) AS APPROVAL_DATE
 from aPPLICATION as A INNER JOIN regactiondate AS R
 ON A.ApplNo = R.ApplNo  where A.ActionType ="AP" GROUP BY YEAR (r.actiondate) order by APPROVAL_DATE;
 


#2. Identify the top three years that got the highest and lowest approvals, in descending  and 
#ascending  order, respectively. 
select count(applno) as no_of_appl , year(actiondate)  from regactiondate 
group by year(actiondate) order by no_of_appl desc
limit 3;

select count(applno) as no_of_appl , year(actiondate)  from regactiondate
group by year(actiondate) order by no_of_appl
limit 3;

 
#3. Explore approval trends over the years based on sponsors.  
select A.sponsorapplicant,year(R.ACTIONDATE) as approval_year,COUNT(A.applno) as no_of_app
from application as A inner join regactiondate as R
on a.applno = r.applno
 GROUP BY YEAR(R.actiondate),a.sponsorapplicant order by approval_year,no_of_app desc;
 
#4. Rank sponsors based on the total number of approvals they received each year between 1939 
#and 1960. 
select  A.sponsorapplicant as sponsor_name , count(A.applno) as no_of_approvals,year(r.actiondate) as approval_year,
dense_rank() over(partition by year(r.actiondate) order by count(a.applno) desc) as "rank"
from  application as A INNER JOIN regactiondate as R 
ON A.applno = R.applno where year(R.actiondate) between 1939 and 1960
group by a.sponsorapplicant,year(r.actiondate)
order by approval_year,no_of_approvals desc ;

##Task 2: Segmentation Analysis Based on Drug MarketingStatus 
 select * from product;
 select * from product_tecode;
 
#1. Group products based on MarketingStatus. Provide meaningful insights into the 
#segmentation patterns. 
 select productmktstatus ,
 count(*) as total_count,
 (case when productmktstatus=1 then "marketed" when productmktstatus=2 then "withdrawn" when productmktstatus =3  then "pending" else "pre market" end) as MARKET_STATUS
 from product group by productmktstatus;

#2. Calculate the total number of applications for each MarketingStatus year-wise after the year 
#2010.  
SELECT p.productmktstatus,year(r.actiondate), count(p.applno) as total_applications
from product as p inner join application as a inner join regactiondate as r 
on p.applno = a.applno and a.applno =r.applno
where year(r.actiondate) > 2010 group by year(r.actiondate),p.productmktstatus 
order by year(r.actiondate), p.productmktstatus ;

#3. Identify the top MarketingStatus with the maximum number of applications and analyze its 
#trend over time. 
select year(r.actiondate) ,
 count(p.applno) as total_application,
 (case when productmktstatus=1 then "marketed" when productmktstatus=2 then 
 "withdrawn" when productmktstatus =3  then "pending" else "pre market" end) as MARKET_STATUS
from product as p inner join application as a inner join regactiondate as r 
on p.applno = a.applno and a.applno =r.applno 
group by year(r.actiondate),p.productmktstatus 
order by total_application desc limit 10 ;

##Task 3: Analyzing Products 
 
#1. Categorize Products by dosage form and analyze their distribution. 
select form,productmktstatus,count(productno) as no_of_products_per_category from product
group by form, productmktstatus order by no_of_products_per_category desc;

#2. Calculate the total number of approvals for each dosage form and identify the most 
#successful forms. 
select form,count(applno)  as no_of_approvals from product where applno in
(select a.applno from application as a left join regactiondate as r on a.applno = r.applno) 
group by form order by no_of_approvals  desc;  

#3. Investigate yearly trends related to successful forms.   
SELECT 
p.form,YEAR(r1.actiondate) AS approval_year,COUNT(p.applno) AS no_of_approvals
FROM product AS p INNER JOIN regactiondate AS r1 ON p.applno = r1.applno
WHERE p.applno IN 
        (SELECT r.applno FROM regactiondate AS r INNER JOIN application AS a ON a.applno = r.applno
        GROUP BY YEAR(r.actiondate)
        ORDER BY YEAR(r.actiondate))
GROUP BY approval_year, p.form
ORDER BY no_of_approvals DESC
LIMIT 3;

##Task 4: Exploring Therapeutic Classes and Approval Trends 
 select * from product_tecode WHERE TEcode <> "AA" ;
 
#1. Analyze drug approvals based on therapeutic evaluation code (TE_Code). 

SELECT  P.TECODE,COUNT(P.PRODUCTNO) AS NO_OF_PRODUCTS from 
APPLICATION AS A INNER JOIN REGACTIONDATE AS R INNER JOIN PRODUCT AS P
ON A.APPLNO=R.APPLNO AND A.APPLNO = P.APPLNO
GROUP BY P.TECODE ORDER BY NO_OF_PRODUCTS DESC;

#2. Determine the therapeutic evaluation code (TE_Code) with the highest number of Approvals in 
#each year. 
SELECT YEAR(R.ACTIONDATE) AS YEAR_OF_APPROVAL,P.TECODE,COUNT(P.PRODUCTNO) AS NO_OF_PRODUCTS from 
APPLICATION AS A INNER JOIN REGACTIONDATE AS R INNER JOIN PRODUCT AS P
ON A.APPLNO=R.APPLNO AND A.APPLNO = P.APPLNO
GROUP BY YEAR(R.ACTIONDATE), P.TECODE ORDER BY YEAR_OF_APPROVAL,NO_OF_PRODUCTS DESC;