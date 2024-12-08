--SQL Advance Case Study
use db_SQLCaseStudies

--Q1--BEGIN 
select l.State,year(f.date) as year_of_sales, sum(f.quantity) as cnt from DIM_LOCATION l
left join FACT_TRANSACTIONS f
on l.IDLocation=f.IDLocation
where year(f.Date)>=2005
group by l.State,year(f.date);
--Q1--END

--Q2--BEGIN
select top 1* from	
	(select l.Country,l.State,sum(f.quantity) as total_sales from DIM_LOCATION l
	inner join FACT_TRANSACTIONS f
	on l.IDLocation=f.IDLocation
	left join DIM_MODEL m
	on f.IDModel=m.IDModel
	left join DIM_MANUFACTURER mr
	on m.IDManufacturer=mr.IDManufacturer
	where l.Country='us'
	and mr.IDManufacturer=12
	group by l.Country,l.State
	) as t1
--Q2--END

--Q3--BEGIN 
select m.Model_Name,l.ZipCode,l.State, count(f.idcustomer) as transactions from FACT_TRANSACTIONS f
left join DIM_LOCATION l
on f.IDLocation=l.IDLocation
join DIM_MODEL m
on f.IDModel=m.IDModel
group by m.Model_Name,l.ZipCode,l.State;
--Q3--END

--Q4--BEGIN
select top 1* from	
	(select IDModel,Model_Name,min(unit_price) as price from DIM_MODEL
	group by IDModel, model_name) as cellphone
	order by price asc;
--Q4--END

--Q5--BEGIN 
select m.Model_Name,avg(t.totalprice)as avg_price, sum(quantity) as total_qty from FACT_TRANSACTIONS t
join DIM_MODEL m on t.IDModel=m.IDModel
join DIM_MANUFACTURER mr on m.IDManufacturer=mr.IDManufacturer
where mr.Manufacturer_Name in (select top 5 mr.Manufacturer_Name from FACT_TRANSACTIONS t
								join DIM_MODEL m on t.IDModel=m.IDModel
								join DIM_MANUFACTURER mr on m.IDManufacturer=mr.IDManufacturer
								group by mr.Manufacturer_Name
								order by sum(t.totalprice) desc)
group by m.Model_Name
order by avg_price desc;
--Q5--END

--Q6--BEGIN
select c.IDCustomer,c.Customer_Name,year(f.date) as [year],avg(f.totalprice) as avg_amt from DIM_CUSTOMER c
left join FACT_TRANSACTIONS f
on c.IDCustomer=f.IDCustomer
where year(f.date)=2009
group by c.IDCustomer,c.Customer_Name,year(f.date)
having avg(f.totalprice)>500;
--Q6--END
	
--Q7--BEGIN  
select * from 	
	(select top 5 IDModel from FACT_TRANSACTIONS 
	where year(date)=2008
	group by IDModel,year(date)
	order by sum(quantity) desc) as A
intersect	
Select * from	
	(select top 5 IDModel from FACT_TRANSACTIONS 
	where year(date)=2009
	group by IDModel,year(date)
	order by sum(quantity) desc) as B
intersect	
Select * from
	(select top 5 IDModel from FACT_TRANSACTIONS 
	where year(date)=2010
	group by IDModel,year(date)
	order by sum(quantity) desc) as C
--Q7--END

--Q8--BEGIN
select * from 	
	(
	select mr.Manufacturer_Name,year(f.date) as [year],sum(f.TotalPrice) as tot_sales, 
	RANK() over (partition by year(f.date) order by sum(f.totalprice) desc) as [rank] from FACT_TRANSACTIONS f
	inner join DIM_MODEL m
	on f.IDModel=m.IDModel
	inner join DIM_MANUFACTURER mr
	on m. IDManufacturer=mr.IDManufacturer
	where year(f.date) in ( '2009','2010')
	group by mr.Manufacturer_Name,year(f.date)) t1
	where rank=2
--Q8--END


--Q9--BEGIN

	select mr.IDManufacturer,mr.Manufacturer_Name from FACT_TRANSACTIONS f
	join DIM_MODEL m
	on f.IDModel=m.IDModel
	left join DIM_MANUFACTURER mr
	on m.IDManufacturer=mr.IDManufacturer
	where year(f.date)=2010
	group by mr.IDManufacturer,mr.Manufacturer_Name
except
	select mr.IDManufacturer,mr.Manufacturer_Name from FACT_TRANSACTIONS f
	join DIM_MODEL m
	on f.IDModel=m.IDModel
	left join DIM_MANUFACTURER mr
	on m.IDManufacturer=mr.IDManufacturer
	where year(f.date)=2009
	group by mr.IDManufacturer,mr.Manufacturer_Name
	
--Q9--END

--Q10--BEGIN
select *, (avg_price-lag_price)/lag_price as percentage_difference from	
	(select *,lag(avg_price,1)over(partition by idcustomer order by year_1) as lag_price 
	 from
	(select idcustomer,year(date)as year_1, avg(totalprice) as avg_price,
	avg(quantity)as qty from FACT_TRANSACTIONS
	where IDCustomer in (select top 10 IDCustomer from FACT_TRANSACTIONS
							group by IDCustomer
							order by sum(totalprice) desc)
	group by IDCustomer,year(date)) as t1) as t2
--Q10--END
	