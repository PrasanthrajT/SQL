create database inventory;

use inventory;

select top 1 * from INFORMATION_SCHEMA.TABLES;

select top 1 * from inventories;

select  * from products;

--update products  set UnitPrice = 1000 where ProductID='P013'

select  * from sales_with_profit order by ProductID asc

--rename inventory table EXEC sp_rename 'inventory', 'inventories';

select * from inventory.dbo.inventories where (productid is null) or (stockqty is null) or (warehouse is null)


--📦 1. Product Movement & Sales
----------------------------------

--Total Sales & Revenue by Product/Category

select a.Category,a.productname,
--a.productname as Product,
sum(b.TotalPrice) as TotalRevenue ,
sum(b.Quantity * a.UnitPrice) as cost,
sum(b.quantity) as TotalSales,
SUM(b.TotalPrice - (b.Quantity * a.UnitPrice)) AS EstimatedProfit
from Products a join sales_with_profit b on a.productid = b.productid
group by a.Category,a.productname,b.productid
order by a.category asc;

--🔹 What is the total quantity sold for each product category?
select  category,sum(quantity) Total_sold from
products p join sales_with_profit s
on p.productid=s.productid
group by Category

--Fast moving , moderate, Slow moving products.
select a.Category,a.productname,
--a.productname as Product,
sum(b.quantity) as TotalSales,
case when sum(b.quantity)>=100 then 'Fast'
	when sum(b.quantity)>=50 then 'Moderate'
	Else 'Slow'
	end as Movement_type
from Products a join sales_with_profit b on a.productid = b.productid
group by a.Category,a.productname
order by a.category asc;

--Which product has the highest and lowest sales volume?
select * from
(select top 1 a.Category,a.productname,sum(b.quantity) as Highest_sales_volume
from Products a join sales_with_profit b on a.productid = b.productid
group by a.Category,a.productname
order by sum(b.quantity) desc) a, 
(select top 1 a.Category,a.productname,sum(b.quantity) as Lowest_sales_volume
from Products a join sales_with_profit b on a.productid = b.productid
group by a.Category,a.productname
order by sum(b.quantity) asc)b

--🔹 Which product contributes the most to total revenue?
select top 1 a.Category,a.productname,sum(b.TotalPrice) as Highest_sales_volume
from Products a join sales_with_profit b on a.productid = b.productid
group by a.Category,a.productname
order by sum(b.TotalPrice) desc;


--🏪 2. Inventory Health & Reorder Management
--Which products are below their reorder level and need immediate attention?
select p.productname,i.StockQty stock, p.ReorderLevel 
from products p join inventories i on p.ProductID =i.ProductID
where i.StockQty<p.ReorderLevel
order by i.StockQty asc;

--🔹 Which products are completely out of stock?
select p.productname,i.StockQty stock, p.ReorderLevel
from products p join inventories i on p.ProductID =i.ProductID
where  i.StockQty < 10
order by i.StockQty asc;

--What is the total value of inventory that is currently in stock (UnitPrice × StockQty)?

select sum(p.unitprice * i.stockqty) totalamount
 from products p join inventories i on p.ProductID =i.ProductID;

 --alter table inventories alter column stockqty int;

--🔹 How many days of stock are left for each product based on last 30-day average sales?


SELECT c.productname,
       (b.StockQty-avg(a.Quantity))/avg(a.Quantity) Stockleftindays
FROM sales_with_profit a
JOIN inventories b ON a.ProductID=b.ProductID --order by saledate desc
join products c on a.ProductID =c.ProductID
WHERE saledate BETWEEN
    (SELECT dateadd(DAY, -30, max(saledate))
     FROM sales_with_profit) AND
    (SELECT Max(saledate)
     FROM sales_with_profit)
GROUP BY c.Productname,
         b.StockQty
ORDER BY c.productname ASC;


--📈 3. Revenue, Cost & Profit Analysis Finance & optimization logic

--🔹 What is the profit made on each product? (Revenue - Cost = (SellingPrice - UnitPrice) × Quantity)

SELECT p.ProductName,
       sum(p.UnitPrice* s.Quantity) AS Cost,
       sum(s.TotalPrice) AS Revenue,
       sum(s.TotalPrice - (p.UnitPrice* s.Quantity)) Profit,
     cast( round((sum(s.TotalPrice - (p.UnitPrice* s.Quantity))*100.0) /ISNULL( sum(p.UnitPrice* s.Quantity),0),2) as decimal(5,2)) AS profitper
FROM products p
JOIN sales_with_profit s ON p.ProductID =s.ProductID
GROUP BY p.ProductName;

--🔹 What is the overall profit by product category?
select p.Category,sum(s.Quantity) QTY , sum(s.TotalPrice) sales,sum(p.UnitPrice*s.Quantity) cost,
sum(s.TotalPrice -(p.UnitPrice*s.Quantity)) profit
--,format((sum(s.TotalPrice -(p.UnitPrice*s.Quantity)) / sum(p.UnitPrice*s.Quantity)) profit2
,CAST(ROUND(
    (SUM(s.TotalPrice - (p.UnitPrice * s.Quantity)) * 100.0) / 
     NULLIF(SUM(p.UnitPrice * s.Quantity), 0), 2) AS DECIMAL(5,2)) AS ProfitMarginPercent
from sales_with_profit s join products p on p.productid = s.productid
--where p.ProductID='P002'
group by p.Category;


--🔹 Which product has the highest profit margin?
select top 1 p.ProductName,sum(s.Quantity) QTY , sum(s.TotalPrice) sales,sum(p.UnitPrice*s.Quantity) cost,
sum(s.TotalPrice -(p.UnitPrice*s.Quantity)) profit
,cast( round(((sum(s.TotalPrice -(p.UnitPrice*s.Quantity))*100.0)/(sum(p.UnitPrice*s.Quantity)) ),2)as decimal(5,2))
from sales_with_profit s join products p on p.productid = s.productid
--where p.ProductID='P002'
group by p.ProductName
order by sum(s.TotalPrice -(p.UnitPrice*s.Quantity))  desc;

--🔹 Find products being sold at a loss.
select top 1 p.ProductName,sum(s.Quantity) QTY , sum(s.TotalPrice) sales,sum(p.UnitPrice*s.Quantity) cost,
sum(s.TotalPrice -(p.UnitPrice*s.Quantity)) profit
,cast( round(((sum(s.TotalPrice -(p.UnitPrice*s.Quantity))*100.0)/(sum(p.UnitPrice*s.Quantity)) ),2)as decimal(5,2))
from sales_with_profit s join products p on p.productid = s.productid
--where p.ProductID='P002'
group by p.ProductName
order by sum(s.TotalPrice -(p.UnitPrice*s.Quantity))  asc;

--📅 4. Time Series Trends For Power BI line/area charts

--🔹 Show monthly sales trend across the last 12 months.
select DATEname(month,saledate), sum(TotalPrice) sales--,EOMONTH(saledate) monthendate
from sales_with_profit
where SaleDate> DATEADD(month,-12,(select max(saledate) from sales_with_profit))
--saledate between (select max((saledate)) from sales_with_profit) and  (select dateadd(month,max(saledate),-12) from sales_with_profit)
group by DATEname(month,saledate),EOMONTH(saledate)
order by EOMONTH(saledate) asc

--Compare revenue between current and previous month.
select DATEname(month,saledate), sum(TotalPrice) sales, lag(sum(TotalPrice)) over(order by EOMONTH(saledate) asc)
from sales_with_profit
group by DATEname(month,saledate),EOMONTH(saledate)
order by EOMONTH(saledate) asc

--🔹 What are the top 3 revenue-generating months?
select top 3 productname,sum(totalprice) sales
from products p join sales_with_profit s on p.ProductID =s.ProductID
group by productname
order by sum(totalprice) desc

--🔹 Which products are consistently selling every month?
select top 1 --(select count (distinct eomonth(saledate)) from sales_with_profit),
productid ,count(month) no_of_months from (select Productid,DATENAME(month,SaleDate) month,count(productid) productcount,EOMONTH(saledate) endofmonth
from sales_with_profit
--where ProductID='P001'
group by EOMONTH(saledate),DATENAME(month,SaleDate),Productid)a
group by a. productid
having count(month)  <= (select count(distinct eomonth(saledate)) from sales_with_profit)
order by count(month) desc;

--👤 5. Business Decision Use-Cases For storytelling in interviews or README

--🔹 If you had to remove 5 low-performing products, which would you choose and why?
select top 5 productname,sum(quantity)
from products p join sales_with_profit s on p.ProductID =s.ProductID
group by ProductName
order by sum(quantity) asc

--🔹 How can stock reorder rules be adjusted to reduce holding cost?
We observed that certain products have low movement (slow-moving) but are still stocked well above their reorder level. 
This leads to unnecessary holding cost. 
To reduce this:
- Adjust reorder levels based on monthly demand trend
- Use 30-day average sales to calculate reorder quantity
- Flag overstocked slow-movers and reduce their reorder threshold


--🔹 Identify mismatch between sales and inventory — are fast-moving products always well-stocked?
SELECT 
    p.ProductName,
    SUM(s.Quantity) AS TotalSold,
    i.StockQty,
    CASE 
        WHEN SUM(s.Quantity) >= 100 AND i.StockQty < p.ReorderLevel THEN 'Mismatch - Fast Moving but Low Stock'
        ELSE 'OK'
    END AS StockStatus
FROM 
    Products p
JOIN 
    sales_with_profit s ON p.ProductID = s.ProductID
JOIN 
    inventories i ON p.ProductID = i.ProductID
GROUP BY 
    p.ProductName, i.StockQty, p.ReorderLevel
ORDER BY 
    TotalSold DESC;

